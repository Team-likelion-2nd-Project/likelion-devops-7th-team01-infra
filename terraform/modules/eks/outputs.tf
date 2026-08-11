output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS 클러스터 API 엔드포인트"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_arn" {
  description = "EKS 클러스터 ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_role_arn" {
  description = "EKS 클러스터 IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

output "cluster_certificate_authority_data" {
  description = "클러스터 인증서 데이터 (kubeconfig 구성 시 필요)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL — Pod Identity/IRSA 연동 시 사용"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}