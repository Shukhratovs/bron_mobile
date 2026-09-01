import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/auth_local_storage.dart';

/// Xostes ilovasining o'z sessiyasi — mijoz ilovasining `AuthLocalStorage`
/// interfeysini implement qiladi (shu bilan mavjud `StandardApiClient`
/// o'zgarishsiz qayta ishlatiladi), lekin alohida `shared_preferences`
/// kalitlarida saqlanadi (ikkalasi bir qurilmada ishlasa ham sessiyalar
/// aralashmasin).
class StaffLocalStorage implements AuthLocalStorage {
  static const _keyAccessToken = 'staff_access_token';
  static const _keyTokenType = 'staff_token_type';
  static const _keyExpiresIn = 'staff_expires_in';
  static const _keyRole = 'staff_role';
  static const _keyOrganizationId = 'staff_organization_id';
  static const _keyVenueId = 'staff_venue_id';
  static const _keySelectedVenueId = 'staff_selected_venue_id';

  final SharedPreferences _prefs;
  final ValueNotifier<bool> _authStateNotifier;

  StaffLocalStorage({required SharedPreferences prefs})
      : _prefs = prefs,
        _authStateNotifier = ValueNotifier<bool>(
          (prefs.getString(_keyAccessToken) ?? '').isNotEmpty,
        );

  static Future<StaffLocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StaffLocalStorage(prefs: prefs);
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

  Future<void> saveStaffMeta({
    required String role,
    required String organizationId,
    required String? venueId,
  }) async {
    await _prefs.setString(_keyRole, role);
    await _prefs.setString(_keyOrganizationId, organizationId);
    if (venueId != null) {
      await _prefs.setString(_keyVenueId, venueId);
      await _prefs.setString(_keySelectedVenueId, venueId);
    }
  }

  String? get role => _prefs.getString(_keyRole);
  String? get organizationId => _prefs.getString(_keyOrganizationId);

  String? get selectedVenueId => _prefs.getString(_keySelectedVenueId);

  Future<void> setSelectedVenueId(String venueId) async {
    await _prefs.setString(_keySelectedVenueId, venueId);
  }

  @override
  Future<String?> getAccessToken() async => _prefs.getString(_keyAccessToken);

  @override
  Future<String?> getTokenType() async => _prefs.getString(_keyTokenType);

  @override
  Future<void> saveUser(Map<String, dynamic> userMap) async {}

  @override
  Future<Map<String, dynamic>?> getUser() async => null;

  @override
  Future<void> clear() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyTokenType);
    await _prefs.remove(_keyExpiresIn);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyOrganizationId);
    await _prefs.remove(_keyVenueId);
    await _prefs.remove(_keySelectedVenueId);
    _authStateNotifier.value = false;
  }
}
