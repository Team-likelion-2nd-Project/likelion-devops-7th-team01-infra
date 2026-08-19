import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const enrollDuration = new Trend('enroll_duration');
const failRate = new Rate('real_fail_rate'); // 진짜 실패(timeout, 5xx)만 추적

const BASE_URL = __ENV.BASE_URL || 'http://k8s-default-backendi-89c25e9e8b-1992645647.ap-northeast-3.elb.amazonaws.com';
const JWT_TOKEN = __ENV.JWT_TOKEN || '';

export const options = {
  stages: [
    { duration: '30s', target: 100 },
    { duration: '30s', target: 300 },
    { duration: '30s', target: 600 },
    { duration: '30s', target: 1000 },
    { duration: '30s', target: 1500 },
    { duration: '30s', target: 2000 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    // 진짜 실패율이 5%를 넘는 순간 테스트 자동 중단
    real_fail_rate: [{ threshold: 'rate<0.05', abortOnFail: true }],
  },
};

const authHeaders = {
  headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${JWT_TOKEN}` },
};

export default function () {
  const studentId = `k6-stress-vu-${__VU}-iter-${__ITER}`;
  const courseId = String(Math.ceil(Math.random() * 15));

  const res = http.post(`${BASE_URL}/api/enrollments`, JSON.stringify({ studentId, courseId }), authHeaders);

  // 진짜 실패만 정확히 판정: 응답 자체가 없거나(status 0) 서버 에러(5xx)일 때만
  const isRealFailure = res.status === 0 || res.status >= 500;

  check(res, { '응답 받음': (r) => r.status !== 0 });
  failRate.add(isRealFailure);
  enrollDuration.add(res.timings.duration);

  if (__ITER < 3) {
    console.log(`상태코드: ${res.status}, 응답: ${res.body}`);
  }

  sleep(0.1);
}