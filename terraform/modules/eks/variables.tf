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

variable "private_subnet_ids" {
  description = "EKS 클러스터가 사용할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}