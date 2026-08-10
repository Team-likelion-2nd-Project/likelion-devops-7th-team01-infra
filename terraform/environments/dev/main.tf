terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = "10.0.0.0/16"
  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}

module "security_group" {
  source = "../../modules/security-group"

  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = "10.0.0.0/16"
  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}

module "billing_alarm" {
  source = "../../modules/billing-alarm"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  project_name      = var.project_name
  owner             = var.owner
  env               = "dev"
  alert_email       = var.alert_email
  billing_threshold = 60
}