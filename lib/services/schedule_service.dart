import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';

class ScheduleService {
  ScheduleService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Map<String, dynamic>>> getSchedules({int? doctorId}) async {
    final path = doctorId == null
        ? ApiConfig.schedulesPath
        : '${ApiConfig.schedulesPath}?doctor_id=$doctorId';
    final response = await _api.get(path);
    final rawList = switch (response) {
      {'data': List<dynamic> value} => value,
      {'data': {'schedules': List<dynamic> value}} => value,
      {'schedules': List<dynamic> value} => value,
      List<dynamic> value => value,
      _ => const <dynamic>[],
    };

    return rawList.whereType<Map>().map((item) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }
}
