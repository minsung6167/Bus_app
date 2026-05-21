import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _langCode = 'ko';

  String get langCode => _langCode;

  void setLanguage(String code) {
    if (_langCode != code) {
      _langCode = code;
      notifyListeners();
    }
  }

  static const languages = [
    {'code': 'ko', 'label': '한국어', 'flag': '🇰🇷'},
    {'code': 'en', 'label': 'English', 'flag': '🇺🇸'},
    {'code': 'zh', 'label': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'label': '日本語', 'flag': '🇯🇵'},
  ];
}
