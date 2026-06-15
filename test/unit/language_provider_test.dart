import 'package:test/test.dart';
import 'package:bus_app/providers/language_provider.dart';

void main() {
  group('LanguageProvider 단위 테스트', () {
    test('기본 언어는 한국어(ko)이다', () {
      final provider = LanguageProvider();
      expect(provider.langCode, 'ko');
    });

    test('setLanguage — 영어로 변경된다', () {
      final provider = LanguageProvider();
      provider.setLanguage('en');
      expect(provider.langCode, 'en');
    });

    test('setLanguage — 중국어로 변경된다', () {
      final provider = LanguageProvider();
      provider.setLanguage('zh');
      expect(provider.langCode, 'zh');
    });

    test('setLanguage — 일본어로 변경된다', () {
      final provider = LanguageProvider();
      provider.setLanguage('ja');
      expect(provider.langCode, 'ja');
    });

    test('setLanguage — 한→영→중→일 순서로 전환이 가능하다', () {
      final provider = LanguageProvider();
      final codes = ['en', 'zh', 'ja', 'ko'];
      for (final code in codes) {
        provider.setLanguage(code);
        expect(provider.langCode, code);
      }
    });

    test('setLanguage — 같은 언어 설정 시 변경되지 않는다', () {
      final provider = LanguageProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setLanguage('ko'); // 이미 ko
      expect(notifyCount, 0);
    });

    test('setLanguage — 다른 언어 설정 시 notifyListeners가 호출된다', () {
      final provider = LanguageProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setLanguage('en');
      expect(notifyCount, 1);
    });

    test('지원 언어 목록이 4개이다 (ko, en, zh, ja)', () {
      final codes = LanguageProvider.languages.map((l) => l['code']).toSet();
      expect(codes, containsAll(['ko', 'en', 'zh', 'ja']));
      expect(LanguageProvider.languages.length, 4);
    });
  });
}
