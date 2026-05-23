# 시외버스 예약 앱

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
| 예매 내역 | 예약 목록 및 상세 조회 |
| 다국어 지원 | 한/영/중/일 실시간 전환 |
| 즐겨찾기 | 자주 이용하는 터미널 저장 |
| 로그인 | 이메일 회원가입 / 소셜 로그인 (카카오·네이버) |
| 고객센터 챗봇 | FAQ 자동응답 + 키워드 매칭 룰베이스 챗봇 |

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

## 문서

- [비전 & 목표](.planning/00-vision.md)
- [요구사항 & MoSCoW](.planning/01-requirements.md)
- [WBS](.planning/02-wbs.md)
- [개발 일정](.planning/03-schedule.md)
- [아키텍처 결정 기록](docs/ADR.md)
- [개발 환경 설정](docs/setup.md)
- [테스트 가이드](docs/testing.md)

---

## AI Agent 활용

이 프로젝트는 **Claude Code (AI Agent)** 를 활용해 개발되었습니다.
→ [AGENTS.md](AGENTS.md) 참고
