output "eks_cluster_role_arn" {
  description = "EKS 클러스터용 IAM Role ARN"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  description = "EKS 노드그룹용 IAM Role ARN"
  value       = aws_iam_role.eks_node_group.arn
}