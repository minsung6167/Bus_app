import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _keyUsers = 'auth_users';
  static const _keyCurrentId = 'auth_current_id';

  User? _currentUser;
  bool _isInitializing = true;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitializing => _isInitializing;

  static const _seedEmail = 'minsung1408@naver.com';
  static const _seedId = 'seed_user_001';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 기본 계정이 없으면 자동 등록
    final users = _loadUsers(prefs);
    final hasSeed = users.any((u) => u.id == _seedId);
    if (!hasSeed) {
      users.add(User(
        id: _seedId,
        email: _seedEmail,
        password: '123456',
        name: '민성',
        phone: '010-0000-0000',
      ));
      await _saveUsers(prefs, users);
    }

    final currentId = prefs.getString(_keyCurrentId);
    if (currentId != null) {
      final updated = _loadUsers(prefs);
      try {
        _currentUser = updated.firstWhere((u) => u.id == currentId);
      } catch (_) {
        await prefs.remove(_keyCurrentId);
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  /// 로그인. 성공 시 null, 실패 시 에러 메시지 반환.
  Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    try {
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
      _currentUser = user;
      await prefs.setString(_keyCurrentId, user.id);
      notifyListeners();
      return null;
    } catch (_) {
      return 'loginFailed';
    }
  }

  /// 회원가입. 성공 시 null, 실패 시 에러 키 반환.
  Future<String?> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final exists = users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'emailExists';

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    users.add(newUser);
    await _saveUsers(prefs, users);
    _currentUser = newUser;
    await prefs.setString(_keyCurrentId, newUser.id);
    notifyListeners();
    return null;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return 'error';
    if (_currentUser!.password != currentPassword) return 'currentPwWrong';

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx == -1) return 'error';

    final updated = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      password: newPassword,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
    );
    users[idx] = updated;
    await _saveUsers(prefs, users);
    _currentUser = updated;
    notifyListeners();
    return null;
  }

  Future<String?> deleteAccount(String password) async {
    if (_currentUser == null) return 'error';
    if (_currentUser!.password != password) return 'currentPwWrong';

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    users.removeWhere((u) => u.id == _currentUser!.id);
    await _saveUsers(prefs, users);
    await prefs.remove(_keyCurrentId);
    _currentUser = null;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentId);
    _currentUser = null;
    notifyListeners();
  }

  List<User> _loadUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_keyUsers);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveUsers(SharedPreferences prefs, List<User> users) async {
    await prefs.setString(_keyUsers, json.encode(users.map((u) => u.toJson()).toList()));
  }
}
