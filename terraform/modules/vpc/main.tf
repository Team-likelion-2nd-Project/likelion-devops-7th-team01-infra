resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# 퍼블릭 서브넷 (ALB용)
resource "aws_subnet" "public" {
  for_each = {
    "a" = { cidr = "10.0.1.0/24", az = "ap-northeast-3a" }
    "c" = { cidr = "10.0.2.0/24", az = "ap-northeast-3c" }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block               = each.value.cidr
  availability_zone        = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-${each.key}"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# 프라이빗 서브넷 (EKS/RDS/Redis용)
resource "aws_subnet" "private" {
  for_each = {
    "a" = { cidr = "10.0.11.0/24", az = "ap-northeast-3a" }
    "c" = { cidr = "10.0.12.0/24", az = "ap-northeast-3c" }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name    = "${var.project_name}-private-${each.key}"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway용 고정 IP (Elastic IP)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "${var.project_name}-nat-eip"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# NAT Gateway (AWS 관리형 — forwarding 설정 신경 불필요)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["a"].id

  tags = {
    Name    = "${var.project_name}-nat-gw"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }

  depends_on = [aws_internet_gateway.main]
}

# 프라이빗 라우팅 테이블 (외부로 나가는 트래픽을 NAT Gateway로 보냄)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-private-rt"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}