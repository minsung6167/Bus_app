# LLM Wiki — 바이브코딩 암묵지 노트

> Claude Code + Flutter 개발 과정에서 얻은 실전 교훈 모음.
> 출처: Anthropic Docs, 실제 프로젝트 트러블슈팅 경험 (2026-05 ~ 2026-06)

---

## 001. Android 에뮬레이터에서 Dart HTTP 패키지 DNS 실패

### 상황
Flutter `http` 패키지로 Google Maps Directions API 호출 시 에뮬레이터에서만 `Failed host lookup` 에러. Google Maps 타일은 정상 로드됨.

### 원인
Google Maps SDK는 Android Play Services 네트워크 스택 사용.
Dart `http` 패키지는 Dart VM 자체 DNS 리졸버 사용 → 에뮬레이터에서 분리 동작.

### 해결
IP 직접 연결 + SSL SNI 설정으로 DNS 우회:
```dart
nativeClient.connectionFactory = (uri, _, __) async {
  final raw = await Socket.connect('216.239.32.223', 443);
  final secure = await SecureSocket.secure(raw, host: 'maps.googleapis.com');
  return ConnectionTask.fromSocket(Future.value(secure), () {});
};
```

### 교훈
에뮬레이터 DNS 이슈 = 코드 버그 아님. IP 직접 연결로 우회 가능.

**출처**: Dart `dart:io` HttpClient 공식 문서, 직접 트러블슈팅

---

## 002. Flutter Provider — didChangeDependencies vs addListener

### 상황
`didChangeDependencies` 안에서 `context.watch<AuthProvider>()` + 다른 Provider `loadForUser()` 호출 시 화면 깜빡임 발생.

### 원인
`notifyListeners()` → `didChangeDependencies` 재호출 → `loadForUser()` 재호출 → 무한 루프에 가까운 반복 rebuild.

### 해결
```dart
@override
void initState() {
  _auth = context.read<AuthProvider>();
  _auth.addListener(_onAuthChanged); // addListener 사용
}
```
`addListener`는 명시적 호출 시에만 반응 → 불필요한 rebuild 없음.

### 교훈
Provider 변화에 반응하는 사이드이펙트는 `didChangeDependencies`가 아닌 `addListener` 사용.

**출처**: Flutter Provider 공식 문서, Anthropic Claude Code 디버깅 세션

---

## 003. Flutter Transform.translate 는 레이아웃 공간을 확보하지 않음

### 상황
인기노선 칩을 탭해도 반응 없음. 코드에 제한 없음.

### 원인
`Transform.translate(offset: Offset(0, -16))`는 시각적으로만 이동. 레이아웃 공간(및 히트테스트 영역)은 원래 위치에 남음 → 다른 위젯과 겹침 발생 가능.

### 해결
- `GestureDetector` → `InkWell`로 교체 (물결 피드백)
- `ScrollController`로 탭 후 화면 상단으로 스크롤
- 로딩 중 탭 시 0.5초 대기 후 재시도 로직 추가

### 교훈
`Transform`은 렌더링만 변경, 히트테스트 영역은 별개. 레이아웃 기반 이동이 필요하면 `Padding`/`SizedBox` 사용.

**출처**: Flutter 공식 문서 `Transform` 위젯, 직접 트러블슈팅

---

## 004. Google Directions API — driving 모드 ZERO_RESULTS (한국)

### 상황
서울 → 부산 driving 경로 요청 시 `ZERO_RESULTS`. `available_travel_modes: ["TRANSIT"]` 반환.

### 원인
API 키 제한 또는 결제 미등록으로 driving 모드 비활성화 상태.
transit 모드는 무료 티어에서도 동작.

### 해결
무료 오픈소스 라우팅 OSRM으로 대체:
```
https://router.project-osrm.org/route/v1/driving/{lng},{lat};{lng},{lat}?overview=full&geometries=polyline
```
- API 키 불필요
- 실제 도로 경로 제공
- Google 폴리라인 인코딩 호환

### 교훈
Google Maps Platform API는 종류마다 별도 활성화 필요. 무료 대안(OSRM) 검토가 프로토타입에 유리.

**출처**: Google Maps Platform 공식 문서, OSRM 공식 문서 (project-osrm.org)

---

## 005. Marp 마크다운 수정 → GitHub Pages 미반영

### 상황
`final_slides.md` 수정 후 push했는데 `*.github.io` 사이트에 반영 안 됨.

### 원인
GitHub Pages는 `index.html`을 직접 서빙. Marp는 마크다운 → HTML 빌드 도구이며, 빌드된 HTML이 별도로 저장됨. 마크다운 수정은 HTML에 자동 반영 안 됨.

### 해결
`docs/presentation/index.html`을 직접 수정 후 push.

### 교훈
정적 사이트 배포 시 "소스 파일"과 "빌드 결과물"을 구분해야 함. CI/CD 없으면 HTML 직접 수정 필요.

**출처**: GitHub Pages 공식 문서, Marp CLI 공식 문서

---

