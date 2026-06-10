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

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final parsedSchedule = _scheduleText(json['schedule']);
    final scheduleText = parsedSchedule.isNotEmpty
        ? parsedSchedule
        : _readString(json, [
            'practice_time',
            'practiceTime',
            'jam_praktik',
            'jadwal_praktik',
          ]);

    return Doctor(
      id: _readInt(json, ['id', 'doctor_id', 'id_dokter']),
      name: _readString(json, ['name', 'nama', 'nama_dokter']),
      specialty: _readString(json, [
        'specialty',
        'specialization',
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
        'photo',
        'foto',
        'photo_url',
        'image_url',
        'imageUrl',
      ], fallback: ''),
      availableDates: _readStringList(json, [
        'available_dates',
        'availableDates',
        'tanggal_tersedia',
        'dates',
      ], fallback: _extractDates(json['schedule'])),
      availableTimes: _readStringList(json, [
        'available_times',
        'availableTimes',
        'jam_tersedia',
        'times',
      ], fallback: _extractTimes(scheduleText)),
      fee: _readInt(json, ['fee', 'tarif', 'biaya', 'price'], fallback: 0),
    );
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
            .map((item) => item.toString())
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

  static List<String> _extractDates(Object? schedule) {
    if (schedule is List) {
      final dates = <String>[];
      for (final item in schedule) {
        if (item is Map) {
          final normalized = _normalizeMap(item);
          final date = _readString(normalized, [
            'date',
            'tanggal',
            'day',
            'hari',
          ]);
          if (date.isNotEmpty) dates.add(date);
        }
      }
      return dates.toSet().toList();
    }
    return const <String>[];
  }

  static List<String> _extractTimes(String text) {
    final matches = RegExp(r'\d{1,2}[.:]\d{2}').allMatches(text).map((match) {
      return match.group(0)!.replaceAll('.', ':');
    }).toList();
    return matches;
  }
}
