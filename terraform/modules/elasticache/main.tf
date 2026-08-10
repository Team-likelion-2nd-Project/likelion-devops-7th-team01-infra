# ElastiCache 서브넷 그룹 — Redis가 어느 서브넷들에 위치할지 지정
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "${var.project_name}-redis-subnet-group"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# ElastiCache Redis 클러스터
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.redis_sg_id]

  tags = {
    Name    = "${var.project_name}-redis"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}