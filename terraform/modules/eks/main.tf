# EKS 클러스터용 IAM Role
resource "aws_iam_role" "cluster" {
  name = "team01-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "team01-eks-cluster-role"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "main" {
  name     = "team01-course-registration-eks"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.36"

  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  zonal_shift_config {
    enabled = false
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}


# EKS 노드그룹
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-ng"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  tags = {
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}