# 시외버스 예약 앱 &nbsp;·&nbsp; [발표자료](https://minsung6167.github.io/Bus_app/)

Flutter 기반 시외버스 예약 모바일 앱 — 졸업 작품

---

## 소개

공공 API를 활용해 실제 시외버스 노선을 조회하고, 좌석을 선택해 예약할 수 있는 크로스 플랫폼 앱입니다.
한국어·영어·중국어·일본어 4개 언어를 지원하며, 내국인과 외국인 관광객 모두 이용 가능합니다.

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 터미널 검색 | 인기 TOP 10 / 지역별 / 즐겨찾기 3탭 제공 |
| 버스 목록 조회 | 공공 API 기반 실제 노선·시간표 |
| 혼잡도 예측 | 탑승률 기반 여유·보통·혼잡·매우혼잡 4단계 표시 |
| 좌석 선택 | 좌석 배치도 시각화, 모바일발권 안내 팝업 |
| 예약 확인 | 탑승인원·결제수단 선택, 예상 결제금액 표시 |
| 예매 내역 | 예약 목록 및 상세 조회, 계정별 영구 저장 |
| 지도 | 출발·도착 터미널 마커, 실제 도로 경로 및 소요시간 표시 |
| 수면 모드 | GPS 기반 목적지 도달 시 진동 알림 (백그라운드 실행) |
| 다국어 지원 | 한/영/중/일 실시간 전환 (챗봇 FAQ 포함) |
| 즐겨찾기 | 자주 이용하는 터미널 저장, 출발지 바로 선택 |
| 자주쓰는카드 | 결제 카드 등록·관리, 계정별 저장 |
| 쿠폰 | 쿠폰 등록 및 결제 시 자동 할인 적용 |
| 로그인 | 이메일 회원가입·로그인, 아이디/비밀번호 찾기, 계정별 데이터 분리 저장 |
| 고객센터 챗봇 | FAQ 자동응답 + 키워드 매칭 (4개 언어 지원) |

---

## 기술 스택

| 항목 | 내용 |
|---|---|
| 프레임워크 | Flutter 3.11.5 (Dart 3.x) |
| 상태 관리 | Provider + ChangeNotifier |
| 로컬 저장 | SharedPreferences |
| API | 공공데이터포털 시외버스 API |
| 플랫폼 | Android / iOS |

---

## 시작하기

```bash
git clone https://github.com/minsung6167/Bus_app.git
cd Bus_app
flutter pub get
flutter run
```

자세한 설치 방법 → [docs/setup.md](docs/setup.md)

---

## 프로젝트 구조

```
lib/
├── data/          # 로컬 샘플 데이터 (fallback)
├── l10n/          # 다국어 문자열
├── models/        # 데이터 모델
├── providers/     # 상태 관리
├── screens/       # 화면
├── services/      # API 서비스
├── theme/         # 앱 테마
└── widgets/       # 공통 위젯
docs/
├── ADR.md         # 아키텍처 결정 기록
├── setup.md       # 개발 환경 설정
└── testing.md     # 테스트 가이드
.planning/
├── 00-vision.md   # 비전·목표
├── 01-requirements.md  # 요구사항·MoSCoW
├── 02-wbs.md      # WBS
└── 03-schedule.md # 개발 일정
```

---

## 문서 (기획서 · 설계 · 운영)

### 기획서 & 요구사항
- [기획서 — 비전 & 목표](.planning/00-vision.md)
- [요구사항 & MoSCoW 우선순위](.planning/01-requirements.md)

### WBS & 일정
- [WBS (Work Breakdown Structure)](.planning/02-wbs.md)
- [개발 일정 (10~15주차)](.planning/04-schedule.md)

### 아키텍처 & ADR
- [아키텍처 다이어그램](docs/architecture.md)
- [아키텍처 결정 기록 (ADR)](docs/ADR.md)
- [ADR 상세 결정 파일](.planning/decisions/)

### setup · deploy · testing
- [개발 환경 설정 (setup)](docs/setup.md)
- [빌드 & 배포 가이드 (deploy)](docs/deploy.md)
- [테스트 가이드 (testing)](docs/testing.md)

### AI Agent 정책
- [AGENTS.md — AI Agent 운영 가이드](AGENTS.md)

---

## AI Agent 활용

이 프로젝트는 **Claude Code (AI Agent)** 를 활용해 개발되었습니다.
→ [AGENTS.md](AGENTS.md) 참고
