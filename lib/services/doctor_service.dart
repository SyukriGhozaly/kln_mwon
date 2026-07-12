import 'package:flutter/foundation.dart';
<<<<<<< HEAD
=======
import 'package:http/http.dart' as http;
>>>>>>> 507a627 (Fix doctor display and schedule parsing)

import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../models/doctor.dart';

class DoctorService {
  DoctorService({ApiService? api, http.Client? client})
    : _api = api ?? ApiService(),
      _client = client ?? http.Client();

  final ApiService _api;
  final http.Client _client;

<<<<<<< HEAD
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
=======
  Future<List<Doctor>> fetchDoctors() async {
    final uri = ApiConfig.apiUri(ApiConfig.doctorsPath);
    final response = await _client
        .get(uri, headers: await _api.requestHeaders())
        .timeout(_api.timeout);

    debugPrint('DoctorService GET $uri status: ${response.statusCode}');
    debugPrint('DoctorService body: ${response.body}');

    final decoded = _api.decodeResponse(response, uri);
    final data = _extractData(decoded);
    final doctors = data.map(Doctor.fromJson).toList();

    debugPrint('DoctorService parsed doctors: ${doctors.length}');
    for (final doctor in doctors) {
      debugPrint(
        'DoctorService doctor: ${doctor.name} photoUrl=${doctor.photoUrl}',
      );
>>>>>>> 507a627 (Fix doctor display and schedule parsing)
    }

    return doctors;
  }

  Future<List<Doctor>> getDoctors() => fetchDoctors();

  List<Map<String, dynamic>> _extractData(dynamic decoded) {
    if (decoded is! Map) {
      throw ApiException('Respons dokter harus berupa object JSON.');
    }

    final rawData = decoded['data'] ?? const <dynamic>[];
    if (rawData is! List) {
      throw ApiException('Field data dokter harus berupa list.');
    }

    return rawData.map((item) {
      if (item is! Map) {
        throw ApiException('Item data dokter harus berupa object JSON.');
      }
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }
}
