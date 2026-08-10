output "db_endpoint" {
  description = "RDS 엔드포인트 (host:port 형태) — 백엔드 앱에서 접속 시 사용"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "RDS 인스턴스 식별자"
  value       = aws_db_instance.main.id
}

output "db_name" {
  description = "생성된 데이터베이스 이름"
  value       = aws_db_instance.main.db_name
}

output "master_user_secret_arn" {
  description = "Secrets Manager에 저장된 마스터 유저 비밀정보의 ARN — 백엔드 파드가 EKS Pod Identity로 이 시크릿을 조회해서 DB 접속정보를 가져옴"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}