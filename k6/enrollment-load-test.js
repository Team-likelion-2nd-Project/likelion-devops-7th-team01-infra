import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const enrollSuccessRate = new Rate('enroll_success_rate');
const enrollDuration = new Trend('enroll_duration');

const BASE_URL = __ENV.BASE_URL || 'http://k8s-default-backendi-89c25e9e8b-1992645647.ap-northeast-3.elb.amazonaws.com';
const MAX_VUS = parseInt(__ENV.MAX_VUS) || 300;
const POPULAR_COURSE_ID = __ENV.POPULAR_COURSE_ID || '1';
const POPULAR_COURSE_RATIO = parseFloat(__ENV.POPULAR_COURSE_RATIO) || 0.7;
const JWT_TOKEN = __ENV.JWT_TOKEN || '';

export const options = {
  stages: [
    { duration: '30s', target: Math.min(50, MAX_VUS) },
    { duration: '1m', target: Math.min(100, MAX_VUS) },
    { duration: '1m', target: Math.min(200, MAX_VUS) },
    { duration: '1m', target: MAX_VUS },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<3000'], // 콜드스타트 감안해서 여유 있게
  },
};

export default function () {
  const coursesRes = http.get(`${BASE_URL}/api/courses`);
  check(coursesRes, {
    '강의 목록 조회 200': (r) => r.status === 200,
  });

  sleep(Math.random() * 1 + 0.5);

  const studentId = `k6-vu-${__VU}-iter-${__ITER}`;
  const isPopular = Math.random() < POPULAR_COURSE_RATIO;
  const courseId = isPopular ? POPULAR_COURSE_ID : String(Math.ceil(Math.random() * 15));

  const enrollPayload = JSON.stringify({
    studentId: studentId,
    courseId: courseId,
  });

  const enrollRes = http.post(`${BASE_URL}/api/enrollments`, enrollPayload, {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${JWT_TOKEN}`,
    },
  });

  if (__ITER === 0 && __VU === 1) {
    console.log(`첫 요청 상태코드: ${enrollRes.status}, 응답: ${enrollRes.body}`);
  }

  check(enrollRes, {
    '신청 응답 받음 (200/400/401/409 중 하나)': (r) => [200, 400, 401, 409].includes(r.status),
  });

  enrollSuccessRate.add(enrollRes.status === 200);
  enrollDuration.add(enrollRes.timings.duration);

  sleep(Math.random() * 0.5 + 0.2);
}