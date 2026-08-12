variable "create_oidc_provider" {
  type    = bool
  default = true
}

variable "existing_oidc_provider_arn" {
  type    = string
  default = ""
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "cloudfront_distribution_arn" {
  type = string
}

variable "github_backend_repo" {
  type = string
}

variable "ecr_repository_arn" {
  type = string
}

variable "eks_cluster_arn" {
  type = string
}