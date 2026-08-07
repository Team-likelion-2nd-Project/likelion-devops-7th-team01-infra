resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"   # 레포 이름 (예: team01-course-registration-backend)
  image_tag_mutability = "IMMUTABLE"                       # 같은 태그로 이미지 덮어쓰기 금지 (커밋 SHA 태그 정책과 맞춤)

  image_scanning_configuration {
    scan_on_push = true                                    # 이미지 push할 때마다 자동으로 취약점 스캔
  }

  tags = {
    Name    = "${var.project_name}-backend-ecr"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env                                       # 아까 얘기한 Env 태그 여기서부터 바로 반영
  }
}