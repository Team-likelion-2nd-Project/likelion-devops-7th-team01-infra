variable "vpc_id" {
  description = "보안그룹이 속할 VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC 전체 CIDR (내부 트래픽 허용 범위 계산용)"
  type        = string
}

variable "project_name" {
  description = "프로젝트 이름 (태깅용)"
  type        = string
}

variable "owner" {
  description = "리소스 소유자 (태깅용)"
  type        = string
}

variable "env" {
  description = "환경 구분 (태깅용)"
  type        = string
}

