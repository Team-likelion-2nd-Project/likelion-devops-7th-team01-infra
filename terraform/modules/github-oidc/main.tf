# GitHub Actions OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub Actions OIDC의 공식 thumbprint (GitHub이 공개한 고정 값)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    Name    = "${var.project_name}-github-oidc"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# Backend 배포용 IAM Role — GitHub Actions에서 assume
resource "aws_iam_role" "github_actions_backend" {
  name = "${var.project_name}-github-actions-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.backend_repo}:ref:refs/heads/${var.deploy_branch}"
          }
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-github-actions-backend-role"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# ECR push 권한
resource "aws_iam_role_policy" "ecr_push" {
  name = "${var.project_name}-ecr-push-policy"
  role = aws_iam_role.github_actions_backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

# EKS 배포 권한 (kubectl 접근용 — 클러스터 describe + Access Entry는 별도)
resource "aws_iam_role_policy" "eks_deploy" {
  name = "${var.project_name}-eks-deploy-policy"
  role = aws_iam_role.github_actions_backend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = var.eks_cluster_arn
      }
    ]
  })
}