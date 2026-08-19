import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const enrollDuration = new Trend('enroll_duration');
const enrollSuccessRate = new Rate('enroll_success_rate');

const BASE_URL = __ENV.BASE_URL || 'http://k8s-default-backendi-89c25e9e8b-1992645647.ap-northeast-3.elb.amazonaws.com';
const MAX_VUS = parseInt(__ENV.MAX_VUS) || 300;

const TEST_EMAIL = __ENV.TEST_EMAIL || 'k6test@example.com';
const TEST_PASSWORD = __ENV.TEST_PASSWORD || 'TestPass123!';
const COGNITO_URL = 'https://cognito-idp.ap-northeast-3.amazonaws.com/';
const CLIENT_ID = 'bbfrmvvt5q6rq95f6mgg0a9oh';

// 학과별 인기 과목 (courseId 기준, 예시: 실제 데이터에 맞게 조정 필요)
const POPULAR_COURSES_PER_DEPT = ['1', '4', '8', '10', '12']; // 학과마다 인기과목 1개씩
const ALL_COURSES = Array.from({ length: 15 }, (_, i) => String(i + 1));

// 테스트 시작 전 딱 한 번 실행 — 진짜 로그인해서 토큰 받아오기
export function setup() {
  const payload = JSON.stringify({
    AuthFlow: 'USER_PASSWORD_AUTH',
    ClientId: CLIENT_ID,
    AuthParameters: {
      USERNAME: TEST_EMAIL,
      PASSWORD: TEST_PASSWORD,
    },
  });

  const params = {
    headers: {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
    },
  };

  const res = http.post(COGNITO_URL, payload, params);

  if (res.status !== 200) {
    throw new Error(`로그인 실패: ${res.status} ${res.body}`);
  }

  const body = JSON.parse(res.body);
  const idToken = body.AuthenticationResult.IdToken;

  console.log('로그인 성공, 토큰 발급 완료');
  return { token: idToken };
}

export const options = {
  stages: [
    { duration: '5s', target: MAX_VUS },   // 정각 오픈처럼 순식간에 몰림
    { duration: '2m', target: MAX_VUS },   // 몰린 상태 유지
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<15000'],
  },
};

// setup()에서 받은 data(토큰)를 모든 가상 사용자가 공유해서 사용
export default function (data) {
  const authHeaders = {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${data.token}`,
    },
  };

  const studentId = `k6-vu-${__VU}`;

  // 신청 목록 만들기: 내 학과 인기과목 1개 + 나머지 5~6개 무작위
  const myPopular = POPULAR_COURSES_PER_DEPT[__VU % POPULAR_COURSES_PER_DEPT.length];
  const wishlist = [myPopular];
  while (wishlist.length < 6 + Math.round(Math.random())) { // 6~7개
    const candidate = ALL_COURSES[Math.floor(Math.random() * ALL_COURSES.length)];
    if (!wishlist.includes(candidate)) wishlist.push(candidate);
  }

  for (const courseId of wishlist) {
    const payload = JSON.stringify({ studentId, courseId });
    const res = http.post(`${BASE_URL}/api/enrollments`, payload, authHeaders);

    console.log(`courseId=${courseId} status=${res.status} body=${res.body}`);

    check(res, {
      '신청 응답 받음 (200/400/401/409)': (r) => [200, 400, 401, 409].includes(r.status),
    });
    
    enrollSuccessRate.add(res.status === 200);
    enrollDuration.add(res.timings.duration);

    sleep(Math.random() * 0.2 + 0.1);
  }
}