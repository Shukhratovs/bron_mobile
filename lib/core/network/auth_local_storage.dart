import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalStorage {
  Future<void> saveAuthToken({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
  });

  Future<String?> getAccessToken();
  Future<String?> getTokenType();
  Future<void> saveUser(Map<String, dynamic> userMap);
  Future<Map<String, dynamic>?> getUser();
  Future<void> clear();
  bool get isLoggedIn;
  ValueListenable<bool> get authStateListenable;
}

class AuthLocalStorageImpl implements AuthLocalStorage {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyTokenType = 'auth_token_type';
  static const String _keyExpiresIn = 'auth_expires_in';
  static const String _keyUserData = 'auth_user_data';
  static const String _keyLocalAvatarPath = 'local_avatar_path';

  final SharedPreferences _prefs;
  final ValueNotifier<bool> _authStateNotifier;

  AuthLocalStorageImpl({required SharedPreferences prefs})
      : _prefs = prefs,
        _authStateNotifier = ValueNotifier<bool>(
          prefs.getString(_keyAccessToken) != null &&
              prefs.getString(_keyAccessToken)!.isNotEmpty,
        );

  static Future<AuthLocalStorageImpl> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthLocalStorageImpl(prefs: prefs);
  }

  @override
  bool get isLoggedIn => _authStateNotifier.value;

  @override
  ValueListenable<bool> get authStateListenable => _authStateNotifier;

  @override
  Future<void> saveAuthToken({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyTokenType, tokenType);
    await _prefs.setInt(_keyExpiresIn, expiresIn);
    _authStateNotifier.value = true;
  }

  @override
  Future<String?> getAccessToken() async {
    return _prefs.getString(_keyAccessToken);
  }

  @override
  Future<String?> getTokenType() async {
    return _prefs.getString(_keyTokenType);
  }

  @override
  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs.setString(_keyUserData, jsonEncode(userMap));
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    final raw = _prefs.getString(_keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyTokenType);
    await _prefs.remove(_keyExpiresIn);
    await _prefs.remove(_keyUserData);
    await _prefs.remove(_keyLocalAvatarPath);
    _authStateNotifier.value = false;
  }

  /// Profil rasmi uchun backend'da maydon/endpoint yo'q (tekshirildi —
  /// `UserOut`/`UserUpdate` sxemalarida `avatar`/`photo` maydoni yo'q),
  /// shuning uchun qurilmada tanlangan rasm faqat mahalliy saqlanadi:
  /// fayl ilova hujjatlar papkasiga nusxalanadi, shu YO'L esa shu yerda
  /// SharedPreferences'ga yoziladi. `clear()` (chiqish) bilan birga
  /// o'chadi — boshqa foydalanuvchi shu qurilmada kirsa eskisi
  /// ko'rinmasin.
  Future<void> saveLocalAvatarPath(String path) async {
    await _prefs.setString(_keyLocalAvatarPath, path);
  }

  Future<void> clearLocalAvatarPath() async {
    await _prefs.remove(_keyLocalAvatarPath);
  }

  String? get localAvatarPath => _prefs.getString(_keyLocalAvatarPath);
}
