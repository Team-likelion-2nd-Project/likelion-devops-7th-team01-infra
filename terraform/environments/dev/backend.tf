# state 백엔드 설정은 이용민님(M1-2)이 S3+DynamoDB 만든 후 채울 예정
# terraform {
#   backend "s3" {
#     bucket         = "team01-terraform-state"
#     key            = "dev/terraform.tfstate"
#     region         = "ap-northeast-3"
#     dynamodb_table = "team01-terraform-lock"
#   }
# }

terraform {
  backend "s3" {
    bucket         = "likelion-team01-tfstate-ap-northeast-3" # S3 버킷명
    key            = "dev/terraform.tfstate"                  # S3 내부 저장 경로
    region         = "ap-northeast-3"                         # 오사카 리전
    encrypt        = true
    dynamodb_table = "likelion-team01-tfstate-lock"           # DynamoDB 테이블명
  }
}