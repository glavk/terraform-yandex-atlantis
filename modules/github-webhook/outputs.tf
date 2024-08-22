output "github_webhook_urls" {
  description = "GitHub webhook URL"
  value       = github_repository_webhook.this.*.url
}

output "github_webhook_secret" {
  description = "GitHub webhook secret"
  value       = var.webhook_secret
  sensitive   = true
}