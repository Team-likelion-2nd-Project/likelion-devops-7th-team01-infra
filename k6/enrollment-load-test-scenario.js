import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const enrollDuration = new Trend('enroll_duration');
const enrollSuccessRate = new Rate('enroll_success_rate');

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
  // 모든 사용자 공통: 강의 목록 조회 (사이트 들어오면 제일 먼저 보는 화면)
  const coursesRes = http.get(`${BASE_URL}/api/courses`);
  check(coursesRes, { '강의 목록 조회 200': (r) => r.status === 200 });
  sleep(Math.random() * 1 + 0.3);

  // 사용자 행동을 확률로 분기 — 다양한 행동 재현
  const rand = Math.random();

  if (rand < 0.5) {
    // 50%: 인기 강의로 몰리는 전형적인 "오픈런" 사용자
    tryEnroll(POPULAR_COURSE_ID);

  } else if (rand < 0.8) {
    // 30%: 아무 강의나 신청하는 일반 사용자
    const courseId = String(Math.ceil(Math.random() * 15));
    tryEnroll(courseId);

  } else if (rand < 0.9) {
    // 10%: 신청 안 하고 시간표만 확인하는 사용자 (관망형)
    const timetableRes = http.get(`${BASE_URL}/api/timetable`, authHeaders);
    check(timetableRes, {
      '시간표 조회 200/401': (r) => [200, 401].includes(r.status),
    });

  } else {
    // 10%: 신청 후 바로 취소하는 변덕형 사용자
    const courseId = String(Math.ceil(Math.random() * 15));
    const enrollmentId = tryEnroll(courseId);
    if (enrollmentId) {
      sleep(0.3);
      const cancelRes = http.del(`${BASE_URL}/api/enrollments/${enrollmentId}`, null, authHeaders);
      check(cancelRes, {
        '취소 응답 200/404': (r) => [200, 404].includes(r.status),
      });
    }
  }

  sleep(Math.random() * 0.5 + 0.2);
}

function tryEnroll(courseId) {
  const studentId = `k6-vu-${__VU}-iter-${__ITER}`;
  const payload = JSON.stringify({ studentId, courseId });

  const res = http.post(`${BASE_URL}/api/enrollments`, payload, authHeaders);

  console.log(`[신청] courseId=${courseId} status=${res.status} duration=${res.timings.duration}ms`);

  check(res, {
    '신청 응답 받음 (200/400/401/409)': (r) => [200, 400, 401, 409].includes(r.status),
  });

  enrollSuccessRate.add(res.status === 200);
  enrollDuration.add(res.timings.duration);

  if (res.status === 200) {
    return JSON.parse(res.body).enrollmentId;
  }
  return null;
}