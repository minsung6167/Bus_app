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

최민성 &nbsp;|&nbsp; 2026-06-22

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

<div style="background:#1e3a8a; color:white; border-radius:10px; padding:14px 20px; margin-bottom:16px; font-size:1.0em; font-weight:bold; text-align:center;">
  ⚠️ 핵심 문제 &nbsp;—&nbsp; 기존 버스 예매 앱들은 <u>예매 기능만</u> 제공<br>
  <span style="font-size:0.85em; font-weight:normal; opacity:0.9;">현재 위치 확인을 위해 다른 앱을 따로 실행해야 하는 번거로움 발생</span>
</div>

| &nbsp; | 문제 상황 | 기존 방식 | **우리 앱** |
|---|---|---|---|
| <span class="tag" style="background:#1a56db;">위치</span> | 이동 중 현재 위치 확인 | 지도 앱 별도 실행 | 앱 내 실시간 지도 |
| <span class="tag" style="background:#7c3aed;">수면</span> | 수면 중 목적지 놓침 | 알람 직접 설정 | GPS 자동 진동 알림 |
| <span class="tag" style="background:#0891b2;">언어</span> | 외국인 이용 불편 | 한국어 전용 | 한·영·중·일 4개국어 |
| <span class="tag" style="background:#059669;">좌석</span> | 혼잡도 파악 불가 | 예매 전 알 수 없음 | 혼잡도 예측 시각화 |
| <span class="tag" style="background:#d97706;">발권</span> | 종이 발권 번거로움 | 창구·ATM 수령 | QR 모바일 발권 |

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

**WBS 진행 현황** (전체 **100%** 완료)

| 주차 | 영역 | 완료율 |
|---|---|---|
| 10~11주 | 기반·인증·터미널 검색 | ✅ 100% |
| 12~13주 | 예매·결제·내역 | ✅ 100% |
| 13~14주 | GPS·지도·다국어 | ✅ 100% |
| 14주 | 부가기능·마이페이지 | ✅ 100% |
| 15주 | 테스트·최종발표 | ✅ 100% |
| **전체** | — | **✅ 100%** |

</div>
<div>

**기술 스택**

| 구분 | 기술 |
|---|---|
| 프레임워크 | Flutter 3.41 (Dart) |
| 상태관리 | Provider (ChangeNotifier) |
| 로컬 저장 | SharedPreferences |
| GPS·백그라운드 | geolocator + FlutterForegroundTask |
| 지도 | Google Maps API |
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
| 15주차 | 6월 2주 | 마무리 · 테스트 · **최종 발표** | ✅ 완료 |

<div class="box" style="margin-top:12px;">
  Must 기능 <strong>전체 완료</strong> &nbsp;·&nbsp; Should 기능 <strong>전체 완료</strong> &nbsp;·&nbsp; 테스트 · 최종발표 <strong>완료</strong>
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
<div style="display:flex; align-items:center; justify-content:center;">

<img src="presentation/home_screenshot2.png" style="height:480px; border-radius:20px; box-shadow:0 8px 24px rgba(0,0,0,0.18);">

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

<div style="display:flex; flex-direction:column; gap:10px; margin-top:8px;">

<div style="display:flex; align-items:stretch; gap:0;">
  <div style="background:#1a56db; color:white; border-radius:8px 0 0 8px; padding:10px 18px; font-weight:bold; font-size:0.95em; display:flex; align-items:center; min-width:120px; justify-content:center; text-align:center;">STEP 1<br>정적 분석</div>
  <div style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:0 8px 8px 0; padding:10px 18px; flex:1; display:flex; align-items:center; gap:16px;">
    <code style="background:#dbeafe; padding:4px 10px; border-radius:4px;">flutter analyze</code>
    <span style="color:#374151;">경고 0건 확인 → 코드 품질 검증</span>
    <span style="margin-left:auto;">✅ 통과</span>
  </div>
</div>

