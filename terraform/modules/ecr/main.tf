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

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최근 10개 이미지만 유지, 나머지는 자동 삭제"
        selection = {
          tagStatus     = "any"          # 태그 있든 없든 상관없이 적용
          countType     = "imageCountMoreThan"
          countNumber   = 10               # 10개 넘으면 오래된 것부터 삭제
        }
        action = {
          type = "expire"                 # 조건에 맞으면 삭제
        }
      }
    ]
  })
}