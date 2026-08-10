variable "vpc_cidr" {
  description = "VPC의 전체 IP 대역"
  type        = string
  default     = "10.0.0.0/16"           # 아까 설계한 VPC 전체 대역
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