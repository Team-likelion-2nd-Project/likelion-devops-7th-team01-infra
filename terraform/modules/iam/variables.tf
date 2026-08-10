variable "project_name" {
  description = "프로젝트 이름 (태깅 및 role명 접두사)"
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