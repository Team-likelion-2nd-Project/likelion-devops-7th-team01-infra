variable "aws_region" {
  description = "AWS 리전"              # 이 변수가 뭘 위한 건지 설명 (팀원이 봐도 이해되게)
  type        = string                  # 값의 타입은 문자열
  default     = "ap-northeast-3"        # 기본값: 오사카 리전 (강사님 확인되면 그대로 유지)
}

variable "project_name" {
  description = "프로젝트 이름 (태깅용)"
  type        = string
  default     = "team01-course-registration"   # 리소스 태그에 쓸 프로젝트명
}

variable "owner" {
  description = "리소스 소유자 (태깅용)"
  type        = string
  default     = "infra-team"
}

variable "alert_email" {
  description = "비용 알림을 받을 이메일 주소"
  type        = string
}