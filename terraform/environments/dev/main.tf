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
  region = var.aws_region               # 리전은 하드코딩 안 하고 변수로 받음 (오사카로 값 넣을 예정)
}

module "vpc" {
  source = "../../modules/vpc"            # vpc 모듈 코드가 있는 경로 (상대경로)

  vpc_cidr     = "10.0.0.0/16"             # vpc 모듈의 variables.tf에서 받는 값 전달
  project_name = var.project_name           # 이 환경(dev)의 variables.tf에 이미 정의된 값 재사용
  owner        = var.owner
}

module "security_group" {
  source = "../../modules/security-group"

  vpc_id       = module.vpc.vpc_id      # vpc 모듈의 output을 그대로 가져다 씀
  vpc_cidr     = "10.0.0.0/16"           # VPC 모듈 만들 때 썼던 것과 동일한 값
  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}