output "repository_url" {
  description = "ECR 리포지토리 URL (이미지 push/pull 시 사용)"
  value       = aws_ecr_repository.backend.repository_url
}

output "repository_arn" {
  description = "ECR 리포지토리 ARN (IAM 정책 등에서 참조 시 사용)"
  value       = aws_ecr_repository.backend.arn
}