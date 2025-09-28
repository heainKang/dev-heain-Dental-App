# DentalNow App - AI 컨텍스트 파일

## 프로젝트 개요
치과 의료진과 병원을 연결하는 매칭 플랫폼입니다.

## 기술 스택
- **Backend**: Ruby on Rails 8.0.2
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Authorization**: Pundit
- **Frontend**: Tailwind CSS
- **Geocoding**: Geocoder gem
- **Background Jobs**: Solid Queue (이미 포함됨)

## 주요 모델
- **User**: 사용자 (jobseeker, hospital, admin 역할)
- **Hospital**: 병원 정보 (geocoding 지원)
- **Job**: 일자리 정보
- **Matching**: 지원자와 일자리 매칭
- **Profile**: 구직자 프로필
- **Review**: 리뷰 시스템

## Rails 8 특이사항
- **Enum 문법**: `enum :status, { active: 1 }` 형태로 변경됨
- **CSS 로딩**: application.erb에서 `:app`으로 로드해야 action text CSS 포함

## 개발 참고사항
### CSS 및 디자인
- Tailwind CSS 기반으로 모든 디자인 구현
- 대시보드는 컴팩트하게, 스크롤 없이 한눈에 볼 수 있게 설계
- application.erb에서 `stylesheet_link_tag :app` 사용

### 권장 추가 gem 목록
- `rails_icons`: Tabler 아이콘 사용
- `resend`: 이메일 발송
- `exception_notification`: 오류 알림

### 보안
- Rails credentials 사용 (master.key는 gitignore에 포함)
- `.env` 대신 `rails credentials:edit` 사용

## 현재 상태
- 서버 정상 실행 중 (Rails 8 enum 문법 수정 완료)
- 기본 모델 및 관계 설정 완료
- Devise, Pundit, Geocoder 설치 완료
- 데이터베이스 마이그레이션 완료

## 다음 작업
1. 추가 gem 설치
2. CSS 로딩 방식 개선
3. 홈페이지 및 대시보드 UI 개선