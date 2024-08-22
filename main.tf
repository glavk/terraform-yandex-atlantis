locals {
  folder_id      = data.yandex_resourcemanager_folder.this.id
  webhook_secret = "AtlasWebhookSecret"
  gh_token       = "ghp_xxx"
  gh_user        = "glavk"
}

data "yandex_resourcemanager_folder" "this" {
  name = var.folder_name
}

resource "yandex_serverless_container" "atlantis" {
  name              = "atlantis"
  description       = "Atlantis for Terraform Pull Request Automation"
  folder_id         = local.folder_id
  memory            = var.memory
  execution_timeout = var.execution_timeout
  cores             = var.cores
  core_fraction     = var.core_fraction

  service_account_id = yandex_iam_service_account.atlantis-sa.id

  image {
    url  = "cr.yandex/${yandex_container_repository.atlantis.name}:latest"
    args = ["server", "--atlantis-url=https://bba3jrl76qrmtbq80v8i.containers.yandexcloud.net/", "--gh-user=${local.gh_user}", "--gh-token=${local.gh_token}", "--gh-webhook-secret=${local.webhook_secret}", "--repo-allowlist=iac-yandex"]
    //command = ["/bin/sh", "-c", "while true; do sleep 1; done"]
    #    environment = {
    #      ATLANTIS_GH_USER           = local.gh_user
    #      ATLANTIS_GH_TOKEN          = local.gh_token
    #      ATLANTIS_GH_WEBHOOK_SECRET = local.webhook_secret
    #    }
  }
}

resource "yandex_container_registry" "this" {
  name      = "registry"
  folder_id = local.folder_id
}

resource "yandex_container_repository" "atlantis" {
  name = "${yandex_container_registry.this.id}/atlantis"

  provisioner "local-exec" {
    command = "docker pull ghcr.io/runatlantis/atlantis && docker tag ghcr.io/runatlantis/atlantis cr.yandex/${yandex_container_repository.atlantis.name} && docker push cr.yandex/${yandex_container_repository.atlantis.name}:latest"
  }
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.this.id
  role        = "container-registry.images.puller"

  members = [
    "system:allUsers",
  ]
}

resource "yandex_iam_service_account" "atlantis-sa" {
  description = "Atlantis in serverless"
  name        = "atlantis"
  folder_id   = local.folder_id
}

resource "yandex_iam_service_account_iam_member" "atlantis-iam" {
  service_account_id = yandex_iam_service_account.atlantis-sa.id
  role               = "admin"
  member             = "serviceAccount:${yandex_iam_service_account.atlantis-sa.id}"
}

module "github-webhook" {
  source = "./modules/github-webhook"

  github_token = local.gh_token
  github_owner = "flowwow"

  atlantis_repo_allowlist = [
    "iac-yandex"
  ]

  webhook_url    = yandex_serverless_container.atlantis.url
  webhook_secret = local.webhook_secret
}
