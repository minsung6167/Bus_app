# 테스트 가이드

## 테스트 구조

```
test/
├── widget_test.dart        # 기본 위젯 테스트
└── (추가 예정)
```

---

## 테스트 실행

```bash
# 전체 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/widget_test.dart

# 커버리지 포함
flutter test --coverage
```

---

## 주요 테스트 항목

### 1. 위젯 테스트 (Widget Test)

| 대상 | 확인 내용 |
|---|---|
| `HomeScreen` | 출발/도착지 선택 버튼 렌더링 |
| `BusListScreen` | 버스 목록 카드 렌더링 |
| `SeatSelectionScreen` | 좌석 배치도 렌더링 |
| `BookingConfirmScreen` | 결제 수단 선택 UI 렌더링 |

### 2. 수동 테스트 시나리오

**핵심 흐름 (Happy Path)**
```
1. 앱 실행 → 홈 화면 확인
2. 출발지 "서울남부" 선택
3. 도착지 "부산종합" 선택
4. 날짜 선택 → 버스 목록 조회
5. 버스 선택 → 좌석 선택
6. 결제 화면 → 일반카드 선택 → 카드 정보 입력
7. 예약 완료 확인
8. 예매 내역에서 예약 확인
```

**엣지 케이스**
```
- 네트워크 없을 때 → fallback 데이터 표시 확인
- 비로그인 상태에서 예약 시도 → 로그인 유도 확인
- 잘못된 카드 번호 입력 → 유효성 오류 메시지 확인
- 언어 전환 (한→영→중→일) → 전체 화면 번역 확인
```

---

## 분석 (정적 검사)

```bash
flutter analyze
```

현재 기준: 경고 0건 유지 목표

---

## 배포 전 체크리스트

- [ ] `flutter analyze` 경고 0건
- [ ] `flutter test` 전체 통과
- [ ] Android 기기 실물 테스트
- [ ] 4개 언어 전환 확인 (한/영/중/일)
- [ ] 오프라인 환경 fallback 동작 확인
- [ ] 예약 전체 흐름 1회 완주
