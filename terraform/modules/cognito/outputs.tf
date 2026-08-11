output "user_pool_id" {
  description = "Cognito User Pool ID — 백엔드 JWT 검증 시 사용"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_client_id" {
  description = "Cognito App Client ID — 프론트엔드 로그인 연동 시 사용"
  value       = aws_cognito_user_pool_client.main.id
}