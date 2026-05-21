# AGENTS.md — AI Agent 운영 가이드

이 프로젝트는 **Claude Code (AI Agent)** 를 주 개발 도구로 활용합니다.

---

## 사용 도구

| 도구 | 용도 |
|---|---|
| Claude Code (claude.ai/code) | 코드 생성, 문서 작성, 디버깅 |
| VS Code | 에디터 |
| GitHub | 버전 관리 |

---

## AI Agent 활용 범위

이 프로젝트에서 AI Agent가 담당한 작업:

- 전체 Flutter 앱 코드 생성 및 수정
- 기획서, WBS, 일정표 문서 작성
- ADR(아키텍처 결정 기록) 작성
- 다국어 문자열(한/영/중/일) 번역 및 관리
- 버그 수정 및 리팩토링
- README, setup, testing 문서 작성

---

## 프롬프트 원칙

AI Agent에게 지시할 때 사용하는 원칙:

1. **What + Why 먼저** — "무엇을, 왜 만들어야 하는지" 설명 후 요청
2. **범위를 명확히** — "이 파일의 이 기능만" 처럼 범위 한정
3. **선택형 질문 활용** — 모호한 결정은 AI에게 선택지를 받아 직접 결정
4. **결과 검증 필수** — AI가 만든 코드는 반드시 직접 실행·확인

---

## 코드 이해 원칙

> AI가 만든 코드라도 본인이 설명할 수 있어야 한다.

핵심 함수 목록 (반드시 이해하고 설명 가능해야 함):

| 함수/클래스 | 위치 | 역할 |
|---|---|---|
| `_resolveRegion()` | `home_screen.dart` | 터미널명 prefix로 행정구역 보정 |
| `FavoriteProvider.toggle()` | `favorite_provider.dart` | 즐겨찾기 추가/제거 및 영속 저장 |
| `BusApiService.fetchRoutes()` | `bus_api_service.dart` | 공공 API 호출 및 fallback 처리 |
| `SeatSelectionScreen` seed 로직 | `seat_selection_screen.dart` | 결정적 난수로 좌석 점유 시뮬레이션 |
| `AppStrings.get()` | `app_strings.dart` | 언어 코드 기반 문자열 반환 |

---

## Git 커밋 규칙

```
feat:   새 기능 추가
fix:    버그 수정
docs:   문서 변경
refactor: 코드 리팩토링
```

---

## 주의사항

- `.env` 파일은 절대 커밋하지 않는다 (API 키 포함)
- `flutter analyze` 경고 0건 유지
- AI가 생성한 코드 병합 전 반드시 `flutter run` 으로 동작 확인
