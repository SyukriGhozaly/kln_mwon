import 'package:flutter/foundation.dart';

import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../models/doctor.dart';

class DoctorService {
  DoctorService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _api.get(ApiConfig.doctorsPath);
      final list = _extractList(response);
      final doctors = list
          .map((item) {
            debugPrint('DOCTOR RAW: ${item['name']} - photo=${item['photo']}, image_url=${item['image_url']}, photo_url=${item['photo_url']}, foto=${item['foto']}');
            final processed = _withPhotoUrl(item);
            debugPrint('DOCTOR PROCESSED: ${processed['name']} - processed photo=${processed['photo']}');
            return Doctor.fromJson(processed);
          })
          .toList();
      return doctors;
    } on ApiException catch (error) {
      if (error.statusCode != null && error.statusCode != 404) rethrow;
      return const <Doctor>[];
    }
  }

  Map<String, dynamic> _withPhotoUrl(Map<String, dynamic> item) {
    final photo = _readPhoto(item);
    if (photo == null) return item;
    return {...item, 'photo': _resolvePhotoUrl(photo)};
  }

  String? _readPhoto(Map<String, dynamic> item) {
    for (final key in ['photo', 'foto', 'image_url', 'imageUrl', 'photo_url']) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  String _resolvePhotoUrl(String photo) {
    return ApiConfig.publicFileUrl(photo);
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    final rawList = switch (response) {
      List<dynamic> value => value,
      {'data': List<dynamic> value} => value,
      {'data': {'doctors': List<dynamic> value}} => value,
      {'data': {'dokter': List<dynamic> value}} => value,
      {'doctors': List<dynamic> value} => value,
      {'dokter': List<dynamic> value} => value,
      _ => const <dynamic>[],
    };

    return rawList.whereType<Map>().map((item) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }
}
