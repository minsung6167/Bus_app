import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class CardProvider extends ChangeNotifier {
  final List<PaymentCard> _cards = [];
  String? _defaultCardId;
  String? _userId;

  static String _cardsKey(String uid) => 'payment_cards_$uid';
  static String _defaultKey(String uid) => 'payment_cards_default_$uid';

  List<PaymentCard> get cards => List.unmodifiable(_cards);
  String? get defaultCardId => _defaultCardId;
  PaymentCard? get defaultCard =>
      _cards.isEmpty ? null : _cards.firstWhere(
        (c) => c.id == _defaultCardId,
        orElse: () => _cards.first,
      );

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardsKey(userId));
    final loaded = <PaymentCard>[];
    if (raw != null) {
      final list = json.decode(raw) as List;
      loaded.addAll(list.map((e) => PaymentCard.fromJson(e as Map<String, dynamic>)));
    }
    _cards
      ..clear()
      ..addAll(loaded);
    _defaultCardId = prefs.getString(_defaultKey(userId));
    if (_cards.isNotEmpty && _defaultCardId == null) {
      _defaultCardId = _cards.first.id;
    }
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _cards.clear();
    _defaultCardId = null;
    notifyListeners();
  }

  // 기존 init() 호환용
  Future<void> init() async {}

  Future<void> addCard(PaymentCard card) async {
    _cards.add(card);
    _defaultCardId ??= card.id;
    notifyListeners();
    await _save();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    if (_defaultCardId == id) {
      _defaultCardId = _cards.isNotEmpty ? _cards.first.id : null;
    }
    notifyListeners();
    await _save();
  }

  Future<void> setDefault(String id) async {
    _defaultCardId = id;
    notifyListeners();
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultKey(_userId!), id);
  }

  Future<void> _save() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardsKey(_userId!), json.encode(_cards.map((c) => c.toJson()).toList()));
    if (_defaultCardId != null) {
      await prefs.setString(_defaultKey(_userId!), _defaultCardId!);
    }
  }
}
