import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class CardProvider extends ChangeNotifier {
  static const _key = 'payment_cards_v1';
  static const _defaultKey = 'payment_cards_default';
  final List<PaymentCard> _cards = [];
  String? _defaultCardId;

  List<PaymentCard> get cards => List.unmodifiable(_cards);
  String? get defaultCardId => _defaultCardId;
  PaymentCard? get defaultCard =>
      _cards.isEmpty ? null : _cards.firstWhere(
        (c) => c.id == _defaultCardId,
        orElse: () => _cards.first,
      );

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = json.decode(raw) as List;
      _cards.addAll(list.map((e) => PaymentCard.fromJson(e as Map<String, dynamic>)));
    }
    _defaultCardId = prefs.getString(_defaultKey);
    if (_cards.isNotEmpty && _defaultCardId == null) {
      _defaultCardId = _cards.first.id;
    }
    notifyListeners();
  }

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultKey, id);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(_cards.map((c) => c.toJson()).toList()));
    if (_defaultCardId != null) {
      await prefs.setString(_defaultKey, _defaultCardId!);
    }
  }
}
