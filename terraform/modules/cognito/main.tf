# Cognito User Pool (회원가입/로그인 관리)
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"

  # 이메일로 로그인
  username_attributes = ["email"]

  # 이메일 인증 필수
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = false
  }

  tags = {
    Name    = "${var.project_name}-user-pool"
    Project = var.project_name
    Owner   = var.owner
    Env     = var.env
  }
}

# App Client (프론트엔드 React 앱에서 사용)
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # 프론트엔드(SPA)에서 직접 쓰는 클라이언트라 시크릿 발급 안 함
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}