## 006. 결정적 난수(Deterministic Random)로 실시간 API 대체

### 상황
시외버스 실시간 좌석 API는 민간 독점 유료 서비스 → 연동 불가.

### 해결
버스 ID + 출발 날짜를 seed로 사용하는 결정적 난수:
```dart
final seed = bus.id.hashCode ^ dep.year ^ (dep.month << 8) ^ (dep.day << 16);
final rng = Random(seed);
```
- 동일 버스·날짜 → 항상 동일한 좌석 배치
- 재실행해도 일관성 유지

### 교훈
접근 불가 데이터는 "그럴듯한 시뮬레이션"으로 대체 가능. seed 기반 난수는 재현 가능성이 핵심.

**출처**: Dart `dart:math` Random 공식 문서, ADR-003 참고

---

## 007. SharedPreferences userId 기반 다중 계정 데이터 분리

### 상황
여러 계정이 같은 기기에서 로그인 시 예매 내역·카드·즐겨찾기가 섞임.

### 해결
저장 키에 userId 접두사 사용:
```dart
static String _key(String userId) => 'bookings_$userId';
```
로그인 → `loadForUser(userId)`, 로그아웃 → `clearUser()`.

### 교훈
로컬 저장소 멀티 계정 분리의 가장 단순한 패턴 = "키에 사용자 ID 포함".

**출처**: SharedPreferences pub.dev 문서, 직접 설계

---

## 008. ADB setprop 는 root 권한 필요

### 상황
`adb shell setprop net.dns1 8.8.8.8` → `Failed to set property` 에러.

### 해결
```bash
adb root        # root로 adbd 재시작
adb shell "setprop net.dns1 8.8.8.8"
```

### 교훈
에뮬레이터 시스템 속성 변경은 root 권한 필요. 실기기에서는 대부분 불가.

**출처**: Android ADB 공식 문서, 직접 트러블슈팅

---

## 009. Flutter 백그라운드 GPS — FlutterForegroundTask

### 상황
앱이 백그라운드로 내려가면 GPS 체크 중단 → 수면 모드 기능 불가.

### 해결
`flutter_foreground_task` 패키지로 Foreground Service 유지:
```dart
await FlutterForegroundTask.startService(
  serviceId: 256,
  notificationTitle: '수면 모드 중',
  callback: startSleepModeCallback,
);
```
- 15초 주기로 GPS 위치 체크
- 반경 진입 시 메인 앱에 `sendDataToMain({'action': 'wake_up'})` 전송

### 교훈
Android 백그라운드 작업은 반드시 Foreground Service 또는 WorkManager 사용. 백그라운드 제한 정책으로 일반 Isolate는 종료됨.

**출처**: Android 백그라운드 실행 제한 공식 문서, flutter_foreground_task pub.dev

---

## 010. Claude Code 프롬프트 — "현상 중심" vs "원인 지정"

### 상황
"왜 이런 버그가 생겼어?" 보다 "탭해도 변화가 없어" 가 더 좋은 결과를 냄.

### 비교

| 방식 | 예시 | 결과 |
|---|---|---|
| 원인 지정 | "GestureDetector 버그 수정해줘" | AI가 GestureDetector만 봄 |
| 현상 중심 | "탭해도 변화가 없어" | AI가 전체 흐름을 분석 |

### 교훈
AI에게 "진단"을 맡기려면 현상을 있는 그대로 전달. 원인을 미리 단정하면 AI도 그 방향으로만 좁혀서 봄.

**출처**: Anthropic Claude 프롬프트 엔지니어링 가이드, 직접 경험

---

## 011. SecureSocket.connect — serverName 파라미터 버전 이슈

### 상황
`SecureSocket.connect(..., serverName: host)` → 컴파일 에러 `No named parameter 'serverName'`.

### 원인
`serverName` 파라미터는 일부 Dart SDK 버전에서 미지원.

### 해결
대신 2단계로:
```dart
final raw = await Socket.connect(ip, 443);
final secure = await SecureSocket.secure(raw, host: host); // host = SNI
```
`SecureSocket.secure`의 `host` 파라미터가 SNI 및 인증서 검증 기준점 역할.

### 교훈
SDK 버전별 API 차이는 공식 문서가 아닌 실제 컴파일로 확인. 대안 API 항상 파악해두기.

**출처**: Dart `dart:io` SecureSocket 공식 문서

---

## 012. GitHub Contribution 잔디 — 이메일 불일치 시 미반영

### 상황
push 완료했는데 GitHub 프로필 잔디에 반영 안 됨.

### 원인
`git config user.email`과 GitHub 계정 등록 이메일이 다를 때 contribution으로 인정 안 됨.

### 확인
```bash
git config user.email          # 현재 설정 이메일
# GitHub Settings → Emails 에서 동일 이메일 등록 여부 확인
```

### 교훈
잔디는 커밋 이메일이 GitHub 계정의 verified email과 일치해야 반영됨. 프로젝트 시작 전 이메일 설정 확인 필수.

**출처**: GitHub Docs — "Why are my contributions not showing up?", 직접 경험
