import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _keyUsers = 'auth_users';
  static const _keyCurrentId = 'auth_current_id';
  static const _keyProfileImage = 'profile_image_path';

  User? _currentUser;
  bool _isInitializing = true;
  String? _profileImagePath;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitializing => _isInitializing;
  String? get profileImagePath => _profileImagePath;

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

    _profileImagePath = prefs.getString(_keyProfileImage);

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

  /// 이름·연락처·이메일 수정. 성공 시 null, 실패 시 에러 키 반환.
  Future<String?> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    if (_currentUser == null) return 'error';
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    // 이메일 중복 체크 (본인 제외)
    final emailExists = users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase().trim() && u.id != _currentUser!.id,
    );
    if (emailExists) return 'emailExists';

    final idx = users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx == -1) return 'error';

    final updated = User(
      id: _currentUser!.id,
      email: email.trim(),
      password: _currentUser!.password,
      name: name.trim(),
      phone: phone.trim(),
    );
    users[idx] = updated;
    await _saveUsers(prefs, users);
    _currentUser = updated;
    notifyListeners();
    return null;
  }

  /// 이름+전화번호로 이메일 찾기. 찾으면 이메일 반환, 없으면 null.
  Future<String?> findEmail({required String name, required String phone}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    try {
      final user = users.firstWhere(
        (u) => u.name == name.trim() && u.phone == phone.trim(),
      );
      return user.email;
    } catch (_) {
      return null;
    }
  }

  /// 이메일+전화번호로 비밀번호 재설정. 성공 시 null, 실패 시 에러 키 반환.
  Future<String?> resetPassword({
    required String email,
    required String phone,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase().trim() && u.phone == phone.trim(),
    );
    if (idx == -1) return 'findAccountFailed';

    final updated = User(
      id: users[idx].id,
      email: users[idx].email,
      password: newPassword,
      name: users[idx].name,
      phone: users[idx].phone,
    );
    users[idx] = updated;
    await _saveUsers(prefs, users);
    if (_currentUser?.id == updated.id) {
      _currentUser = updated;
      notifyListeners();
    }
    return null;
  }

  Future<void> updateProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileImage, path);
    _profileImagePath = path;
    notifyListeners();
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
