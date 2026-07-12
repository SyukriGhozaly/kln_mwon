class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.polyclinic,
    required this.phone,
    required this.email,
    required this.practiceTime,
    required this.imageUrl,
    required this.availableDates,
    required this.availableTimes,
    required this.fee,
  });

  final int id;
  final String name;
  final String specialty;
  final String polyclinic;
  final String phone;
  final String email;
  final String practiceTime;
  final String imageUrl;
  final List<String> availableDates;
  final List<String> availableTimes;
  final int fee;

  String get schedule => practiceTime;
  String get photoUrl => imageUrl;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final scheduleText = _readSchedule(json, [
      'schedule',
      'practice_time',
      'jadwal_praktik',
      'practiceTime',
      'jam_praktik',
    ]);
    final scheduleDates = _extractScheduleDates(scheduleText);
    final rawDates = _readStringList(json, [
      'available_dates',
      'availableDates',
      'tanggal_tersedia',
      'dates',
    ], fallback: scheduleDates);
    final hasAvailableTimes = _hasListValue(json, [
      'available_times',
      'availableTimes',
      'jam_tersedia',
      'times',
    ]);
    final rawTimes = _readStringList(json, [
      'available_times',
      'availableTimes',
      'jam_tersedia',
      'times',
    ], fallback: _extractTimeSlots(scheduleText));

    return Doctor(
      id: _readInt(json, ['id', 'doctor_id', 'id_dokter']),
      name: _readString(json, ['name', 'nama', 'nama_dokter']),
      specialty: _readString(json, [
        'specialization',
        'specialty',
        'spesialis',
        'spesialisasi',
      ], fallback: 'Dokter'),
      polyclinic: _readString(json, [
        'polyclinic',
        'poli',
        'nama_poli',
        'clinic',
      ], fallback: 'Poli'),
      phone: _readString(json, ['phone', 'no_hp', 'telepon']),
      email: _readString(json, ['email']),
      practiceTime: scheduleText.isEmpty
          ? 'Jadwal belum tersedia'
          : scheduleText,
      imageUrl: _readString(json, [
        'photo_url',
        'image_url',
        'foto',
        'photo',
        'imageUrl',
      ]),
      availableDates: _normalizeDateList(
        rawDates,
        scheduleFallback: scheduleDates,
        timeFallback: scheduleText.isNotEmpty,
      ),
      availableTimes: _normalizeTimes(
        rawTimes,
        scheduleText,
        expandRange: !hasAvailableTimes,
      ),
      fee: _readInt(json, ['fee', 'tarif', 'biaya', 'price'], fallback: 0),
    );
  }

  static String _readSchedule(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      final schedule = _scheduleText(value);
      if (schedule.isNotEmpty) return schedule;
    }
    return '';
  }

  static bool _hasListValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List && value.isNotEmpty) return true;
      if (value is String && value.trim().isNotEmpty) return true;
    }
    return false;
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  static String _scheduleText(Object? value) {
    if (value is List) {
      return value
          .map(_scheduleText)
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    if (value is Map) {
      final schedule = _normalizeMap(value);
      final day = _readString(schedule, ['day', 'hari', 'date', 'tanggal']);
      final start = _readString(schedule, [
        'start_time',
        'jam_mulai',
        'time_start',
        'from',
      ]);
      final end = _readString(schedule, [
        'end_time',
        'jam_selesai',
        'time_end',
        'to',
      ]);
      final raw = _readString(schedule, ['schedule', 'jadwal', 'time', 'jam']);
      if (raw.isNotEmpty) return raw;
      if (day.isNotEmpty && start.isNotEmpty && end.isNotEmpty) {
        return '$day $start-$end';
      }
      if (day.isNotEmpty && start.isNotEmpty) return '$day $start';
    }
    return value?.toString().trim() ?? '';
  }

  static Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static List<String> _readStringList(
    Map<String, dynamic> json,
    List<String> keys, {
    required List<String> fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        final list = value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
      if (value is String && value.trim().isNotEmpty) {
        final list = value
            .split(RegExp(r'[,;]'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      }
    }
    return fallback;
  }

  static String _normalizeDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final lower = trimmed.toLowerCase();
    if (lower == 'hari ini' || lower == 'today') return _dateFromNow(0);
    if (lower == 'besok' || lower == 'tomorrow') return _dateFromNow(1);

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return '${parsed.year}-${_two(parsed.month)}-${_two(parsed.day)}';
    }

    return trimmed;
  }

  static List<String> _normalizeDateList(
    List<String> rawDates, {
    required List<String> scheduleFallback,
    required bool timeFallback,
  }) {
    final normalized = rawDates
        .map(_normalizeDate)
        .where(_isIsoDate)
        .toSet()
        .toList();

    if (normalized.isNotEmpty) return normalized;
    if (scheduleFallback.isNotEmpty) return scheduleFallback;
    return timeFallback ? [_dateFromNow(0)] : const <String>[];
  }

  static bool _isIsoDate(String value) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
  }

  static String _dateFromNow(int days) {
    final date = DateTime.now().add(Duration(days: days));
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static List<String> _extractTimes(String text) {
    final matches = RegExp(r'\d{1,2}[.:]\d{2}').allMatches(text).map((match) {
      return match.group(0)!.replaceAll('.', ':');
    }).toList();
    return matches;
  }

  static List<String> _extractTimeSlots(String text) {
    return _normalizeTimes(_extractTimes(text), text, expandRange: true);
  }

  static List<String> _normalizeTimes(
    List<String> rawTimes,
    String text, {
    required bool expandRange,
  }) {
    final times = rawTimes
        .map(_normalizeTime)
        .where((time) => time.isNotEmpty)
        .toList();
    if (expandRange && times.length >= 2 && _looksLikeTimeRange(text)) {
      return _hourlySlots(times.first, times[1]);
    }
    return times.toSet().toList();
  }

  static String _normalizeTime(String value) {
    final match = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(value);
    if (match == null) return '';
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) return '';
    return '${_two(hour)}:${_two(minute)}';
  }

  static bool _looksLikeTimeRange(String text) {
    return text.contains('-') || text.toLowerCase().contains('sampai');
  }

  static List<String> _hourlySlots(String start, String end) {
    final startParts = start.split(':').map(int.parse).toList();
    final endParts = end.split(':').map(int.parse).toList();
    final startMinutes = startParts[0] * 60 + startParts[1];
    final endMinutes = endParts[0] * 60 + endParts[1];

    if (endMinutes <= startMinutes) return [start, end];

    final slots = <String>[];
    for (var minutes = startMinutes; minutes <= endMinutes; minutes += 60) {
      slots.add('${_two(minutes ~/ 60)}:${_two(minutes % 60)}');
    }
    return slots;
  }

  static List<String> _extractScheduleDates(String text) {
    if (text.trim().isEmpty) return const <String>[];

    final lower = text.toLowerCase();
    final selectedDays = <int>{};
    final dayNumbers = _dayNumbers();
    final rangePattern = RegExp(
      r"(senin|selasa|rabu|kamis|jumat|jum'at|sabtu|minggu)\s*-\s*(senin|selasa|rabu|kamis|jumat|jum'at|sabtu|minggu)",
    );

    for (final match in rangePattern.allMatches(lower)) {
      final start = dayNumbers[match.group(1)];
      final end = dayNumbers[match.group(2)];
      if (start == null || end == null) continue;
      selectedDays.addAll(_dayRange(start, end));
    }

    for (final entry in dayNumbers.entries) {
      if (lower.contains(entry.key)) selectedDays.add(entry.value);
    }

    if (selectedDays.isEmpty) return const <String>[];

    final today = DateTime.now();
    final dates = <String>[];
    for (var offset = 0; dates.length < 7 && offset < 21; offset++) {
      final date = today.add(Duration(days: offset));
      if (selectedDays.contains(date.weekday)) {
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

  static List<int> _dayRange(int start, int end) {
    final days = <int>[];
    var current = start;
    while (true) {
      days.add(current);
      if (current == end) break;
      current = current == DateTime.sunday ? DateTime.monday : current + 1;
    }
    return days;
  }
}
