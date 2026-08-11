output "aws_region" {
  description = "사용 중인 AWS 리전"
  value       = var.aws_region
}

output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "Backend ECR 리포지토리 URL"
  value       = module.ecr.repository_url
}

output "eks_nodes_sg_id" {
  value = module.security_group.eks_nodes_sg_id
}

output "rds_sg_id" {
  value = module.security_group.rds_sg_id
}

output "redis_sg_id" {
  value = module.security_group.redis_sg_id
}

output "alb_sg_id" {
  value = module.security_group.alb_sg_id
}

output "eks_cluster_role_arn" {
  value = module.iam.eks_cluster_role_arn
}

output "eks_node_group_role_arn" {
  value = module.iam.eks_node_group_role_arn
}

output "billing_alarm_sns_topic_arn" {
  value = module.billing_alarm.sns_topic_arn
}

output "billing_alarm_name" {
  value = module.billing_alarm.alarm_name
}

output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value       = module.rds.db_endpoint
}

output "rds_db_name" {
  description = "RDS 데이터베이스 이름"
  value       = module.rds.db_name
}

output "rds_master_user_secret_arn" {
  description = "RDS 마스터 계정 Secrets Manager ARN"
  value       = module.rds.master_user_secret_arn
}

output "redis_endpoint" {
  description = "Redis 엔드포인트"
  value       = module.elasticache.redis_endpoint
}

output "redis_port" {
  description = "Redis 포트"
  value       = module.elasticache.redis_port
}

output "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_role_arn_new" {
  description = "EKS 클러스터 IAM Role ARN (신규, team01-eks-cluster-role)"
  value       = module.eks.cluster_role_arn
}

output "eks_oidc_issuer_url" {
  description = "EKS OIDC issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}