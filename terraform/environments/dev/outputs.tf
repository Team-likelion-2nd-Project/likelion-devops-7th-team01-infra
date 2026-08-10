output "aws_region" {
  description = "사용 중인 AWS 리전"      # 나중에 다른 모듈이나 팀원이 확인할 때 참고용
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

<<<<<<< HEAD
output "ecr_repository_url" {
  description = "Backend ECR 리포지토리 URL"
  value       = module.ecr.repository_url
}

=======
>>>>>>> 2c3b4c527458e17d595c2553cae321ab1e55f67f
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
<<<<<<< HEAD
}

output "eks_cluster_role_arn" {
  value = module.iam.eks_cluster_role_arn
}

output "eks_node_group_role_arn" {
  value = module.iam.eks_node_group_role_arn
=======
>>>>>>> 2c3b4c527458e17d595c2553cae321ab1e55f67f
}