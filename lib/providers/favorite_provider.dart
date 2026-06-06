import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/terminal_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Terminal> _favorites = [];
  String? _userId;

  static String _key(String uid) => 'favorites_$uid';

  bool isFavorite(String id) => _favorites.any((t) => t.id == id);
  List<Terminal> get favoriteTerminals => List.unmodifiable(_favorites);

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    final loaded = <Terminal>[];
    if (raw != null) {
      try {
        final list = json.decode(raw) as List;
        loaded.addAll(list.map((e) {
          final m = e as Map<String, dynamic>;
          return Terminal(
            id: m['id'] as String,
            name: m['name'] as String,
            cityName: m['cityName'] as String,
          );
        }));
      } catch (_) {}
    }
    _favorites
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _favorites.clear();
    notifyListeners();
  }

  // 기존 init() 호환용
  Future<void> init() async {}

  Future<void> toggle(Terminal terminal) async {
    final idx = _favorites.indexWhere((t) => t.id == terminal.id);
    if (idx != -1) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(terminal);
    }
    notifyListeners();
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(_userId!),
      json.encode(_favorites
          .map((t) => {'id': t.id, 'name': t.name, 'cityName': t.cityName})
          .toList()),
    );
  }
}
