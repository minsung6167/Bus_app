import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bus_app/providers/auth_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthProvider 단위 테스트', () {
    test('init — 초기화 후 isInitializing이 false가 된다', () async {
      final provider = AuthProvider();
      expect(provider.isInitializing, true);
      await provider.init();
      expect(provider.isInitializing, false);
    });

    test('init — 초기화 후 로그인 상태가 아니다', () async {
      final provider = AuthProvider();
      await provider.init();
      expect(provider.isLoggedIn, false);
      expect(provider.currentUser, isNull);
    });

    test('login — 시드 계정으로 로그인에 성공한다', () async {
      final provider = AuthProvider();
      await provider.init();

      final result = await provider.login('minsung1408@naver.com', '123456');
      expect(result, isNull); // null = 성공
      expect(provider.isLoggedIn, true);
      expect(provider.currentUser?.email, 'minsung1408@naver.com');
    });

    test('login — 잘못된 비밀번호로 로그인에 실패한다', () async {
      final provider = AuthProvider();
      await provider.init();

      final result = await provider.login('minsung1408@naver.com', 'wrongpassword');
      expect(result, 'loginFailed');
      expect(provider.isLoggedIn, false);
    });

    test('login — 존재하지 않는 이메일로 로그인에 실패한다', () async {
      final provider = AuthProvider();
      await provider.init();

      final result = await provider.login('nobody@test.com', '123456');
      expect(result, 'loginFailed');
      expect(provider.isLoggedIn, false);
    });

    test('login — 이메일 대소문자 구분 없이 로그인된다', () async {
      final provider = AuthProvider();
      await provider.init();

      final result = await provider.login('MINSUNG1408@NAVER.COM', '123456');
      expect(result, isNull);
      expect(provider.isLoggedIn, true);
    });

    test('signup — 신규 계정 가입에 성공한다', () async {
      final provider = AuthProvider();
      await provider.init();

      final result = await provider.signup(
        email: 'newuser@test.com',
        password: 'pass1234',
        name: '홍길동',
        phone: '010-1111-2222',
      );
      expect(result, isNull);
    });

    test('signup — 중복 이메일로 가입에 실패한다', () async {
      final provider = AuthProvider();
      await provider.init();

      await provider.signup(
        email: 'dup@test.com',
        password: 'pass1234',
        name: '홍길동',
        phone: '010-1111-2222',
      );

      final result = await provider.signup(
        email: 'dup@test.com',
        password: 'other1234',
        name: '이름',
        phone: '010-3333-4444',
      );
      expect(result, 'emailExists');
    });

    test('signup 후 로그인이 성공한다', () async {
      final provider = AuthProvider();
      await provider.init();

      await provider.signup(
        email: 'test@test.com',
        password: 'mypassword',
        name: '테스트',
        phone: '010-9999-0000',
      );

      final result = await provider.login('test@test.com', 'mypassword');
      expect(result, isNull);
      expect(provider.isLoggedIn, true);
    });

    test('logout — 로그인 후 로그아웃 시 isLoggedIn이 false가 된다', () async {
      final provider = AuthProvider();
      await provider.init();
      await provider.login('minsung1408@naver.com', '123456');
      expect(provider.isLoggedIn, true);

      await provider.logout();
      expect(provider.isLoggedIn, false);
      expect(provider.currentUser, isNull);
    });

    test('changePassword — 올바른 현재 비밀번호로 변경 성공한다', () async {
      final provider = AuthProvider();
      await provider.init();
      await provider.login('minsung1408@naver.com', '123456');

      final result = await provider.changePassword(
        currentPassword: '123456',
        newPassword: 'newpass999',
      );
      expect(result, isNull);

      // 새 비밀번호로 로그인 확인
      await provider.logout();
      final loginResult = await provider.login('minsung1408@naver.com', 'newpass999');
      expect(loginResult, isNull);
    });

    test('changePassword — 잘못된 현재 비밀번호로 변경 실패한다', () async {
      final provider = AuthProvider();
      await provider.init();
      await provider.login('minsung1408@naver.com', '123456');

      final result = await provider.changePassword(
        currentPassword: 'wrongpass',
        newPassword: 'newpass999',
      );
      expect(result, 'currentPwWrong');
    });

    test('findEmail — 이름+전화번호로 이메일을 찾는다', () async {
      final provider = AuthProvider();
      await provider.init();

      await provider.signup(
        email: 'find@test.com',
        password: 'pass',
        name: '찾기테스트',
        phone: '010-5555-6666',
      );

      final email = await provider.findEmail(name: '찾기테스트', phone: '010-5555-6666');
      expect(email, 'find@test.com');
    });

    test('findEmail — 존재하지 않으면 null을 반환한다', () async {
      final provider = AuthProvider();
      await provider.init();

      final email = await provider.findEmail(name: '없는사람', phone: '010-0000-0000');
      expect(email, isNull);
    });
  });
}
