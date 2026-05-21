---
marp: true
theme: default
paginate: true
---

# 시외버스 예약 앱
### 중간 발표 (12주차)

최민성 | 신구대학교 | 2026-05-21

---

## 01. 프로젝트 개요

- **주제**: 시외버스 통합 예약 앱 (Flutter)
- **목표**: 내·외국인 모두 쉽게 쓸 수 있는 한/영/중/일 4개국어 예약 서비스
- **기간**: 10주차 ~ 15주차 (6주)

---

## 02. 해결하려는 문제

- 기존 고속버스 앱은 **한국어 전용** → 외국인 관광객 불편
- 여러 터미널사 앱이 **분산** → 하나로 조회 불가
- 좌석 선택 UI가 복잡하거나 **모바일 최적화 미흡**

---

## 03. 핵심 기능 (Must Have)

| 기능 | 상태 |
|---|---|
| 터미널 검색 + 버스 조회 | ✅ 완료 |
| 좌석 선택 (시뮬레이션) | ✅ 완료 |
| 예약 확인 / 결제 흐름 | ✅ 완료 |
| 예매 내역 조회 | ✅ 완료 |
| 4개국어 전환 | ✅ 완료 |

---

## 04. 기술 스택

```
Flutter 3.x (Dart)
├── Provider + ChangeNotifier  (상태 관리)
├── SharedPreferences          (로컬 저장)
├── http                       (공공 API)
└── flutter_dotenv             (환경변수)
```

공공데이터포털 시외버스 운행정보 API 연동 + fallback mock 데이터

---

## 05. 아키텍처

```
Screens → Providers → Services → 공공 API
                  ↘ SharedPreferences
```

- **레이어 분리**: UI / 상태 / 서비스 / 모델
- **Fallback 전략**: API 실패 시 로컬 mock_data.dart 자동 전환

---

## 06. 핵심 구현 — 지역 분류 보정

```dart
// 공공 API의 cityName "광주"는 경기·전라 두 곳에 모두 존재
// → 터미널명 prefix로 실제 지역 판별
String _resolveRegion(String cityName, String terminalName) {
  if (cityName == '광주' && terminalName.startsWith('경기')) {
    return '경기';
  }
  return cityName;
}
```

API 데이터 맹신 금지 → 실제 출력값 검증 후 보정 로직 추가

---

## 07. 핵심 구현 — 좌석 시뮬레이션

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

---

## 08. 진행 현황

```
10주차 ✅ 기획·일정
11주차 ✅ 설계·환경 (Flutter 앱 빌드 가능)
12주차 ✅ 핵심 기능 완성 ← 현재
13주차 ⬜ 소셜 로그인 / 테스트
14주차 ⬜ 마감·배포·문서
15주차 ⬜ 최종 발표
```

Must 기능 100% 완료, Should 기능 진행 중

---

## 09. 남은 과제 & 위험

| 항목 | 대응 |
|---|---|
| 카카오/네이버 SDK 연동 | 기한 내 어려우면 이메일 로그인만 제출 |
| 기말고사 2주 공백 | Must 기능 완료 후 잠금 → 시험 후 재개 |
| 발표 네트워크 장애 | 오프라인 fallback 데이터 활성화로 대비 |

---

## 10. 데모

> 앱 직접 시연

1. 서울 → 부산 버스 검색
2. 좌석 선택
3. 예약 확인 화면
4. 언어 전환 (한 → EN → 中 → 日)

---

## 감사합니다

**GitHub**: https://github.com/minsung6167/Bus_app

**문의**: minsung1408@g.shingu.ac.kr
