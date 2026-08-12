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

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  owner        = var.owner
  env          = "dev"

  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id           = module.security_group.rds_sg_id
}

module "elasticache" {
  source = "../../modules/elasticache"

  project_name = var.project_name
  owner        = var.owner
  env          = "dev"

  private_subnet_ids = module.vpc.private_subnet_ids
  redis_sg_id         = module.security_group.redis_sg_id
}

module "eks" {
  source = "../../modules/eks"
  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_group_role_arn = module.iam.eks_node_group_role_arn
}

module "cognito" {
  source = "../../modules/cognito"
  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}

module "frontend_hosting" {
  source = "../../modules/frontend-hosting"

  project_name = var.project_name
  owner        = var.owner
  env          = "dev"
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  create_oidc_provider       = false
  existing_oidc_provider_arn = "arn:aws:iam::834922934330:oidc-provider/token.actions.githubusercontent.com"

  github_org  = "Team-likelion-2nd-Project"
  github_repo = "likelion-devops-7th-team01-frontend"

  s3_bucket_arn                = module.frontend_hosting.s3_bucket_arn
  cloudfront_distribution_arn  = module.frontend_hosting.cloudfront_distribution_arn

  github_backend_repo = "likelion-devops-7th-team01-backend"
  ecr_repository_arn  = module.ecr.repository_arn
  eks_cluster_arn     = module.eks.cluster_arn
}

resource "aws_eks_access_entry" "backend_cicd" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_oidc.backend_role_arn
}

resource "aws_eks_access_policy_association" "backend_cicd" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_oidc.backend_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "cluster"
  }
}