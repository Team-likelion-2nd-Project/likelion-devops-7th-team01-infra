# 수강신청 시스템 — Infra

수강신청 프로젝트의 인프라 저장소입니다. Terraform으로 AWS 리소스(VPC, EKS, RDS, ElastiCache, CloudFront 등)를 관리하고, Kustomize로 EKS manifest를 관리합니다. 모듈 구조와 설계 근거는 [Terraform Design (Wiki)](https://github.com/Team-likelion-2nd-Project/likelion-devops-7th-team01/wiki/Terraform-Design)을 참고하세요.

## 사전 준비물

- AWS CLI, Terraform, kubectl 설치
- IAM 사용자 자격 증명 + MFA 디바이스 등록 완료
- 설치 확인: `terraform -version`, `aws --version`, `kubectl version --client`

## 빠른 시작

```bash
git clone <저장소 주소>
cd <이 폴더>

# MFA 세션 발급 (12시간마다 갱신 필요)
aws sts get-session-token \
  --serial-number <MFA ARN> \
  --token-code <OTP 6자리>

export AWS_PROFILE=team01-mfa

cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

State는 S3 백엔드(`likelion-team01-tfstate-ap-northeast-3`)에 저장되며, lock으로 동시 작업 충돌을 방지합니다.

### K8s manifest 적용 (Kustomize)

```bash
kubectl apply -k k8s/overlays/dev
```

## 환경변수 / 프로필

| 항목 | 값 | 설명 |
|---|---|---|
| AWS 리전 | `ap-northeast-3` | 오사카. 지연시간, 서비스 안정성 고려해 선정 |
| AWS 계정 | `834922934330` | |
| Terraform 프로필 | `team01-mfa` | MFA 세션 발급 후 사용 |
| State 버킷 | `likelion-team01-tfstate-ap-northeast-3` | S3 백엔드 |

## 실행 확인

```bash
kubectl get pods
kubectl get hpa
```

`backend-*` 파드가 `Running` 상태, HPA가 `MINPODS 3 / MAXPODS 5`로 나오면 정상입니다.

```bash
kubectl logs -f <파드명>
```

## 동작 원리 — 알아두면 좋은 것

- **Pod Identity 우선**: 정적 액세스 키를 코드나 Secret에 두지 않고, IAM Role을 파드의 ServiceAccount에 직접 연결합니다(`cluster-autoscaler`, `alb-controller`, `ebs-csi-driver`, `grafana-cloudwatch` 모듈이 동일 패턴).
- **HPA**: CPU 40% 임계치, `minReplicas=3 / maxReplicas=5`. min=3은 무중단 요건과 동시 스파이크 대응력을 함께 고려해 확정한 값입니다.
- **커넥션 풀과 RDS 한도**: 백엔드 HikariCP `maximum-pool-size=15`이므로, 파드가 5개까지 늘어나면 이론상 최대 75개 커넥션이 필요할 수 있습니다. RDS(`db.t4g.micro`)의 `max_connections`는 60이라, 최대 부하 시 병목 지점이 될 수 있습니다 — 300명 부하테스트에서 실측 58까지 확인.
- **CloudFront가 프론트와 백엔드 트래픽을 함께 처리**: `/api/*`는 ALB(백엔드)로, 그 외는 S3(프론트 정적 파일)로 라우팅합니다. 프론트(HTTPS)와 ALB(HTTP) 사이의 Mixed Content를 CloudFront가 중계자 역할로 해결합니다.

## 자주 겪는 문제

**`terraform plan`에서 매번 같은 보안그룹 규칙이 변경 대상으로 뜸**

세 가지를 의심하세요.
1. 하드코딩된 리소스 ID가 실제 상태와 어긋났는지 (`grep`으로 SG ID 하드코딩 여부 확인)
2. 인라인 규칙과 별도 리소스가 같은 규칙을 이중으로 관리하고 있는지 (`modules/security-group/main.tf`의 인라인 규칙과 대조)
3. 데이터소스(`data.aws_eks_cluster...`)를 참조하는 `aws_security_group_rule`이 매번 재조회되며 불필요한 replace를 유발하는지

세 번째 경우, 삭제 전에 반드시 "이 규칙이 지금 유일한 통로인지" 반대 방향(ingress/egress) 규칙과 대조해서 확인하세요. 겉보기엔 비슷해도 방향이 다르면 별개 규칙입니다. 삭제가 위험하다고 판단되면 `lifecycle { ignore_changes = [...] }`로 봉합하는 것도 방법입니다.

```hcl
resource "aws_security_group_rule" "cluster_sg_from_nodes" {
  ...
  lifecycle {
    ignore_changes = [security_group_id]
  }
}
```

**AWS CLI 프로필이 의도한 것과 다르게 잡힘**

```bash
aws sts get-caller-identity --profile team01-mfa
```

로 현재 프로필이 정확한 계정(`834922934330`)을 가리키는지 항상 먼저 확인하세요. 다른 프로필(예: 학생 계정)이 기본으로 잡혀있는 경우가 있습니다.

**MFA 세션이 만료됨 (`ExpiredToken`)**

세션은 12시간마다 만료됩니다. `aws sts get-session-token`을 다시 실행해 재발급하세요.

**워커노드가 AWS API에 접근하지 못함**

NAT 인스턴스로 구성했을 때 IP forwarding/iptables 설정 실수로 발생했던 이력이 있습니다. 관리형 NAT Gateway로 교체되어 있는지(`terraform/modules/vpc`) 확인하세요.

## 폴더 구조

```
.
├── terraform/
│   ├── environments/dev/     # 모듈을 조립하는 진입점
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       ├── iam/
│       ├── security-group/
│       ├── rds/
│       ├── elasticache/
│       ├── cognito/
│       ├── frontend-hosting/
│       ├── ecr/
│       ├── github-oidc/
│       ├── cluster-autoscaler/
│       ├── alb-controller/
│       ├── ebs-csi-driver/
│       ├── grafana-cloudwatch/
│       └── billing-alarm/
├── k8s/
│   ├── base/                 # HPA, PDB, Deployment 등 기본 manifest
│   └── overlays/dev/         # 환경별 오버레이
└── k6/                       # 부하테스트 시나리오
```

## 향후 개선 과제

- **HikariCP `minimum-idle` 최적화**: 현재 `minimum-idle=15`가 `maximum-pool-size`와 동일해, 평상시에도 파드 3개 × 15 = 45개 커넥션이 상시 점유됩니다(RDS 한도 대비 75%). `minimum-idle`을 5~8 수준으로 낮추는 방향을 검토할 수 있으나 재검증 필요.
- **`aws_security_group_rule` → `aws_vpc_security_group_ingress_rule` 마이그레이션**: 반복 replace 문제의 근본 해결 가능성.
- **RDS 인스턴스 확장**: 더 큰 트래픽 대응 시 `db.t4g.micro` 상위 인스턴스로 확장 필요.

## 관련 문서

- [Terraform Design](https://github.com/Team-likelion-2nd-Project/likelion-devops-7th-team01/wiki/Terraform-Design)
- [System Architecture](https://github.com/Team-likelion-2nd-Project/likelion-devops-7th-team01/wiki/System-Architecture)
