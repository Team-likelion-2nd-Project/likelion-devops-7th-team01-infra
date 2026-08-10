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
  description = "Redis를 배치할 프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "redis_sg_id" {
  description = "Redis에 적용할 보안그룹 ID (security-group 모듈의 redis_sg_id 출력값)"
  type        = string
}

variable "node_type" {
  description = "ElastiCache 노드 사양"
  type        = string
  default     = "cache.t4g.micro"
}