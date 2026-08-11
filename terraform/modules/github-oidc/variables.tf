variable "project_name" {
  description = "프로젝트 이름 (태그에 사용)"
  type        = string
}

variable "owner" {
  description = "리소스 소유 태그"
  type        = string
}

variable "env" {
  description = "환경 (dev/prod 등)"
  type        = string
}

variable "github_org" {
  description = "GitHub 조직 이름"
  type        = string
  default     = "Team-likelion-2nd-Project"
}

variable "backend_repo" {
  description = "백엔드 레포 이름"
  type        = string
  default     = "likelion-devops-7th-team01-backend"
}

variable "github_repo" {
  description = "프론트엔드 레포 이름"
  type        = string
}

variable "deploy_branch" {
  description = "백엔드 배포 대상 브랜치"
  type        = string
  default     = "main"
}

variable "ecr_repository_arn" {
  description = "ECR 리포지토리 ARN"
  type        = string
}

variable "eks_cluster_arn" {
  description = "EKS 클러스터 ARN"
  type        = string
}

variable "create_oidc_provider" {
  description = "OIDC Provider를 새로 생성할지 여부 (계정당 하나만 존재 가능)"
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "기존 OIDC Provider ARN (create_oidc_provider=false일 때 사용)"
  type        = string
  default     = ""
}

variable "s3_bucket_arn" {
  description = "프론트엔드 S3 버킷 ARN"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  type        = string
}