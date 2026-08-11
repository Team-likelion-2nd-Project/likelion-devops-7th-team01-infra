output "github_actions_role_arn" {
  description = "Backend GitHub Actions가 assume할 IAM Role ARN"
  value       = aws_iam_role.github_actions_backend.arn
}

output "oidc_provider_arn" {
  description = "GitHub Actions OIDC Provider ARN"
  value       = local.oidc_provider_arn
}

output "role_arn" {
  description = "Frontend GitHub Actions가 assume할 IAM Role ARN"
  value       = aws_iam_role.github_actions_frontend.arn
}