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

variable "private_subnet_ids" {
  description = "RDS를 배치할 프라이빗 서브넷 ID 목록 (최소 2개 AZ)"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "RDS에 적용할 보안그룹 ID (security-group 모듈의 rds_sg_id 출력값)"
  type        = string
}

variable "instance_class" {
  description = "RDS 인스턴스 사양"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "스토리지 크기 (GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "생성할 데이터베이스 이름"
  type        = string
  default     = "course_registration"
}

variable "db_username" {
  description = "마스터 사용자명"
  type        = string
  default     = "admin"
}