<div style="display:flex; align-items:stretch; gap:0;">
  <div style="background:#7c3aed; color:white; border-radius:8px 0 0 8px; padding:10px 18px; font-weight:bold; font-size:0.95em; display:flex; align-items:center; min-width:120px; justify-content:center; text-align:center;">STEP 2<br>테스트</div>
  <div style="background:#f5f3ff; border:1px solid #ddd6fe; border-radius:0 8px 8px 0; padding:10px 18px; flex:1; display:flex; align-items:center; gap:16px;">
    <code style="background:#ede9fe; padding:4px 10px; border-radius:4px;">flutter test</code>
    <span style="color:#374151;">단위·위젯 테스트 전체 통과 확인</span>
    <span style="margin-left:auto;">✅ 통과</span>
  </div>
</div>

<div style="display:flex; align-items:stretch; gap:0;">
  <div style="background:#0891b2; color:white; border-radius:8px 0 0 8px; padding:10px 18px; font-weight:bold; font-size:0.95em; display:flex; align-items:center; min-width:120px; justify-content:center; text-align:center;">STEP 3<br>Debug 빌드</div>
  <div style="background:#ecfeff; border:1px solid #a5f3fc; border-radius:0 8px 8px 0; padding:10px 18px; flex:1; display:flex; align-items:center; gap:16px;">
    <code style="background:#cffafe; padding:4px 10px; border-radius:4px;">flutter build apk --debug</code>
    <span style="color:#374151;">에뮬레이터·테스트 기기 설치용</span>
  </div>
</div>

<div style="display:flex; align-items:stretch; gap:0;">
  <div style="background:#059669; color:white; border-radius:8px 0 0 8px; padding:10px 18px; font-weight:bold; font-size:0.95em; display:flex; align-items:center; min-width:120px; justify-content:center; text-align:center;">STEP 4<br>Release 빌드</div>
  <div style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:0 8px 8px 0; padding:10px 18px; flex:1; display:flex; align-items:center; gap:16px;">
    <code style="background:#dcfce7; padding:4px 10px; border-radius:4px;">flutter build apk --release</code>
    <span style="color:#374151;">최적화된 배포용 APK 생성</span>
    <span style="margin-left:auto; font-size:0.85em; color:#059669;">app-release.apk</span>
  </div>
</div>

<div style="display:flex; align-items:stretch; gap:0;">
  <div style="background:#d97706; color:white; border-radius:8px 0 0 8px; padding:10px 18px; font-weight:bold; font-size:0.95em; display:flex; align-items:center; min-width:120px; justify-content:center; text-align:center;">STEP 5<br>Play Store</div>
  <div style="background:#fffbeb; border:1px solid #fde68a; border-radius:0 8px 8px 0; padding:10px 18px; flex:1; display:flex; align-items:center; gap:16px;">
    <code style="background:#fef3c7; padding:4px 10px; border-radius:4px;">flutter build appbundle --release</code>
    <span style="color:#374151;">Google Play Store 제출용 AAB</span>
    <span style="margin-left:auto; font-size:0.85em; color:#d97706;">app-release.aab</span>
  </div>
</div>

</div>

---

## 09. GPS 수면모드

<div class="cols2">
<div style="display:flex; flex-direction:column; gap:12px; justify-content:center;">

<div class="box">
  <strong>동작 흐름</strong><br><br>
  티켓 상세 → 수면모드 ON<br>
  &nbsp;&nbsp;&nbsp;&nbsp;↓<br>
  Foreground Service 시작 (화면 꺼져도 동작)<br>
  &nbsp;&nbsp;&nbsp;&nbsp;↓<br>
  15초마다 GPS 위치 체크<br>
  &nbsp;&nbsp;&nbsp;&nbsp;↓<br>
  목적지 반경 진입 감지 (2 / 5 / 10km 선택)<br>
  &nbsp;&nbsp;&nbsp;&nbsp;↓<br>
  <strong>강한 진동으로 알림</strong>
</div>

</div>
<div style="display:flex; gap:12px; align-items:center; justify-content:center;">

<div style="text-align:center;">
  <img src="presentation/sleep_setting.png" style="height:400px; border-radius:16px; box-shadow:0 6px 20px rgba(0,0,0,0.18);">
  <div style="font-size:0.78em; color:#64748b; margin-top:6px;">거리 설정 화면</div>
</div>

<div style="text-align:center;">
  <img src="presentation/sleep_running.png" style="height:400px; border-radius:16px; box-shadow:0 6px 20px rgba(0,0,0,0.18);">
  <div style="font-size:0.78em; color:#64748b; margin-top:6px;">실행 중 화면</div>
