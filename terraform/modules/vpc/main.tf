resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr        # VPC 전체 IP 대역 (10.0.0.0/16)
  enable_dns_support   = true                # VPC 안에서 DNS 조회 가능하게 함 (RDS 엔드포인트 등에 필요)
  enable_dns_hostnames = true                # 인스턴스에 자동으로 DNS 호스트명 부여

  tags = {
    Name    = "${var.project_name}-vpc"      # 리소스 이름 태그 (콘솔에서 구분용)
    Project = var.project_name                # 프로젝트 태그 (계획서 6번 규칙)
    Owner   = var.owner                        # 소유자 태그
  }
}

# 퍼블릭 서브넷 (ALB용)
resource "aws_subnet" "public" {
  for_each = {                                  # 반복문 — 여러 개의 비슷한 리소스를 한번에 정의할 때 씀
    "a" = { cidr = "10.0.1.0/24", az = "ap-northeast-3a" }
    "c" = { cidr = "10.0.2.0/24", az = "ap-northeast-3c" }
  }

  vpc_id                  = aws_vpc.main.id     # 위에서 만든 VPC에 소속시킴
  cidr_block               = each.value.cidr     # 각 서브넷의 IP 대역
  availability_zone        = each.value.az        # 각 서브넷이 위치할 가용영역
  map_public_ip_on_launch = true                 # 이 서브넷에서 생성된 인스턴스는 자동으로 퍼블릭 IP 받음

  tags = {
    Name    = "${var.project_name}-public-${each.key}"
    Project = var.project_name
    Owner   = var.owner
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
  # map_public_ip_on_launch 없음 = 기본값 false → 퍼블릭 IP 자동 부여 안 됨

  tags = {
    Name    = "${var.project_name}-private-${each.key}"
    Project = var.project_name
    Owner   = var.owner
  }
}

# 인터넷 게이트웨이 (VPC가 외부 인터넷과 통신하는 통로)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
    Owner   = var.owner
  }
}

# 퍼블릭 라우팅 테이블 (0.0.0.0/0 트래픽을 IGW로 보냄)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                   # 모든 외부 트래픽
    gateway_id = aws_internet_gateway.main.id   # IGW로 내보냄
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
    Owner   = var.owner
  }
}

# 퍼블릭 서브넷들을 방금 만든 라우팅 테이블에 연결
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public                 # 위에서 만든 퍼블릭 서브넷 2개 각각에 대해 반복

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT 인스턴스용 보안그룹 (프라이빗 서브넷에서 오는 트래픽만 허용)
resource "aws_security_group" "nat" {
  name_prefix = "${var.project_name}-nat-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all traffic from private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                          # 모든 프로토콜
    cidr_blocks = [var.vpc_cidr]                 # VPC 내부에서만 (10.0.0.0/16)
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-nat-sg"
    Project = var.project_name
    Owner   = var.owner
  }
}

# 최신 Amazon Linux 2023 AMI 자동 조회 (하드코딩 방지 — 리전/시점마다 AMI ID가 다르기 때문)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]      # t4g는 ARM 아키텍처라 arm64 이미지 필요
  }
}

# NAT 인스턴스 (프라이빗 서브넷의 아웃바운드 트래픽을 대신 내보내는 역할)
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t4g.nano"                # 계획서에 정해둔 사양
  subnet_id                   = aws_subnet.public["a"].id  # 퍼블릭 서브넷에 위치해야 함 (외부와 통신하려면)
  vpc_security_group_ids      = [aws_security_group.nat.id]
  source_dest_check           = false                       # NAT 역할 하려면 반드시 꺼야 함 (자기 목적지 아닌 트래픽도 전달해야 하므로)
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-nat-instance"
    Project = var.project_name
    Owner   = var.owner
  }
}

# 프라이빗 라우팅 테이블 (외부로 나가는 트래픽을 NAT 인스턴스로 보냄)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id   # NAT 인스턴스의 기본 네트워크 인터페이스를 가리킴
  }

  tags = {
    Name    = "${var.project_name}-private-rt"
    Project = var.project_name
    Owner   = var.owner
  }
}

# 프라이빗 서브넷들을 방금 만든 라우팅 테이블에 연결
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}