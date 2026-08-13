terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
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

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "ap-northeast-3"]
  }
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

module "cluster_autoscaler" {
  source = "../../modules/cluster-autoscaler"

  project_name = var.project_name
  owner        = var.owner
  env          = "dev"

  cluster_name = module.eks.cluster_name
}

resource "kubernetes_secret" "backend_rds" {
  metadata {
    name      = "backend-rds-secret"
    namespace = "default"
  }

  data = {
    DB_HOST     = split(":", module.rds.db_endpoint)[0]
    DB_PORT     = "3306"
    DB_NAME     = module.rds.db_name
    DB_USER = "admin"
    DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.rds_master.secret_string)["password"]
  }

  type = "Opaque"
}

data "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = module.rds.master_user_secret_arn
}

resource "aws_security_group_rule" "rds_from_eks_cluster_sg" { 
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.security_group.rds_sg_id
  source_security_group_id = "sg-08535928bf04e73ad"
  description               = "Allow MySQL from actual EKS cluster security group"
}