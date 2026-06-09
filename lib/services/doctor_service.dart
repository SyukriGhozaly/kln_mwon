import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../models/doctor.dart';

class DoctorService {
  DoctorService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Doctor>> getDoctors() async {
    final response = await _api.get(ApiConfig.doctorsPath);
    final list = _extractList(response);
    return list.map((item) => Doctor.fromJson(item)).toList();
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
