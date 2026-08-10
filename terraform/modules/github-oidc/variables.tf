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

variable "deploy_branch" {
  description = "배포 대상 브랜치"
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