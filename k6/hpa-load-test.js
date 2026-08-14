// hpa-load-test.js
//
// M9-4 — HPA(오토스케일링) 데모 시연용 표준 부하테스트 시나리오.
// 50명 가상 사용자 부하에서 backend 파드가 1개 -> 3개로 스케일아웃되는 것을
// 3회 반복 실측 검증함 (Grafana "Team01 Backend Monitoring" 대시보드에서 확인).
//
// 실행 전 확인:
// - 대상은 실제 EKS ALB 주소 (로컬 Docker Compose 백엔드가 아님 -
//   로컬에 걸어도 HPA는 반응하지 않음, 실제 EKS 클러스터의 CPU 메트릭만 봄)
// - kubectl get hpa -w 로 REPLICAS 변화를 함께 관찰할 것

import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // 1분 동안 서서히 50명까지 증가
    { duration: '3m', target: 50 },   // 50명 부하 3분간 유지 (HPA 반응 관찰 구간)
    { duration: '1m', target: 0 },    // 1분 동안 서서히 감소
  ],
};

export default function () {
  http.get('http://k8s-default-backendi-89c25e9e8b-1992645647.ap-northeast-3.elb.amazonaws.com/api/courses');
  sleep(0.1);
}
