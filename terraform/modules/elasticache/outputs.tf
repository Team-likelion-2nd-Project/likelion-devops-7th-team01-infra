output "redis_endpoint" {
  description = "Redis 엔드포인트 (host) — 백엔드 앱에서 접속 시 사용"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis 포트"
  value       = aws_elasticache_cluster.main.cache_nodes[0].port
}

output "redis_cluster_id" {
  description = "ElastiCache 클러스터 식별자"
  value       = aws_elasticache_cluster.main.cluster_id
}