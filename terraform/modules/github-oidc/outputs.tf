output "role_arn" {
  value = aws_iam_role.github_actions_frontend.arn
}

output "backend_role_arn" {
  value = aws_iam_role.github_actions_backend.arn
}