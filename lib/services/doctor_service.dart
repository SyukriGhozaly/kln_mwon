import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../models/doctor.dart';
import 'local_data_service.dart';

class DoctorService {
  DoctorService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _api.get(ApiConfig.doctorsPath);
      final list = _extractList(response);
      final doctors = list
          .map((item) => Doctor.fromJson(_withPhotoUrl(item)))
          .toList();
      return doctors.isEmpty ? LocalDataService.doctors() : doctors;
    } on ApiException catch (error) {
      if (error.statusCode != null && error.statusCode != 404) rethrow;
      return LocalDataService.doctors();
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
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }
    if (photo.startsWith('/')) {
      return '${ApiConfig.baseUrl}$photo';
    }
    if (photo.startsWith('img/')) {
      return '${ApiConfig.baseUrl}/$photo';
    }
    return '${ApiConfig.baseUrl}/img/$photo';
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
