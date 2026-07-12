import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  const SessionManager._();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _accountCacheKeys = [
    'profile',
    'user',
    'user_id',
    'pasien_id',
    'booking',
    'active_booking',
    'history',
    'payment',
    'selected_doctor',
    'selected_schedule',
    'payment_method',
    'local_bookings',
  ];

  static String? token;
  static Map<String, dynamic>? user;
  static bool _loaded = false;

  static bool get hasSession => token != null && token!.isNotEmpty;

  static String getDisplayName() {
    final currentUser = user;
    if (currentUser == null) return 'Pasien';

    for (final key in ['name', 'nama', 'nama_lengkap', 'username', 'email']) {
      final value = currentUser[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return 'Pasien';
  }

  static Future<void> load() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);

    final rawUser = prefs.getString(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map) {
          user = decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } on FormatException {
        user = null;
      }
    }

    _loaded = true;
  }

  static Future<void> save({
    required String newToken,
    required Map<String, dynamic> newUser,
  }) async {
    token = newToken;
    user = _sessionUser(newUser);
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Map<String, dynamic> _sessionUser(Map<String, dynamic> source) {
    final stored = <String, dynamic>{};
    for (final key in [
      'id',
      'user_id',
      'id_user',
      'name',
      'nama',
      'nama_lengkap',
      'username',
      'email',
      'phone',
      'no_hp',
      'telepon',
      'address',
      'alamat',
      'role',
      'photo',
      'photo_url',
      'profile_photo',
      'avatar',
      'image_url',
      'foto',
    ]) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        stored[key] = value;
      }
    }
    return stored;
  }

  static Future<void> clear() async {
    token = null;
    user = null;
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await clearAccountCache();
  }

  static Future<void> clearAccountCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _accountCacheKeys) {
      await prefs.remove(key);
    }
  }
}