</div>

</div>
</div>

---

## 10. 지도 & 챗봇

<div style="display:flex; gap:16px; align-items:flex-start;">

<div style="text-align:center; flex-shrink:0;">
  <img src="presentation/map_screenshot.png" style="height:440px; border-radius:16px; box-shadow:0 6px 20px rgba(0,0,0,0.18);">
</div>

<div style="flex:1; display:flex; flex-direction:column; gap:14px;">

<div>

**실시간 지도**

| 기술 | 역할 |
|---|---|
| **Google Maps SDK** | 지도 배경 표시 (타일 렌더링) |
| **OSRM** | 실제 도로 경로 계산 (선 그리기) |
| **Geolocator** | 내 현재 위치 좌표 가져오기 |

</div>

<div>

**고객센터 챗봇 (FAQ 키워드 매칭)**

| 키워드 | 안내 내용 |
|---|---|
| 취소·환불 | 예매 취소 방법·환불 정책 |
| 발권·QR | 모바일 발권 사용법 |
| 언어·language | 언어 변경 방법 |
| 회원가입·로그인 | 비회원 예매 가능 여부 |

- 빠른 질문 버튼 원터치 선택 · 4개 언어 전체 대응

</div>

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

<div class="good" style="margin-bottom:12px;">
✅ 동일 버스·날짜 → 항상 같은 좌석 배치 &nbsp;·&nbsp; 실 서비스 전환 시 이 함수만 교체하면 나머지 UI 그대로 동작
</div>

<div class="cols2">
<div class="warn">
  <strong>⚠️ 문제 2 — 에뮬레이터 GPS 불가</strong><br><br>
  <strong>문제 상황</strong><br>
  에뮬레이터는 실제 GPS 칩이 없어 위치 정보를 수신할 수 없음<br>
  → 수면 모드·지도 기능 테스트 불가
</div>
<div class="good">
  <strong>✅ 대응 방안 — 수동 좌표 입력</strong><br><br>
  Android Studio → 에뮬레이터 우측 <strong>⋮ → Location 탭</strong><br><br>
  <code>Latitude &nbsp;: 37.5665 (서울)</code><br>
  <code>Longitude : 126.9780</code><br><br>
  → Send 버튼으로 원하는 좌표 수동 전송
</div>
</div>

---

## ADR 요약

| # | 결정 항목 | 선택 | 핵심 이유 |
|---|---|---|---|
| ADR-001 | 크로스플랫폼 프레임워크 | **Flutter** | React Native는 네이티브 컴포넌트를 빌려 써 iOS·Android UI가 미묘하게 달라짐. Flutter는 자체 렌더링 엔진(Skia)으로 직접 그려 어떤 기기에서도 완전히 동일한 UI 제공 |
| ADR-002 | 버스 목록 정렬 기준 | **출발 시간순 고정** | 사용자가 사용하는 핵심 화면, 정렬 기준 확립 필요 → 가장 보기 편한 출발 시간순 정렬 고정 |
| ADR-003 | 실시간 좌석 조회 | **결정적 난수 시뮬레이션** | 독점으로 인한 공개 API 없음·B2B 불가 → seed 기반으로 일관성 확보 |
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

<div style="font-size:0.82em; color:#1a56db; font-weight:bold; margin-bottom:6px;">🤖 AI (Claude Code)</div>

**단위 테스트 — `flutter test`**

<div class="good" style="padding:8px 12px; line-height:1.9; font-size:0.88em;">

✅ HomeScreen 렌더링<br>
✅ BusListScreen 카드 렌더링<br>
✅ SeatSelectionScreen 좌석 배치도<br>
✅ BookingConfirmScreen 결제 UI<br>
<span style="color:#16a34a; font-weight:bold;">All tests passed!</span>

</div>

<br>

**통합 테스트 — E2E 시나리오**

<div class="good" style="padding:8px 12px; line-height:1.9; font-size:0.88em;">

✅ 앱 실행 → 홈 화면 정상 로딩<br>
✅ 터미널 선택 → 버스 목록 조회<br>
✅ 좌석 선택 → 결제 → 예매 완료<br>
✅ 네트워크 없음 → Mock 자동 전환

</div>

</div>
<div>

