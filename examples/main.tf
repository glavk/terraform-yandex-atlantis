provider "yandex" {
  zone     = "ru-central1-a"
  cloud_id = "xxx"
}

module "atlantis-github" {
  source      = "../"
  folder_name = "dev"
}
