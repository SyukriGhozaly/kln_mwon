import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';

class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  final String name;
  final String email;
  final String phone;
  final String address;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: _readString(json, ['name', 'nama', 'nama_lengkap']),
      email: _readString(json, ['email']),
      phone: _readString(json, ['phone', 'no_hp', 'telepon']),
      address: _readString(json, ['address', 'alamat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nama': name,
      'email': email,
      'phone': phone,
      'no_hp': phone,
      'address': address,
      'alamat': address,
    };
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}

class ProfileService {
  ProfileService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<ProfileData> getProfile() async {
    final response = await _api.get(ApiConfig.profilePath);
    final profile = ProfileData.fromJson(_extractObject(response));
    _saveUser(profile);
    return profile;
  }

  Future<ProfileData> updateProfile(ProfileData profile) async {
    final response = await _api.put(ApiConfig.profilePath, profile.toJson());
    final updated = ProfileData.fromJson(_extractObject(response));
    final value = updated.name.isEmpty ? profile : updated;
    _saveUser(value);
    return value;
  }

  Map<String, dynamic> _extractObject(dynamic response) {
    final payload = switch (response) {
      {'data': Map value} => value,
      {'user': Map value} => value,
      {'profile': Map value} => value,
      Map value => value,
      _ => SessionManager.user ?? const <String, dynamic>{},
    };

    final normalized = payload.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    for (final key in ['user', 'profile']) {
      final nested = normalized[key];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    return normalized;
  }

  void _saveUser(ProfileData profile) {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) return;

    SessionManager.save(newToken: token, newUser: profile.toJson());
  }
}
