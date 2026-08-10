# DB 서브넷 그룹 — RDS가 어느 서브넷들에 위치할지 지정 (최소 2개 AZ 필요)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# RDS 인스턴스 (MySQL)
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type       = "gp3"
  storage_encrypted  = true

  db_name  = var.db_name
  username = var.db_username

  # 마스터 계정 비밀번호를 AWS가 자동 생성해서 Secrets Manager에 저장
  # (이슈 체크박스: "마스터 계정 정보를 Secrets Manager에 저장, 콘솔에 하드코딩 금지")
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]

  multi_az            = false
  publicly_accessible = false

  skip_final_snapshot = true
  deletion_protection = false

  backup_retention_period = 1

  tags = {
    Name    = "${var.project_name}-db"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}