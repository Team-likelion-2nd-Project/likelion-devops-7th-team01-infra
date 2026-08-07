# state 백엔드 설정은 이용민님(M1-2)이 S3+DynamoDB 만든 후 채울 예정
# terraform {
#   backend "s3" {
#     bucket         = "team01-terraform-state"
#     key            = "dev/terraform.tfstate"
#     region         = "ap-northeast-3"
#     dynamodb_table = "team01-terraform-lock"
#   }
# }