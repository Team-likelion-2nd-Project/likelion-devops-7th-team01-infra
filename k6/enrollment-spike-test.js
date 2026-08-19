import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const enrollDuration = new Trend('enroll_duration');
const enrollSuccessRate = new Rate('enroll_success_rate');

const BASE_URL = __ENV.BASE_URL || 'http://k8s-default-backendi-89c25e9e8b-1992645647.ap-northeast-3.elb.amazonaws.com';
const MAX_VUS = parseInt(__ENV.MAX_VUS) || 300;
const POPULAR_COURSE_ID = __ENV.POPULAR_COURSE_ID || '1';
const JWT_TOKEN = __ENV.JWT_TOKEN || '';

export const options = {
  stages: [
    { duration: '5s', target: MAX_VUS },   // 정각 오픈처럼 순식간에 몰림
    { duration: '2m', target: MAX_VUS },   // 몰린 상태 유지
    { duration: '10s', target: 0 },        // 종료
  ],
  thresholds: {
    http_req_duration: ['p(95)<15000'],
  },
};

const authHeaders = {
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${JWT_TOKEN}`,
  },
};

export default function () {
  // 정각 오픈 상황이니, 다들 미리 강의 목록 페이지에서 대기 중이었다고 가정
  // -> 목록 조회는 생략하고, 바로 인기 강의 신청부터 시작
  const studentId = `k6-spike-vu-${__VU}-iter-${__ITER}`;
  const payload = JSON.stringify({ studentId, courseId: POPULAR_COURSE_ID });

  const res = http.post(`${BASE_URL}/api/enrollments`, payload, authHeaders);

  check(res, {
    '신청 응답 받음 (200/400/401/409)': (r) => [200, 400, 401, 409].includes(r.status),
  });

  enrollSuccessRate.add(res.status === 200);
  enrollDuration.add(res.timings.duration);

  sleep(0.1);
}