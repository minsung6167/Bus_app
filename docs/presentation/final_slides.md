---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: 'Noto Sans KR', sans-serif;
    font-size: 22px;
  }
  h1 { color: #1a56db; font-size: 2em; }
  h2 { color: #1a56db; border-bottom: 2px solid #1a56db; padding-bottom: 6px; }
  table { width: 100%; font-size: 0.85em; }
  th { background: #1a56db; color: white; }
  code { font-size: 0.8em; }
  .tag { background:#1a56db; color:white; border-radius:4px; padding:2px 8px; font-size:0.8em; }
---

# 시외버스 통합 예약 앱
### 최종 발표

최민성 | 신구대학교 | 2026-05-31

---

## 01. 주제 선택 계기

> **"시외버스를 타고 가다 보면, 지금 어디쯤 왔는지 궁금한데**
> **지도 앱을 따로 켜야 하는 번거로움이 있었다."**

<br>

- 이동시간이 긴 시외버스 특성상 **현재 위치 확인 수요** 높음
- 기존 앱은 예매 기능만 제공 → **위치 확인은 별도 앱** 필요
- → **앱 자체에서 현재 위치 · 출발지 · 도착지를 한 번에 확인**할 수 있는 서비스 구현

---

## 02. 해결하려는 문제

| 문제 | 기존 방식 | 우리 앱 |
|---|---|---|
| 현재 위치 확인 | 지도 앱 별도 실행 | 앱 내 지도 (구현 예정) |
| 수면 중 도착역 놓침 | 알람 직접 설정 | GPS 수면 모드 자동 알림 |
| 외국인 이용 불편 | 한국어 전용 | 한·영·중·일 4개국어 |
| 여러 앱 분산 | 터미널사별 앱 따로 | 통합 예약·조회·발권 |

---

## 03. 핵심 기능 전체 목록

| 기능 | 상태 |
|---|---|
| 터미널 검색 + 버스 조회 (공공 API) | ✅ 완료 |
| 좌석 선택 (시뮬레이션) + 혼잡도 예측 | ✅ 완료 |
| 결제 흐름 + 모바일 발권 (QR코드) | ✅ 완료 |
| 예매 내역 · 티켓 상세 조회 | ✅ 완료 |
| GPS 기반 수면 모드 (백그라운드) | ✅ 완료 |
| 회원 가입 · 로그인 · 아이디/비밀번호 찾기 | ✅ 완료 |
| 마이페이지 · 내 정보 수정 · 프로필 사진 | ✅ 완료 |
| 즐겨찾기 터미널 | ✅ 완료 |
| 고객센터 챗봇 | ✅ 완료 |
| 공지사항 · 이벤트 · 쿠폰 | ✅ 완료 |
| 4개국어 전환 (한·영·중·일) | ✅ 완료 |
| 지도 기능 (현재 위치 + 경로) | 🔜 구현 예정 |

---

## 04. 기술 스택

```
Flutter 3.41 (Dart)
├── Provider + ChangeNotifier   상태 관리
├── SharedPreferences           로컬 저장 (인증·즐겨찾기)
├── geolocator                  GPS 위치 추적
├── flutter_foreground_task     백그라운드 서비스 (수면 모드)
├── qr_flutter                  QR코드 생성 (모바일 발권)
├── image_picker                프로필 사진 선택
├── http + flutter_dotenv       공공 API 연동 + 환경변수
└── vibration                   도착 알림 진동
```

공공데이터포털 시외버스 운행정보 API + fallback mock 데이터

---

## 05. 아키텍처

```
사용자 입력
    │
    ▼
Screens / Widgets (UI)
    │ context.read / context.watch
    ▼
Providers (상태 관리)
    ├──▶ Services ──▶ 공공 API (data.go.kr)
    │              └▶ mock_data.dart (fallback)
    └──▶ SharedPreferences (영속 저장)

별도 서비스
└── SleepModeTask (flutter_foreground_task)
        └── Geolocator → 15초마다 GPS 위치 체크
```

---

## 06. 화면 구성

```
MainScreen (하단 탭 3개)
├── 홈 — 터미널 검색 → 버스 목록 → 좌석 선택 → 결제 → 완료
├── 내 예매 — 예정된 여행 / 지난 여행
│              └── 티켓 상세 (QR코드 + 수면모드 + 지도)
└── 마이페이지 — 내 정보 수정 · 프로필 사진
                  ├── 즐겨찾기 / 쿠폰 / 공지 / 이벤트
                  └── 언어 설정 / 로그아웃

로그인 화면
├── 회원가입
└── 아이디 / 비밀번호 찾기
```

---

## 07. 핵심 구현 — GPS 수면 모드

**"자다가 목적지 근처에 오면 자동으로 깨워준다"**

```dart
// 백그라운드에서 15초마다 실행
void onRepeatEvent(DateTime timestamp) async {
  final pos = await Geolocator.getCurrentPosition(...);
  final dist = Geolocator.distanceBetween(
    pos.latitude, pos.longitude, _destLat!, _destLng!,
  );
  if (dist <= _alertMeters) {
    FlutterForegroundTask.sendDataToMain({'action': 'wake_up'});
  }
}
```

- 화면 꺼진 상태에서도 동작 (Foreground Service)
- 2km / 5km / 10km 전 알림 선택 가능
- 도착 시 **강한 진동**으로 깨워줌

---

## 08. 핵심 구현 — 좌석 시뮬레이션

```dart
// 실시간 좌석 API 미지원 (독점 유료 서비스)
// → 결정적 난수(seed)로 일관된 좌석 상태 생성
List<SeatStatus> generateSeats(String busId, String date) {
  final seed = int.parse(busId.replaceAll(RegExp(r'\D'), ''))
             + date.hashCode;
  final rng = Random(seed);
  return List.generate(28, (_) =>
    rng.nextDouble() < 0.4 ? SeatStatus.occupied : SeatStatus.available);
}
```

같은 버스·날짜면 항상 동일한 좌석 배치 → **일관성 유지**

---

## 09. 핵심 구현 — 모바일 발권 QR코드

```dart
QrImageView(
  data: '${booking.id}|${booking.bus.from}|${booking.bus.to}|'
      '${DateFormat('yyyy-MM-dd HH:mm').format(booking.bus.departureTime)}|'
      '${booking.seats.join(',')}|${booking.passengerName}',
  version: QrVersions.auto,
  size: 180,
)
```

- 예매 정보를 QR코드로 인코딩
- 티켓 상세 화면에서 즉시 확인 가능
- 현장 발권 없이 탑승 가능

---

## 10. 구현 예정 — 지도 기능

**주제 선택의 핵심 동기: "앱 하나로 현재 위치 확인"**

```
계획된 지도 기능
├── 현재 위치 실시간 표시 (geolocator 이미 연동)
├── 출발지 터미널 핀 표시
├── 도착지 터미널 핀 표시
└── 이동 경로 시각화
```

- `geolocator` 패키지 이미 설치 완료
- 티켓 상세 화면에 **지도 버튼** 배치 완료
- 구현 기술: `flutter_map` (OpenStreetMap, 무료)

---

## 11. 진행 현황

```
10주차  ✅  기획 · 일정 수립
11주차  ✅  설계 · 환경 구성
12주차  ✅  핵심 기능 완성 (중간 발표)
13주차  ✅  GPS 수면 모드 · 챗봇 · QR발권
14주차  ✅  마이페이지 고도화 · UX 개선
15주차  🔜  지도 기능 · 최종 발표  ← 현재
```

Must 기능 **100%** 완료 / Should 기능 대부분 완료

---

## 12. 데모 순서

1. **버스 검색** — 서울 → 부산, 날짜 선택 (커스텀 캘린더)
2. **좌석 선택** — 혼잡도 확인 + 좌석 선택
3. **결제** — 카드 정보 입력 → QR코드 발급
4. **티켓 상세** — QR코드 확인 + 수면 모드 설정
5. **수면 모드** — GPS 알림 설정 시연
6. **마이페이지** — 프로필 사진 · 내 정보 수정
7. **언어 전환** — 한 → EN → 中 → 日

---

## 감사합니다

**GitHub**: https://github.com/minsung6167/Bus_app

**문의**: minsung1408@g.shingu.ac.kr

> "버스 안에서 지도 앱을 따로 켜지 않아도 되는 앱"
