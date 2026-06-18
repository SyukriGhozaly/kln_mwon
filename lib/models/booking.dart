import 'doctor.dart';

class Booking {
  const Booking({
    this.id,
    required this.code,
    required this.queueNumber,
    required this.patientName,
    required this.doctor,
    required this.date,
    required this.time,
    required this.complaint,
    required this.paymentMethod,
    required this.status,
    required this.total,
  });

  final int? id;
  final String code;
  final String queueNumber;
  final String patientName;
  final Doctor doctor;
  final String date;
  final String time;
  final String complaint;
  final String paymentMethod;
  final String status;
  final int total;

  Booking copyWith({
    int? id,
    String? code,
    String? queueNumber,
    String? patientName,
    Doctor? doctor,
    String? date,
    String? time,
    String? complaint,
    String? paymentMethod,
    String? status,
    int? total,
  }) {
    return Booking(
      id: id ?? this.id,
      code: code ?? this.code,
      queueNumber: queueNumber ?? this.queueNumber,
      patientName: patientName ?? this.patientName,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      complaint: complaint ?? this.complaint,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      total: total ?? this.total,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final doctorJson = _readMap(json, ['doctor', 'dokter']);
    final doctor = doctorJson == null
        ? Doctor(
            id: _readInt(json, ['doctor_id', 'id_dokter']),
            name: _readString(json, [
              'doctor_name',
              'nama_dokter',
            ], fallback: 'Dokter'),
            specialty: _readString(json, [
              'specialty',
              'specialization',
              'spesialis',
            ], fallback: 'Dokter'),
            polyclinic: _readString(json, [
              'polyclinic',
              'poli',
              'nama_poli',
            ], fallback: 'Poli'),
            phone: '',
            email: '',
            practiceTime: _readString(json, [
              'practice_time',
              'jadwal_praktik',
            ], fallback: '-'),
            imageUrl: _readString(json, [
              'photo',
              'foto',
              'photo_url',
              'image_url',
              'imageUrl',
            ]),
            availableDates: [
              _readString(json, [
                'date',
                'tanggal',
                'tanggal_booking',
              ], fallback: '-'),
            ],
            availableTimes: [
              _readString(json, [
                'time',
                'jam',
                'jam_booking',
              ], fallback: '08:00'),
            ],
            fee: _readInt(json, ['total', 'biaya', 'fee']),
          )
        : Doctor.fromJson(doctorJson);

    return Booking(
      id: _readIntOrNull(json, ['id', 'booking_id', 'id_booking']),
      code: _readString(json, [
        'code',
        'booking_code',
        'kode_booking',
      ], fallback: _fallbackCode(json)),
      queueNumber: _readString(json, [
        'queue_number',
        'nomor_antrian',
        'no_antrian',
      ], fallback: '-'),
      patientName: _readString(json, [
        'patient_name',
        'nama_pasien',
        'name',
      ], fallback: '-'),
      doctor: doctor,
      date: _readString(json, [
        'date',
        'tanggal',
        'tanggal_booking',
      ], fallback: '-'),
      time: _readString(json, ['time', 'jam', 'jam_booking'], fallback: '-'),
      complaint: _readString(json, ['complaint', 'keluhan'], fallback: '-'),
      paymentMethod: _readString(json, [
        'payment_method',
        'metode_pembayaran',
      ], fallback: '-'),
      status: _displayStatus(
        _readString(json, ['status'], fallback: 'Menunggu pembayaran'),
      ),
      total: _readInt(json, ['total', 'biaya', 'fee'], fallback: 50000),
    );
  }

  static String _fallbackCode(Map<String, dynamic> json) {
    final id = _readIntOrNull(json, ['id', 'booking_id', 'id_booking']);
    return id == null ? '-' : 'KM-$id';
  }

  static String _displayStatus(String status) {
    return switch (status.toLowerCase()) {
      'waiting' || 'pending' => 'Menunggu pembayaran',
      'menunggu pembayaran' => 'Menunggu pembayaran',
      'menunggu konfirmasi' => 'Menunggu konfirmasi',
      'confirmed' || 'paid' => 'Terjadwal',
      'terjadwal' => 'Terjadwal',
      'done' || 'completed' || 'selesai' => 'Selesai',
      'cancelled' || 'canceled' || 'dibatalkan' => 'Dibatalkan',
      _ => status,
    };
  }

  static Map<String, dynamic>? _readMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    return null;
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
    int fallback = 50000,
  }) {
    return _readIntOrNull(json, keys) ?? fallback;
  }

  static int? _readIntOrNull(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }
}
