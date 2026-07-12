import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';

class ScheduleService {
  ScheduleService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Map<String, dynamic>>> getSchedules({int? doctorId}) async {
    final path = doctorId == null
        ? ApiConfig.schedulesPath
        : '${ApiConfig.schedulesPath}?doctor_id=$doctorId';
    final response = await _getScheduleResponse(path);
    final rawList = switch (response) {
      {'data': List<dynamic> value} => value,
      {'data': {'schedules': List<dynamic> value}} => value,
      {'data': {'jadwal': List<dynamic> value}} => value,
      {'schedules': List<dynamic> value} => value,
      {'jadwal': List<dynamic> value} => value,
      List<dynamic> value => value,
      _ => const <dynamic>[],
    };

    final schedules = rawList
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .expand(_expandSchedule)
        .where((item) {
          final id = _readInt(item, ['doctor_id', 'id_dokter']);
          return doctorId == null || id == null || id == doctorId;
        })
        .toList();
    return schedules;
  }

  Future<dynamic> _getScheduleResponse(String path) async {
    try {
      return await _api.get(path);
    } on ApiException catch (error) {
      if (error.statusCode != null && error.statusCode != 404) rethrow;
      return const <dynamic>[];
    }
  }

  Iterable<Map<String, dynamic>> _expandSchedule(Map<String, dynamic> source) {
    final doctorId = _readInt(source, ['doctor_id', 'id_dokter']);
    final rawDate = _readString(source, ['date', 'tanggal']);
    final rawDay = _readString(source, ['day', 'hari']);
    final start = _normalizeTime(
      _readString(source, ['time', 'jam', 'start_time', 'jam_mulai']),
    );
    final end = _normalizeTime(
      _readString(source, ['end_time', 'jam_selesai']),
    );
    final dates = rawDate.isNotEmpty
        ? [_normalizeDate(rawDate)]
        : _datesForDay(rawDay);
    final times = end.isEmpty ? [start] : _hourlySlots(start, end);

    return dates.where((date) => date.isNotEmpty).expand((date) {
      return times.where((time) => time.isNotEmpty).map((time) {
        return {
          ...source,
          'doctor_id': doctorId,
          'id_dokter': doctorId,
          'date': date,
          'tanggal': date,
          'time': time,
          'jam': time,
          if (rawDay.isNotEmpty) 'day_label': rawDay,
        };
      });
    });
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String _normalizeDate(String value) {
    final lower = value.toLowerCase().trim();
    if (lower == 'hari ini' || lower == 'today') return _dateFromNow(0);
    if (lower == 'besok' || lower == 'tomorrow') return _dateFromNow(1);

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '';
    return '${parsed.year}-${_two(parsed.month)}-${_two(parsed.day)}';
  }

  static List<String> _datesForDay(String value) {
    final weekday = _dayNumbers()[value.toLowerCase().trim()];
    if (weekday == null) return const <String>[];

    final today = DateTime.now();
    final dates = <String>[];
    for (var offset = 0; dates.length < 7 && offset < 21; offset++) {
      final date = today.add(Duration(days: offset));
      if (date.weekday == weekday) {
        dates.add('${date.year}-${_two(date.month)}-${_two(date.day)}');
      }
    }
    return dates;
  }

  static Map<String, int> _dayNumbers() {
    return const {
      'senin': DateTime.monday,
      'selasa': DateTime.tuesday,
      'rabu': DateTime.wednesday,
      'kamis': DateTime.thursday,
      'jumat': DateTime.friday,
      "jum'at": DateTime.friday,
      'sabtu': DateTime.saturday,
      'minggu': DateTime.sunday,
    };
  }

  static String _normalizeTime(String value) {
    final match = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(value);
    if (match == null) return '';
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) return '';
    return '${_two(hour)}:${_two(minute)}';
  }

  static List<String> _hourlySlots(String start, String end) {
    if (start.isEmpty || end.isEmpty) return [start];

    final startParts = start.split(':').map(int.parse).toList();
    final endParts = end.split(':').map(int.parse).toList();
    final startMinutes = startParts[0] * 60 + startParts[1];
    final endMinutes = endParts[0] * 60 + endParts[1];

    if (endMinutes <= startMinutes) return [start];

    final slots = <String>[];
    for (var minutes = startMinutes; minutes <= endMinutes; minutes += 60) {
      slots.add('${_two(minutes ~/ 60)}:${_two(minutes % 60)}');
    }
    return slots;
  }

  static String _dateFromNow(int days) {
    final date = DateTime.now().add(Duration(days: days));
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
