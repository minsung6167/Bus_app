import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/terminal_model.dart';

class FavoriteProvider extends ChangeNotifier {
  static const _key = 'favorite_terminals_v2';
  final List<Terminal> _favorites = [];

  bool isFavorite(String id) => _favorites.any((t) => t.id == id);
  List<Terminal> get favoriteTerminals => List.unmodifiable(_favorites);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = json.decode(raw) as List;
        _favorites.addAll(list.map((e) {
          final m = e as Map<String, dynamic>;
          return Terminal(
            id: m['id'] as String,
            name: m['name'] as String,
            cityName: m['cityName'] as String,
          );
        }));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> toggle(Terminal terminal) async {
    final idx = _favorites.indexWhere((t) => t.id == terminal.id);
    if (idx != -1) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(terminal);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(_favorites
          .map((t) => {'id': t.id, 'name': t.name, 'cityName': t.cityName})
          .toList()),
    );
  }
}
