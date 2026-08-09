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

variable "alert_email" {
  description = "비용 알림을 받을 이메일 주소"
  type        = string
}

variable "billing_threshold" {
  description = "주간 비용 알림 임계값 (USD 기준, 약 8만원)"
  type        = number
  default     = 60
}