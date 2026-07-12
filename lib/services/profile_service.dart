import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';

class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String? photoUrl;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final photo = _readString(json, ['photo_url', 'photo', 'profile_photo', 'image_url']);
    return ProfileData(
      name: _readString(json, ['name', 'nama', 'nama_lengkap']),
      email: _readString(json, ['email']),
      phone: _readString(json, ['phone', 'no_hp', 'telepon']),
      address: _readString(json, ['address', 'alamat']),
      photoUrl: _resolvePhotoUrl(photo),
    );
  }

  Map<String, dynamic> toJson({bool includePhotoFields = true}) {
    final data = <String, dynamic>{
      'name': name,
      'nama': name,
      'email': email,
      'phone': phone,
      'no_hp': phone,
      'address': address,
      'alamat': address,
    };

    if (includePhotoFields && photoUrl != null && photoUrl!.trim().isNotEmpty) {
      data['photo'] = photoUrl;
      data['profile_photo'] = photoUrl;
    }

    return data;
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

  static String? _resolvePhotoUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) {
      return null;
    }

    final trimmed = photo.trim();
    return ApiConfig.publicFileUrl(trimmed);
  }
}

class ProfileService {
  ProfileService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<ProfileData> getProfile() async {
    try {
      final response = await _api.get(ApiConfig.profilePath);
      final profile = ProfileData.fromJson(_extractObject(response));
      await _saveUser(profile);
      return profile;
    } on ApiException catch (error) {
      if (error.statusCode != null) rethrow;
      return _profileFromSession();
    }
  }

  Future<ProfileData> updateProfile(ProfileData profile, {Uint8List? photoBytes, String? photoFilename}) async {
    try {
      final response = (photoBytes == null)
          ? await _api.put(ApiConfig.profilePath, profile.toJson())
          : await _uploadProfileWithFile(profile, photoBytes, photoFilename ?? 'upload.jpg');
      final updated = ProfileData.fromJson(_extractObject(response));
      final value = updated.name.isEmpty ? profile : updated;
      await _saveUser(value);
      return value;
    } on ApiException catch (error) {
      if (error.statusCode != null) rethrow;
      await _saveUser(profile);
      return profile;
    }
  }

  Future<dynamic> _uploadProfileWithFile(
    ProfileData profile,
    Uint8List photoBytes,
    String photoFilename,
  ) async {
    final uri = ApiConfig.apiUri(ApiConfig.profilePath);
    final request = http.MultipartRequest('POST', uri);
    final headers = await _api.requestHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    final fields = profile.toJson(includePhotoFields: false)
      .map((key, value) => MapEntry(key, value.toString()));
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: photoFilename,
      ),
    );

    final streamed = await request.send().timeout(_api.timeout);
    final response = await http.Response.fromStream(streamed);
    return _api.decodeResponse(response, uri);
  }

  Map<String, dynamic> _extractObject(dynamic response) {
    if (response is! Map) {
      return SessionManager.user ?? const <String, dynamic>{};
    }

    final normalized = response.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    for (final key in ['data', 'user', 'profile']) {
      final nested = normalized[key];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    final hasProfileFields = [
      'name',
      'nama',
      'nama_lengkap',
      'email',
      'phone',
      'no_hp',
      'address',
      'alamat',
    ].any((key) => normalized[key] != null);

    if (!hasProfileFields) {
      return SessionManager.user ?? const <String, dynamic>{};
    }

    return normalized;
  }

  Future<void> _saveUser(ProfileData profile) async {
    final token = SessionManager.token;
    if (token == null || token.isEmpty) return;
    if (profile.name.isEmpty &&
        profile.email.isEmpty &&
        profile.phone.isEmpty) {
      return;
    }
    final mergedUser = _mergeNonEmpty(SessionManager.user, profile.toJson());

    await SessionManager.save(newToken: token, newUser: mergedUser);
  }

  Map<String, dynamic> _mergeNonEmpty(
    Map<String, dynamic>? current,
    Map<String, dynamic> incoming,
  ) {
    final merged = <String, dynamic>{...?current};
    for (final entry in incoming.entries) {
      final value = entry.value;
      if (value != null && value.toString().trim().isNotEmpty) {
        merged[entry.key] = value;
      }
    }
    return merged;
  }

  ProfileData _profileFromSession() {
    final profile = ProfileData.fromJson(SessionManager.user ?? const {});
    return ProfileData(
      name: profile.name.isEmpty
          ? SessionManager.getDisplayName()
          : profile.name,
      email: profile.email.isEmpty ? '-' : profile.email,
      phone: profile.phone.isEmpty ? '-' : profile.phone,
      address: profile.address.isEmpty ? '-' : profile.address,
    );
  }
}
