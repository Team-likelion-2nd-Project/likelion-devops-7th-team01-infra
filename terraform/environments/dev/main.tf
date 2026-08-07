terraform {
  required_version = ">= 1.5.0"        # 팀원들이 다른 terraform 버전 써도 최소 버전은 맞추게 강제

  required_providers {
    aws = {
      source  = "hashicorp/aws"        # AWS 리소스를 다루기 위한 공식 provider 사용 선언
      version = "~> 5.0"                # 5.x 버전대 사용 (호환성 문제 방지)
    }
  }
}

provider "aws" {
  region = var.aws_region               # 리전은 하드코딩 안 하고 변수로 받음
}