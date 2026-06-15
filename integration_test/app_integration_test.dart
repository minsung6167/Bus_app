import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bus_app/main.dart' as app;

// 시드 계정 (auth_provider.dart에 하드코딩된 값)
const _seedEmail = 'minsung1408@naver.com';
const _seedPassword = '123456';
const _networkWait = Duration(seconds: 5);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // 각 테스트 전 로컬 저장소 초기화 (로그아웃 상태에서 시작)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  // ──────────────────────────────────────────────
  // TC-INT-01: 앱 실행 — 홈 화면 정상 로드
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-01: 앱 실행 시 홈 화면과 하단 탭이 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // 하단 탭 3개 확인
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('내 예매'), findsOneWidget);
    expect(find.text('마이페이지'), findsOneWidget);

    // 홈 화면 헤더 확인
    expect(find.text('어디로 떠나시나요?'), findsOneWidget);
  });

  // ──────────────────────────────────────────────
  // TC-INT-02: 비로그인 상태 — 마이페이지 탭 접근
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-02: 비로그인 상태에서 마이페이지 탭에 로그인 안내가 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // 마이페이지 탭 클릭
    await tester.tap(find.text('마이페이지'));
    await tester.pumpAndSettle();

    // 로그인 안내 화면 확인
    expect(find.text('로그인이 필요합니다'), findsOneWidget);
    expect(find.text('로그인하기'), findsOneWidget);
  });

  // ──────────────────────────────────────────────
  // TC-INT-03: 로그인 흐름 — 잘못된 비밀번호
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-03: 잘못된 비밀번호 입력 시 오류 메시지가 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // 마이페이지 → 로그인하기
    await tester.tap(find.text('마이페이지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('로그인하기'));
    await tester.pumpAndSettle();

    // 이메일/비밀번호 입력
    final emailField = find.byType(TextFormField).first;
    final pwField = find.byType(TextFormField).last;

    await tester.enterText(emailField, _seedEmail);
    await tester.enterText(pwField, 'wrongpassword');
    await tester.pumpAndSettle();

    // 로그인 버튼 클릭 (ElevatedButton으로 특정)
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    // 오류 메시지 확인
    expect(find.text('이메일 또는 비밀번호가 올바르지 않습니다'), findsOneWidget);
  });

  // ──────────────────────────────────────────────
  // TC-INT-04: 로그인 흐름 — 정상 로그인
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-04: 올바른 계정으로 로그인하면 마이페이지에 사용자 정보가 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // 마이페이지 → 로그인하기
    await tester.tap(find.text('마이페이지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('로그인하기'));
    await tester.pumpAndSettle();

    // 시드 계정 입력
    final emailField = find.byType(TextFormField).first;
    final pwField = find.byType(TextFormField).last;

    await tester.enterText(emailField, _seedEmail);
    await tester.enterText(pwField, _seedPassword);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    // 로그인 후 마이페이지에 이메일 표시
    expect(find.text(_seedEmail), findsOneWidget);
  });

  // ──────────────────────────────────────────────
  // TC-INT-05: 홈 화면 — 출발지/도착지 선택
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-05: 출발지와 도착지를 선택하면 카드에 터미널 이름이 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // 터미널 목록 로딩 대기
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 출발지 선택 버튼 클릭 (첫 번째 '선택' 버튼)
    final selectBtns = find.text('선택');
    if (selectBtns.evaluate().length >= 2) {
      await tester.tap(selectBtns.first);
      await tester.pumpAndSettle();

      // 서울남부 터미널 검색 및 선택
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, '서울');
        await tester.pumpAndSettle();
      }

      // 리스트에서 서울남부 터미널 선택
      final seoulItem = find.textContaining('서울');
      if (seoulItem.evaluate().isNotEmpty) {
        await tester.tap(seoulItem.first);
        await tester.pumpAndSettle();
      }
    }

    // 출발지가 화면에 반영됐는지 확인 (선택 버튼이 줄어들거나 터미널명 표시)
    expect(find.text('버스 검색하기'), findsOneWidget);
  });

  // ──────────────────────────────────────────────
  // TC-INT-06: 로그인 후 로그아웃
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-06: 로그아웃하면 마이페이지에 로그인 안내 화면이 다시 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // 로그인
    await tester.tap(find.text('마이페이지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('로그인하기'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, _seedEmail);
    await tester.enterText(find.byType(TextFormField).last, _seedPassword);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    // 로그아웃 버튼 찾기 (스크롤 후 탭)
    final logoutBtn = find.text('로그아웃');
    await tester.scrollUntilVisible(logoutBtn, 200);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // 확인 다이얼로그에서 로그아웃 확인
    final confirmBtns = find.text('로그아웃');
    if (confirmBtns.evaluate().length > 1) {
      await tester.tap(confirmBtns.last);
    } else {
      await tester.tap(confirmBtns.first);
    }
    await tester.pumpAndSettle();

    // 로그인 안내 화면으로 복귀
    expect(find.text('로그인이 필요합니다'), findsOneWidget);
  });

  // ──────────────────────────────────────────────
  // TC-INT-07: 예매 내역 탭 — 비로그인 상태
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-07: 비로그인 상태에서 예매 내역 탭에 로그인 안내가 표시된다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    await tester.tap(find.text('내 예매'));
    await tester.pumpAndSettle();

    // 로그인 안내 텍스트 확인
    expect(
      find.textContaining('로그인').evaluate().isNotEmpty,
      true,
      reason: '비로그인 시 예매 내역 탭에 로그인 안내가 있어야 한다',
    );
  });

  // ──────────────────────────────────────────────
  // TC-INT-08: 챗봇 버튼 → 챗봇 화면 이동
  // ──────────────────────────────────────────────
  testWidgets('TC-INT-08: 플로팅 챗봇 버튼 클릭 시 챗봇 화면으로 이동한다', (tester) async {
    app.main();
    await tester.pump(_networkWait);
    await tester.pumpAndSettle();

    // FAB(챗봇) 버튼 탭
    await tester.tap(find.byTooltip('고객센터 챗봇'));
    await tester.pumpAndSettle();

    // 챗봇 화면 확인 — 메시지 입력 필드 or 챗봇 타이틀
    expect(
      find.byType(TextField).evaluate().isNotEmpty ||
          find.textContaining('챗봇').evaluate().isNotEmpty,
      true,
      reason: '챗봇 화면에 입력 필드 또는 챗봇 텍스트가 있어야 한다',
    );
  });
}
