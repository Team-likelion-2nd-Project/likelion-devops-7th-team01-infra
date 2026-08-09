# Terraform 작성 가이드

이 문서는 인프라(`infra`) 레포에서 Terraform 코드를 작성하거나 리뷰할 때 팀 전체가 따르는 기준을 정리한 문서입니다.

## 1. 모듈 구조 컨벤션

terraform/
├── environments/
│   └── dev/
│       ├── main.tf         # 모듈 호출 + provider 설정
│       ├── variables.tf    # 이 환경의 변수 정의
│       ├── outputs.tf      # 모듈 output을 상위로 노출
│       ├── backend.tf      # state 백엔드(S3+DynamoDB) 설정
│       └── terraform.tfvars.example  # 변수 값 예시 (실제 값은 .gitignore 처리)
└── modules/
    ├── vpc/
    ├── security-group/
    ├── iam/
    ├── ecr/
    ├── eks/    (M5에서 채울 예정)
    └── rds/    (M3에서 채울 예정)

- 각 모듈은 main.tf(리소스 정의), variables.tf(입력 변수), outputs.tf(출력 값) 3개 파일로 구성합니다.
- environments/dev/main.tf에서 각 모듈을 module "xxx" { source = "../../modules/xxx" ... } 형태로 호출합니다.
- 모듈 간 값 전달은 module.모듈이름.output이름 형태로 참조합니다. (예: module.vpc.vpc_id)

## 2. 네이밍 컨벤션

- 리소스 이름: ${var.project_name}-역할-용도 형태 (예: team01-course-registration-eks-nodes-sg)
- 변수명: snake_case 사용 (예: vpc_cidr, project_name)
- 브랜치명: feature/이름-이슈코드 (예: feature/youngchan-m1-4)

## 3. 태깅 규칙

모든 리소스에 아래 3개 태그를 필수로 포함합니다.

| 태그 | 값 | 설명 |
|---|---|---|
| Project | course-registration | 프로젝트 식별 |
| Owner | infra-team | 소유 팀 |
| Env | dev | 환경 구분 |

## 4. 변수 관리

- 공통 변수(project_name, owner, env 등)는 variables.tf에 정의합니다.
- 민감한 값(비밀번호, API 키 등)은 terraform.tfvars에 작성하고, 이 파일은 .gitignore로 커밋 대상에서 제외합니다.
- 팀원이 참고할 수 있도록 terraform.tfvars.example을 커밋해둡니다.

## 5. 버전 고정

main.tf에 아래와 같이 최소 버전을 명시합니다.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

## 6. PR 리뷰 체크리스트

PR을 올리거나 리뷰할 때 아래 항목을 확인합니다.

- [ ] 리소스에 태그 3종(Project/Owner/Env)이 모두 포함되어 있는가
- [ ] CIDR, 계정 ID 등 하드코딩된 값 대신 변수를 사용했는가
- [ ] 민감정보(비밀번호, 키 등)가 코드에 직접 포함되지 않았는가
- [ ] terraform plan 실행 결과에 에러가 없는가
- [ ] 보안그룹은 최소 권한 원칙(필요한 출처에서만 필요한 포트만 허용)을 지키는가

## 7. State 백엔드

- state는 S3(likelion-team01-tfstate-ap-northeast-3)에 저장하고, DynamoDB(likelion-team01-tfstate-lock)로 동시 작업 충돌을 방지합니다.
- 모든 팀원은 동일한 backend 설정을 공유하며, 별도 로컬 state 파일을 만들지 않습니다.