<div style="font-size:0.82em; color:#7c3aed; font-weight:bold; margin-bottom:6px;">👤 직접 수동 테스트</div>

**단위 테스트 — 화면별 기능 확인**

<div style="background:#f5f3ff; border-left:4px solid #7c3aed; border-radius:6px; padding:8px 12px; line-height:1.9; font-size:0.88em;">

✅ 예매 내역 QR 발권 확인<br>
✅ 언어 전환 한→영→중→일 전체 적용<br>
✅ 비로그인 예약 → 로그인 유도<br>
✅ 잘못된 카드 입력 → 유효성 오류

</div>

<br>

**통합 테스트 — 사용자 시나리오**

<div style="background:#f5f3ff; border-left:4px solid #7c3aed; border-radius:6px; padding:8px 12px; line-height:1.9; font-size:0.88em;">

✅ 서울남부 → 부산종합 전체 예매 흐름<br>
✅ 수면모드 ON → GPS 감지 → 진동 알림<br>
✅ 즐겨찾기 추가 → 재선택 확인<br>
✅ 쿠폰 적용 → 할인 금액 반영 확인

</div>

</div>
</div>

---

## 15. 활용 방안 & 기대 효과

<div class="cols3">
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.8em; margin-bottom:8px;">😴</div>
  <strong>수면 모드</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:6px;">수면모드로 목적지 놓침<br>걱정 없이 장거리 이동</p>
</div>
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.8em; margin-bottom:8px;">🗺️</div>
  <strong>지도 기능</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:6px;">위치를 확인하고 싶을 때<br>앱 내부에서 한번에 해결<br>번거로움 해소</p>
</div>
<div class="card" style="text-align:center; padding:14px;">
  <div style="font-size:1.8em; margin-bottom:8px;">🌏</div>
  <strong>외국인 관광객</strong>
  <p style="font-size:0.8em; color:#64748b; margin-top:6px;">4개국어 지원으로<br>언어 장벽 없이<br>시외버스 이용</p>
</div>
</div>

<br>

**기대 효과**

- 수면 모드로 **목적지 놓칠 걱정 없는** 장거리 이동 실현
- 지도·위치 확인을 **앱 하나로 해결** → 다른 앱 전환 번거로움 제거
- 한·영·중·일 4개국어로 **외국인 관광 접근성** 대폭 향상
- 예매 → 탑승 → 도착까지 **전 과정을 하나의 앱에서 완결**

---

## 16. AI Agent 활용

<div class="cols3">
<div>

**AI 협업 (Claude Code)**

기획부터 배포까지 전 과정에서 Claude Code와 함께 개발

- 코드 작성 · 버그 수정
- 문서 자동 작성 (ADR, WBS)
- 4개국어 번역
- 오류 분석 및 해결

</div>
<div>

**나만의 운영 방식**

`AGENTS.md` 파일 하나에 모두 정리

- AI 역할 정의
- 자주 쓰는 작업 절차화
- 해도 되는 것 / 하면 안 되는 것
- 자주 쓰는 명령어 모음
- 발표 대비 코드 이해 체크리스트

→ 파일 하나로 일관된 협업 유지

</div>
<div>

**개발 노트 (LLM Wiki)**

개발 중 겪은 문제와 해결법을 직접 기록

- 에뮬레이터 DNS 우회
- GPS 백그라운드 처리
- OSRM으로 지도 경로 해결
- 프롬프트 작성 노하우
- 총 12개 항목 정리

</div>
</div>

<!--
[대사]
AI를 단순히 코드 생성 도구로만 쓰지 않고, 기획부터 문서화까지 전 과정에서 활용했습니다.
AGENTS.md 파일 하나에 협업 규칙을 모두 정리해 일관성 있게 작업했고,
개발 중 마주친 문제들은 직접 LLM Wiki로 기록해 나만의 노하우로 만들었습니다.
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

**AI 협업 경험 & 개선 의지**

- Claude Code와 협업해 **프롬프트 설계·문서화·디버깅**을 자동화
- 막힌 문제마다 ADR로 기록 → **결정 근거를 문서화**하는 습관 형성
- AI가 생성한 코드도 직접 이해하고 설명할 수 있도록 **코드 이해 체크리스트** 운영

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
