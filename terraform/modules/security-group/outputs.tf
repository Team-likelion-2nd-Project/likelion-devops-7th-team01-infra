output "eks_nodes_sg_id" {
  description = "EKS 워커노드용 보안그룹 ID"
  value       = aws_security_group.eks_nodes.id
}

output "rds_sg_id" {
  description = "RDS용 보안그룹 ID"
  value       = aws_security_group.rds.id
}

output "redis_sg_id" {
  description = "Redis(ElastiCache)용 보안그룹 ID"
  value       = aws_security_group.redis.id
}

output "alb_sg_id" {
  description = "ALB용 보안그룹 ID"
  value       = aws_security_group.alb.id
}