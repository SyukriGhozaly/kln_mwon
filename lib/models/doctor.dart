class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.polyclinic,
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
  final String practiceTime;
  final String imageUrl;
  final List<String> availableDates;
  final List<String> availableTimes;
  final int fee;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final scheduleText = _readString(json, [
      'practice_time',
      'practiceTime',
      'jam_praktik',
      'jadwal_praktik',
      'schedule',
    ], fallback: '-');

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
      practiceTime: scheduleText,
      imageUrl: _readString(json, [
        'image_url',
        'imageUrl',
        'foto',
        'photo',
      ], fallback: ''),
      availableDates: _readStringList(
        json,
        ['available_dates', 'availableDates', 'tanggal_tersedia', 'dates'],
        fallback: const ['Hari ini'],
      ),
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

  static List<String> _extractTimes(String text) {
    final matches = RegExp(r'\d{1,2}[.:]\d{2}').allMatches(text).map((match) {
      return match.group(0)!.replaceAll('.', ':');
    }).toList();
    return matches.isEmpty ? const ['08:00'] : matches;
  }
}
