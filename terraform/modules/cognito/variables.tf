variable "project_name" {
  description = "프로젝트 이름 (태그/리소스명에 사용)"
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