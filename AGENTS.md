# AGENTS.md — 통합 AI Agent 운영 가이드

> 이 파일 하나로 **Agent 역할 · Skills · Rules · Commands** 를 통합 관리합니다.
> Claude Code (claude.ai/code) 기반 바이브코딩 프로젝트 전용 정책 파일입니다.

---

## 1. Agent 역할 정의

| 항목 | 내용 |
|---|---|
| **사용 Agent** | Claude Code (claude-sonnet-4-6) |
| **역할** | Flutter 풀스택 개발 파트너 |
| **주요 책임** | 코드 생성·수정, 문서 작성, 디버깅, 번역, ADR 작성 |
| **결정권** | 구현 방식은 AI 제안 → 사람 최종 승인 |

### 프로젝트 컨텍스트 (Agent 필독)

```
앱명: 시외버스 통합 예약 앱 (BusTicket)
스택: Flutter 3.11.5 / Dart / Provider / SharedPreferences
플랫폼: Android (에뮬레이터 Pixel_6 API 31)
언어: 한/영/중/일 4개국어
주요 외부 API: 공공데이터포털 시외버스 API, Google Maps, OSRM
테스트 환경: Android Studio 에뮬레이터 (실기기 없음)
```

---

## 2. Skills (커스텀 워크플로우)

자주 쓰는 작업을 절차화한 스킬 모음입니다.

### Skill-01: 잔디 심기
```
1. git status 확인
2. 의미 있는 파일 변경 or README/docs 업데이트
3. git add → git commit (Co-Authored-By 포함) → git push
※ .env는 절대 커밋 금지
```

### Skill-02: 번역 키 추가
```
1. app_strings.dart 에서 'ko' 섹션에 키 추가
2. 같은 키를 'en' / 'zh' / 'ja' 섹션에도 추가
3. 해당 화면에서 하드코딩 문자열 → AppStrings.get(lang, 'key') 교체
```

### Skill-03: ADR 작성
```
1. .planning/decisions/ADR-NNNN-{title}.md 생성
2. 배경 / 결정 / 대안 / 결과 섹션 필수 포함
3. docs/ADR.md 하단에 요약 섹션 추가
```

### Skill-04: 에뮬레이터 DNS 우회 HTTP 요청
```dart
// Dart http 패키지가 에뮬레이터에서 DNS 실패 시 사용
final nativeClient = HttpClient();
nativeClient.connectionFactory = (uri, _, __) async {
  final raw = await Socket.connect(IP_ADDRESS, 443);
  final secure = await SecureSocket.secure(raw, host: HOSTNAME);
  return ConnectionTask.fromSocket(Future.value(secure), () {});
};
final client = IOClient(nativeClient);
```

### Skill-05: 유저별 데이터 분리 저장
```dart
// SharedPreferences 키에 userId 접두사 사용
static String _key(String userId) => 'data_$userId';
// 로그인 시 loadForUser(userId) 호출
// 로그아웃 시 clearUser() 호출
```

---

## 3. Rules (AI에게 적용되는 규칙)

### Do ✅
- 변경 전 반드시 관련 파일 Read
- 커밋 메시지는 `feat/fix/docs/refactor:` prefix 사용
- 4개 언어 모두 동시에 번역 키 추가
- 에러 발생 시 근본 원인 파악 후 수정
- SharedPreferences 저장 시 userId 기반 키 사용

### Don't ❌
- `.env` 파일 커밋 금지 (API 키 포함)
- `withOpacity` 대신 `withValues(alpha:)` 사용 (Flutter 최신 API)
- 실기기 없이 GPS 실시간 추적 기능이 완벽히 동작한다고 단언 금지
- 에뮬레이터 DNS 문제를 "코드 버그"로 오진 금지

---

## 4. Commands (자주 쓰는 명령어 모음)

### Flutter
```bash
flutter run                          # 앱 실행
flutter run --suppress-analytics    # flutter 업데이트 체크 무시
flutter build apk --release          # 릴리즈 APK 빌드
flutter analyze                      # 정적 분석
flutter pub get                      # 패키지 설치
```

### ADB (에뮬레이터 제어)
```powershell
# adb 경로
$adb = "C:\Users\최민성\AppData\Local\Android\Sdk\platform-tools\adb.exe"

& $adb devices                        # 연결된 기기 목록
& $adb root                           # root 권한 획득
& $adb -s emulator-5556 shell "..."   # 특정 에뮬레이터에 명령
```

### Git
```bash
git add <파일>
git commit -m "feat: 기능 추가
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git push origin main
```

---

## 5. 코드 이해 체크리스트 (발표 대비)

> AI가 만든 코드라도 본인이 설명할 수 있어야 한다.

| 파일 | 핵심 로직 | 한 줄 설명 |
|---|---|---|
| `bus_api_service.dart` | `getTerminals()` | 공공 API 호출 → 실패 시 fallback 자동 전환 |
| `seat_selection_screen.dart` | seed 기반 Random | `busId + date` → 결정적 난수 → 일관된 좌석 배치 |
| `app_strings.dart` | `AppStrings.get(lang, key)` | langCode로 4개국어 문자열 동적 반환 |
| `main.dart` | `_AuthGateState._onAuthChanged` | 로그인/로그아웃 시 각 Provider 데이터 로드·초기화 |
| `map_screen.dart` | `_loadRoute()` | OSRM API → 폴리라인 디코딩 → 지도에 경로 표시 |
| `sleep_mode_task.dart` | `onRepeatEvent()` | 15초마다 GPS 체크 → 반경 진입 시 진동 알림 |

---

## 6. 프롬프트 원칙 (본인만의 기법)

이 프로젝트에서 효과적이었던 프롬프트 패턴:

| 패턴 | 예시 | 효과 |
|---|---|---|
| **현상 우선** | "탭해도 변화가 없어" | 원인 추론을 AI에게 맡김 |
| **결과 지정** | "누르면 MyCardsScreen으로 넘어가게" | 구현 방식은 AI 재량 |
| **단계 생략** | "잔디심어줘" | 반복 절차는 한 단어로 |
| **스크린샷 첨부** | 에러 화면 캡처 | 텍스트보다 정확한 맥락 전달 |

---

## 7. Git 커밋 컨벤션

```
feat:     새 기능 추가
fix:      버그 수정
docs:     문서 변경 (README, ADR, WBS 등)
refactor: 코드 리팩토링 (기능 변화 없음)
chore:    빌드·설정 변경
style:    UI/디자인 변경
```

모든 커밋에 Co-author 포함:
```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```
