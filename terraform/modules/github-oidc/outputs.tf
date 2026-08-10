output "github_actions_role_arn" {
  description = "GitHub Actions가 assume할 IAM Role ARN — GitHub Secrets/워크플로우에 설정 필요"
  value       = aws_iam_role.github_actions_backend.arn
}

output "oidc_provider_arn" {
  description = "GitHub Actions OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}