---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: 'Noto Sans KR', 'Segoe UI', sans-serif;
    font-size: 20px;
  }
  h1 { color: #1a56db; font-size: 1.9em; }
  h2 { color: #1a56db; border-bottom: 2px solid #1a56db; padding-bottom: 6px; margin-bottom: 14px; }
  table { width: 100%; font-size: 0.82em; }
  th { background: #1a56db; color: white; }
  td { vertical-align: middle; }
  code { font-size: 0.76em; }
  .box { background:#eff6ff; border-left:4px solid #1a56db; border-radius:6px; padding:11px 15px; margin:8px 0; }
  .warn { background:#fff7ed; border-left:4px solid #f97316; border-radius:6px; padding:11px 15px; margin:8px 0; }
  .good { background:#f0fdf4; border-left:4px solid #16a34a; border-radius:6px; padding:11px 15px; margin:8px 0; }
  .cols2 { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
  .cols3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; }
  .tag { display:inline-block; border-radius:4px; padding:2px 8px; font-size:0.75em; font-weight:600; color:white; }
  .card { background:white; border:1px solid #e2e8f0; border-radius:8px; padding:12px 14px; }
---

# 시외버스 통합 예약 앱
### 최종 발표

최민성 &nbsp;|&nbsp; 2026-06-14

---

## 01. 비전 제시

<div style="text-align:center; margin:16px 0 20px;">
  <div style="background:#1a56db; color:white; border-radius:12px; padding:18px 32px; font-size:1.08em; font-weight:bold; line-height:1.9;">
    "버스 안에서 지도 앱을 따로 켜지 않아도 되는 앱"<br>
    <span style="font-size:0.8em; font-weight:normal; opacity:0.88;">예매 · 현재위치 · 수면알림 · QR발권을 하나의 앱에서</span>
  </div>
</div>

<div class="cols3">
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.7em;">🎫</div>
  <strong>예매·발권</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:4px;">좌석 선택부터<br>QR 모바일 발권까지</p>
</div>
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.7em;">😴</div>
  <strong>수면 알림</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:4px;">GPS 기반 도착 전<br>자동 진동 알림</p>
</div>
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.7em;">🗺️</div>
  <strong>실시간 지도</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:4px;">현재위치·경로를<br>앱 이탈 없이 확인</p>
</div>
</div>

<!--
[대사]
시외버스를 타고 장거리 이동할 때, 불편한 점이 있으셨나요?
저는 버스를 타면 지도 앱을 따로 켜야 하고, 자다가 내릴 곳을 놓칠까봐 걱정하고, 외국인 친구와 같이 탈 때 한국어 앱이라 혼자 설명해야 했습니다.
이 모든 문제를 앱 하나로 해결하는 것이 저의 비전입니다.
-->

---

## 02. 문제 정의

| &nbsp; | 문제 상황 | 기존 방식 | **우리 앱** |
|---|---|---|---|
| <span class="tag" style="background:#1a56db;">위치</span> | 이동 중 현재 위치 확인 | 지도 앱 별도 실행 | 앱 내 실시간 지도 |
| <span class="tag" style="background:#7c3aed;">수면</span> | 수면 중 목적지 놓침 | 알람 직접 설정 | GPS 자동 진동 알림 |
| <span class="tag" style="background:#0891b2;">언어</span> | 외국인 이용 불편 | 한국어 전용 | 한·영·중·일 4개국어 |
| <span class="tag" style="background:#059669;">좌석</span> | 혼잡도 파악 불가 | 예매 전 알 수 없음 | 혼잡도 예측 시각화 |
| <span class="tag" style="background:#d97706;">발권</span> | 종이 발권 번거로움 | 창구·ATM 수령 | QR 모바일 발권 |

<div class="box" style="margin-top:12px;">
  <strong>핵심 문제:</strong> 기존 시외버스 앱은 <strong>예매 기능만</strong> 제공 → 승차 후 경험은 완전히 공백
</div>

<!--
[대사]
기존 시외버스 앱은 예매는 되지만, 버스를 탄 이후의 경험은 완전히 공백입니다.
자리에 앉으면 지도 앱을 따로 켜야 하고, 자다가 내릴 곳을 놓칠까봐 알람을 따로 맞춰야 합니다.
외국인이라면 한국어 전용 앱 앞에서 막막합니다.
저는 이 공백을 채우는 앱을 만들었습니다.
-->

---

## 03. 프로젝트 계획 — WBS & 기술 스택

<div class="cols2">
<div>

**WBS 진행 현황** (전체 **95%** 완료)

| 영역 | 완료 | 완료율 |
|---|---|---|
| 기반·인증·터미널 검색 | 20 / 20 | ✅ 100% |
| 예매·결제·내역 | 19 / 19 | ✅ 100% |
| GPS·지도·다국어 | 14 / 14 | ✅ 100% |
| 부가기능·마이페이지 | 9 / 9 | ✅ 100% |
| 테스트·배포 | 1 / 5 | 🔄 20% |
| **전체** | **79 / 83** | **95%** |

</div>
<div>

**기술 스택**

| 구분 | 기술 |
|---|---|
| 프레임워크 | Flutter 3.41 (Dart) |
| 상태관리 | Provider (ChangeNotifier) |
| 로컬 저장 | SharedPreferences |
| GPS·백그라운드 | geolocator + FlutterForegroundTask |
| 지도·경로 | Google Maps + OSRM |
| 공공 API | 공공데이터포털 버스 노선 |
| 다국어 | 한·영·중·일 (AppStrings) |

</div>
</div>

---

## 04. 프로젝트 진행 과정

| 주차 | 기간 | 내용 | 상태 |
|---|---|---|---|
| 10주차 | 5월 1주 | 기획 · 요구사항 정의 · 일정 수립 | ✅ 완료 |
| 11주차 | 5월 2주 | 개발환경 구성 · 기반 설계 · UI 스켈레톤 | ✅ 완료 |
| 12주차 | 5월 3주 | 핵심 기능 구현 **(중간 발표)** | ✅ 완료 |
| 13주차 | 5월 4주 | UX 개선 · QR 고도화 · 챗봇 · 쿠폰 | ✅ 완료 |
| 14주차 | 6월 1주 | 지도 기능 구현 · 다국어 완성 | ✅ 완료 |
| 15주차 | 6월 2주 | 마무리 · 테스트 · **최종 발표** | 🔄 진행중 |

<div class="box" style="margin-top:12px;">
  Must 기능 <strong>전체 완료</strong> &nbsp;·&nbsp; Should 기능 <strong>전체 완료</strong> &nbsp;·&nbsp; 테스트/배포 진행중
</div>

---

## 05. 앱 구조 설명

<div class="cols2">
<div>

**화면 구성 (하단 탭 3개)**

```
MainScreen
├── 🏠 홈
│    터미널 검색 → 버스목록
│    → 좌석 선택 → 결제 → 완료
│
├── 🎫 내 예매
│    예정된 여행 / 지난 여행
│    └── 티켓 상세
│         QR발권 · 지도 · 수면모드
│
└── 👤 마이페이지
     내 정보 · 카드 · 쿠폰
     즐겨찾기 · 공지 · 챗봇
```

**비로그인** → 게스트 예매 지원
**4개국어** 전환 — 전체 화면 즉시 적용

</div>
<div>

**디렉토리 구조**

```
lib/
├── main.dart
├── screens/        # 화면 (UI)
│   ├── home/
│   ├── booking/    # 예매·결제·좌석
│   ├── mypage/     # 마이페이지·카드·쿠폰
│   └── auth/       # 로그인·회원가입
├── providers/      # 상태 관리
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   ├── language_provider.dart
│   └── card_provider.dart
├── services/       # API·비즈니스 로직
│   └── bus_api_service.dart
├── models/         # 데이터 모델
├── widgets/        # 공통 위젯
├── data/           # Mock fallback 데이터
├── theme/          # 색상·폰트 시스템
└── l10n/           # 다국어 문자열
```

</div>
</div>

---

## 06. 아키텍처 다이어그램

<div style="font-size:0.78em; margin-top:4px; display:flex; gap:14px;">

<div style="flex:3; display:flex; flex-direction:column; gap:5px;">

  <div style="background:#dbeafe; border-left:5px solid #2563eb; border-radius:7px; padding:8px 14px;">
    <strong style="color:#1e40af;">🖥️ UI Layer &nbsp;·&nbsp; Screens / Widgets</strong><br>
    <span style="color:#3b82f6;">홈 &nbsp;·&nbsp; 예매 &nbsp;·&nbsp; 마이페이지 &nbsp;·&nbsp; 로그인 &nbsp;·&nbsp; 티켓상세 &nbsp;·&nbsp; 지도</span>
  </div>

  <div style="text-align:center; color:#6366f1; font-weight:bold; font-size:1.1em; line-height:1.2;">⇅ watch / read</div>

  <div style="background:#ede9fe; border-left:5px solid #7c3aed; border-radius:7px; padding:8px 14px;">
    <strong style="color:#6d28d9;">⚡ State Layer &nbsp;·&nbsp; Provider (ChangeNotifier)</strong><br>
    <span style="color:#7c3aed;">Auth &nbsp;·&nbsp; Booking &nbsp;·&nbsp; Language &nbsp;·&nbsp; Favorite &nbsp;·&nbsp; Card</span>
  </div>

  <div style="display:grid; grid-template-columns:3fr 2fr; gap:10px; margin-top:2px;">
    <div style="display:flex; flex-direction:column; gap:5px;">
      <div style="text-align:center; color:#64748b; font-size:0.9em;">↓ HTTP 요청</div>
      <div style="background:#fef3c7; border-left:5px solid #f59e0b; border-radius:7px; padding:8px 14px;">
        <strong style="color:#b45309;">🔧 BusApiService</strong><br>
        <span style="color:#78716c;">공공데이터포털 API 호출</span><br>
        <span style="color:#9ca3af; font-size:0.88em;">└ 실패 시 Mock Data 자동 폴백</span>
      </div>
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:5px;">
        <div style="background:#dcfce7; border-left:4px solid #16a34a; border-radius:6px; padding:7px 10px;">
          <strong style="color:#166534;">🌐 공공버스 API</strong><br>
          <span style="color:#15803d; font-size:0.88em;">data.go.kr</span>
        </div>
        <div style="background:#f3f4f6; border-left:4px solid #9ca3af; border-radius:6px; padding:7px 10px;">
          <strong style="color:#374151;">📄 Mock Data</strong><br>
          <span style="color:#6b7280; font-size:0.88em;">폴백 데이터</span>
        </div>
      </div>
    </div>
    <div style="display:flex; flex-direction:column; gap:5px;">
      <div style="text-align:center; color:#64748b; font-size:0.9em;">↕ 로컬 · 지도</div>
      <div style="background:#dcfce7; border-left:4px solid #16a34a; border-radius:6px; padding:8px 12px;">
        <strong style="color:#166534;">💾 SharedPreferences</strong><br>
        <span style="color:#15803d; font-size:0.88em;">로그인 · 즐겨찾기 · 카드</span>
      </div>
      <div style="background:#e0f2fe; border-left:4px solid #0284c7; border-radius:6px; padding:8px 12px;">
        <strong style="color:#0369a1;">🗺️ Google Maps + OSRM</strong><br>
        <span style="color:#0284c7; font-size:0.88em;">지도·경로 계산</span>
      </div>
    </div>
  </div>

</div>

<div style="flex:1.1; display:flex; flex-direction:column; gap:6px; border-left:2px dashed #c4b5fd; padding-left:14px; align-items:stretch;">

  <div style="text-align:center; color:#7c3aed; font-weight:bold; font-size:0.95em;">백그라운드 독립 실행</div>

  <div style="background:#fdf4ff; border-left:4px solid #a855f7; border-radius:7px; padding:8px 12px; text-align:center;">
    <strong style="color:#7e22ce;">😴 SleepModeTask</strong><br>
    <span style="color:#9333ea; font-size:0.88em;">Foreground Service</span>
  </div>

  <div style="text-align:center; color:#64748b; font-size:0.88em;">↓ 15초마다 체크</div>

  <div style="background:#fdf4ff; border-left:4px solid #a855f7; border-radius:7px; padding:8px 12px; text-align:center;">
    <strong style="color:#7e22ce;">📍 Geolocator</strong><br>
    <span style="color:#9333ea; font-size:0.88em;">GPS 위치 추적</span>
  </div>

  <div style="text-align:center; color:#64748b; font-size:0.88em;">↓ 반경 진입 감지</div>

  <div style="background:#fff7ed; border-left:4px solid #f97316; border-radius:7px; padding:8px 12px; text-align:center;">
    <strong style="color:#c2410c;">🔔 진동 알림</strong><br>
    <span style="color:#ea580c; font-size:0.88em;">2 / 5 / 10km 선택</span>
  </div>

</div>

</div>

---

## 07. 개발 환경 설정 & GitHub 설치 가이드

<div class="cols2">
<div>

**필수 환경**

| 도구 | 버전 |
|---|---|
| Flutter SDK | 3.11.5 이상 |
| Android Studio | 최신 |
| Git | 최신 |

**GitHub 클론 & 실행**

```bash
git clone https://github.com/minsung6167/Bus_app.git
cd Bus_app

# 패키지 설치
flutter pub get

# 환경변수 설정 (.env에 API 키 입력)
cp .env.example .env

# 앱 실행
flutter run
```

</div>
<div>

**환경변수 (.env)**

```
BUS_API_KEY=공공데이터포털_발급_키
```

> 키 없이도 실행 가능 — fallback 모드로 Mock 데이터 동작

**주요 패키지**

| 패키지 | 용도 |
|---|---|
| `provider` | 전역 상태 관리 |
| `shared_preferences` | 로컬 영구 저장 |
| `geolocator` | GPS 위치 추적 |
| `flutter_foreground_task` | 백그라운드 서비스 |
| `google_maps_flutter` | 지도 렌더링 |
| `flutter_dotenv` | 환경변수 관리 |

</div>
</div>

---

## 08. 빌드 & 배포 과정

<div class="cols2">
<div>

**빌드 명령어**

```bash
# 정적 분석 (경고 0건 확인)
flutter analyze

# Android Debug APK (테스트용)
flutter build apk --debug

# Android Release APK (배포용)
flutter build apk --release

# Google Play 제출용
flutter build appbundle --release

# iOS (Mac + Xcode 필요)
flutter build ios --release
```

</div>
<div>

**결과물 위치**

```
build/app/outputs/
├── flutter-apk/
│   ├── app-debug.apk
│   └── app-release.apk   ← 제출용
└── bundle/release/
    └── app-release.aab   ← Play Store
```

**배포 전 체크리스트**

- ✅ `flutter analyze` 경고 0건
- ✅ `flutter test` 전체 통과
- ✅ `.env` API 키 설정 확인
- ✅ `pubspec.yaml` 버전 확인
- ⬜ Release APK 최종 빌드

</div>
</div>

---

## 09. 구현 방법 설명 — GPS 수면 모드

**"자다가 목적지 근처에 오면 자동으로 깨워준다"**

<div class="cols2">
<div>

```dart
void onRepeatEvent(DateTime timestamp) async {
  final pos = await Geolocator
    .getCurrentPosition(...);
  final dist = Geolocator.distanceBetween(
    pos.latitude, pos.longitude,
    _destLat!, _destLng!,
  );
  if (dist <= _alertMeters) {
    FlutterForegroundTask
      .sendDataToMain({'action': 'wake_up'});
  }
}
```

</div>
<div>

**동작 흐름**

```
티켓 상세 → 수면모드 ON
        ↓
 Foreground Service 시작
 (화면 꺼져도 계속 동작)
        ↓
  15초마다 GPS 위치 체크
        ↓
  목적지 반경 진입 감지
  (2km / 5km / 10km 선택)
        ↓
    강한 진동으로 알림
```

</div>
</div>

---

## 10. 구현 방법 설명 — 지도 & 챗봇

<div class="cols2">
<div>

**실시간 지도 (Google Maps + OSRM)**

```
Geolocator → 현재 위치 취득
        ↓
출발·도착 터미널 마커 표시
        ↓
OSRM API → 실제 도로 경로 계산
        ↓
폴리라인 + 예상 소요시간 표시
```

- 비용 없이 실제 도로 경로 계산 (OSRM 오픈소스)
- 에뮬레이터 → Android Studio Location 탭으로 좌표 수동 설정

</div>
<div>

**고객센터 챗봇 (FAQ 키워드 매칭)**

| 키워드 | 안내 내용 |
|---|---|
| 취소·환불 | 예매 취소 방법·환불 정책 |
| 발권·QR | 모바일 발권 사용법 |
| 짐·수하물 | 허용 수하물 안내 |
| 언어·language | 언어 변경 방법 |
| 회원가입·로그인 | 비회원 예매 가능 여부 |

- 빠른 질문 버튼 원터치 선택
- 4개 언어 전체 대응

</div>
</div>

---

## 11. 구현 시행착오 사례

<div class="warn">
⚠️ <strong>문제 1 — 실시간 좌석 API 없음</strong><br>
시외버스 좌석 데이터는 KOBUS·금호고속 독점 유료 서비스 (B2B 계약 필요, 공공 API 미제공)
</div>

**해결: 결정적 난수(seed) 기반 시뮬레이션**

```dart
List<SeatStatus> generateSeats(String busId, String date) {
  final seed = int.parse(busId.replaceAll(RegExp(r'\D'), '')) + date.hashCode;
  final rng = Random(seed);   // 버스ID + 날짜 → 항상 동일한 시드
  return List.generate(28, (_) =>
    rng.nextDouble() < 0.4 ? SeatStatus.occupied : SeatStatus.available);
}
```

<div class="cols2">
<div class="good">
✅ 동일 버스·날짜 → 항상 같은 좌석 배치<br>
✅ 실 서비스 전환 시 이 함수만 교체하면 나머지 UI 그대로 동작
</div>
<div class="warn">
⚠️ <strong>문제 2 — 에뮬레이터 GPS 불가</strong><br>
→ Android Studio Extended Controls<br>
&nbsp;&nbsp; Location 탭에서 수동 좌표 입력으로 대응
</div>
</div>

---

## 12. ADR 요약 (질의응답 준비)

| # | 결정 항목 | 선택 | 핵심 이유 |
|---|---|---|---|
| ADR-001 | 크로스플랫폼 프레임워크 | **Flutter** | Skia 렌더링으로 iOS·Android 완전 동일 UI, 단일 코드베이스 |
| ADR-002 | 버스 목록 정렬 기준 | **출발 시간순 고정** | 사용자가 가장 먼저 확인하는 정보, 정렬 UI 추가 불필요 |
| ADR-003 | 실시간 좌석 조회 | **결정적 난수 시뮬레이션** | 공개 API 없음·B2B 불가 → seed 기반으로 일관성 확보 |
| ADR-004 | 에뮬레이터 GPS 한계 | **수동 위치 설정** | GPS 칩 없는 에뮬레이터 → Studio Location 탭 활용 |

---

## 13. 성능 최적화 & 코드 품질 관리

<div class="cols2">
<div>

**성능 최적화**

- **API Fallback** — 네트워크 오류 시 로컬 Mock 데이터 자동 전환, 앱 중단 없음
- **결정적 좌석 캐싱** — seed 기반 계산으로 동일 요청 재연산 없음
- **IndexedStack** — 탭 전환 시 위젯 재빌드 방지
- **Foreground Service** — GPS 백그라운드 15초 주기 안정 동작
- **계정별 데이터 분리** — `userId` 키로 SharedPreferences 관리

</div>
<div>

**코드 품질**

```bash
$ flutter analyze
Analyzing bus_app...
No issues found! (ran in 3.5s)
```

- `flutter analyze` **경고 0건** 유지
- Provider 패턴으로 UI·비즈니스 로직 완전 분리
- `.env` 환경변수로 API 키를 코드 외부 관리
- fallback Mock 데이터로 오프라인 완전 대응
- 전체 화면 다국어 누락 키 검수 완료

</div>
</div>

---

## 14. 테스트 결과 (단위 / 통합)

<div class="cols2">
<div>

**위젯 테스트 (Widget Test)**

| 대상 화면 | 확인 내용 |
|---|---|
| HomeScreen | 출발·도착 선택 버튼 렌더링 |
| BusListScreen | 버스 목록 카드 렌더링 |
| SeatSelectionScreen | 좌석 배치도 렌더링 |
| BookingConfirmScreen | 결제 수단 선택 UI 렌더링 |

```bash
$ flutter test
All tests passed!
```

</div>
<div>

**통합 테스트 (Integration Test)**
전체 예매 흐름을 실제 앱에서 End-to-End 검증

```
1. 앱 실행 → 홈 화면 렌더링 확인
2. 서울남부 → 부산종합 선택
3. 날짜 선택 → 버스 목록 조회 (API 연동)
4. 버스 선택 → 좌석 선택 → 결제 완료
5. 예매 내역 탭 → QR 발권 확인
6. 수면모드 ON → GPS 감지 → 진동 알림
7. 언어 전환 (한→영→중→일) 전체 화면 검증
```

**엣지 케이스 검증**
- ✅ 네트워크 없음 → fallback Mock 자동 전환
- ✅ 비로그인 예약 시도 → 로그인 유도 화면
- ✅ 잘못된 카드 번호 → 유효성 오류 메시지

</div>
</div>

---

## 15. 활용 방안 & 기대 효과

<div class="cols3">
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.8em; margin-bottom:8px;">🧳</div>
  <strong>내국인 여행자</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:6px;">수면 모드로<br>목적지 놓침 걱정 없이<br>장거리 이동</p>
</div>
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.8em; margin-bottom:8px;">🌏</div>
  <strong>외국인 관광객</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:6px;">4개국어 지원으로<br>언어 장벽 없이<br>시외버스 이용</p>
</div>
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.8em; margin-bottom:8px;">📱</div>
  <strong>디지털 전환</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:6px;">종이 발권 → QR<br>모바일 발권으로<br>편의성 향상</p>
</div>
</div>

<br>

**기대 효과**

- 예매 → 탑승 → 도착까지 **앱 하나로 전 과정 완결**
- GPS 수면 모드로 **장거리 이동 스트레스 해소**
- 4개국어로 **외국인 관광 접근성** 향상
- 공공 API 기반 **실제 노선 데이터** 제공 (신뢰성 확보)

---

## 16. AI Agent 활용 & 가산점 어필

<div class="cols3">
<div>

**A. AI Agent 활용** `+1점`

Claude Code (claude-sonnet-4-6)를 **개발 전 과정**에 활용

- Flutter 코드 생성 · 수정 · 디버깅
- ADR · WBS · 기획 문서 자동 생성
- 다국어 4개국어 번역 자동화
- `flutter analyze` 경고 즉시 수정

</div>
<div>

**B. 본인만의 기법** `+2점`

**`AGENTS.md` 단일 파일**로 통합

```
AGENTS.md
├── 1. Agent 역할 정의
├── 2. Skills (5가지 절차화)
├── 3. Rules (Do / Don't)
├── 4. Commands (모음)
├── 5. 코드 이해 체크리스트
├── 6. 프롬프트 패턴
└── 7. Git 커밋 컨벤션
```

별도 정책 파일 필요 없이 **이 파일 하나**로 AI와 협업

</div>
<div>

**C. LLM Wiki 암묵지** `+1점`

`docs/llm-wiki.md` — 12개 항목

| # | 교훈 |
|---|---|
| 001 | 에뮬레이터 DNS 우회 |
| 002 | Provider addListener |
| 003 | Transform 히트테스트 |
| 004 | OSRM으로 Maps 대체 |
| 006 | 결정적 난수 패턴 |
| 010 | 현상 중심 프롬프트 |
| ... | 총 12개 직접 경험 기록 |

</div>
</div>

<!--
[대사]
가산점 항목 세 가지를 어필하겠습니다.
첫 번째, AI Agent를 단순 코드 생성이 아닌 기획부터 문서화까지 전 과정에 활용했습니다.
두 번째, AGENTS.md 파일 하나에 Agent 역할, 스킬, 규칙, 커맨드를 모두 통합해 관리하는 저만의 기법을 사용했습니다.
세 번째, 개발 중 마주친 실제 문제와 해결법을 12개 항목의 LLM Wiki로 정리해 암묵지를 문서화했습니다.
-->

---

## 마무리 & 향후 발전 방향

<div class="cols2">
<div>

**달성 내용 요약**

- ✅ Flutter 크로스플랫폼 (Android · iOS)
- ✅ 공공 API 기반 실시간 버스 조회
- ✅ QR 모바일 발권 + 예매 전 과정
- ✅ GPS 수면 모드 (Foreground Service)
- ✅ 실시간 지도 + 도로 경로 (OSRM)
- ✅ 한·영·중·일 4개국어 완성
- ✅ flutter analyze 경고 0건

**학습 여정 & 개선 의지**

- Flutter·Dart를 이 프로젝트에서 **처음 학습**, 공식 문서·커뮤니티로 독학
- 막힌 문제마다 ADR로 기록 → **결정 근거를 문서화**하는 습관 형성
- 실 서비스 수준의 코드 품질 기준(analyze 0건)을 스스로 설정하고 유지

</div>
<div>

**향후 발전 방향**

- 🔜 **실제 결제 연동** — PG사 (토스·카카오페이)
- 🔜 **Push 알림** — FCM 출발 알림
- 🔜 **소셜 로그인** — 카카오·네이버·구글
- 🔜 **App Store · Play Store 출시**
- 🔜 **실시간 좌석 API** — B2B 계약 시 교체 가능 구조
- 🔜 **버스 내 와이파이 연동** 안내

</div>
</div>

---

## 18. 시연 데모

**30초 시나리오** — "서울에서 부산 가는 버스, 자면서 안심하고 타기"

<div class="cols2">
<div>

**순서** (사용자 시나리오)

| 초 | 화면 | 포인트 |
|---|---|---|
| 0~5s | 홈 → 터미널 선택 | 인기 TOP10 즉시 선택 |
| 5~10s | 버스 목록 → 선택 | 혼잡도 색상 + 잔여석 |
| 10~15s | 좌석 배치도 → 결제 | 배치도 시각화 |
| 15~20s | 내 예매 → QR 발권 | 티켓 카드 → QR 코드 |
| 20~25s | 수면모드 ON → 지도 | 위치 추적 시작 |
| 25~30s | 언어 전환 (한→영) | 전체 화면 즉시 적용 |

</div>
<div style="display:flex; flex-direction:column; gap:10px;">

<div class="box">
  <strong>임팩트 포인트</strong><br>
  수면 모드 ON 후 GPS 반경 진입 → <strong>진동으로 깨어남</strong><br>
  <span style="font-size:0.85em; color:#64748b;">← 이게 이 앱의 핵심 차별점</span>
</div>

<div class="good">
  <strong>엣지 케이스도 보여줄 것</strong><br>
  네트워크 OFF → Mock 데이터 자동 전환 (앱 중단 없음)
</div>

</div>
</div>

<!--
[대사]
지금부터 30초 시연을 보여드리겠습니다.
서울남부에서 부산으로 가는 버스를 예약하고, 버스 안에서 자면서도 목적지 근처에 오면 자동으로 알림을 받는 전체 흐름을 보여드립니다.
-->

---

<!-- 영상 슬라이드 (별도 화면으로 전환하거나 위 슬라이드와 합쳐서 사용) -->
## 🎬 시연

<div style="display:flex; align-items:center; justify-content:center; min-height:300px; flex-direction:column; gap:16px;">

<div style="font-size:1.1em; font-weight:bold; color:#1a56db;">앱 시연 (Live / 영상)</div>

<div style="background:#f8fafc; border:2px dashed #94a3b8; border-radius:12px; padding:20px 40px; text-align:center; color:#64748b; font-size:0.9em; line-height:2;">
  검색 → 좌석 선택 → 결제 → QR 발권<br>
  수면 모드 ON → GPS 감지 → 진동 알림<br>
  실시간 지도 → 언어 전환 (한/영/중/일)
</div>

</div>

---

## 감사합니다

**GitHub** &nbsp;: &nbsp;https://github.com/minsung6167/Bus_app

**발표자료** &nbsp;: &nbsp;https://minsung6167.github.io/Bus_app/

**문의** &nbsp;: &nbsp;minsung1408@g.shingu.ac.kr

<br>
<br>

> *"버스 안에서 지도 앱을 따로 켜지 않아도 되는 앱"*
