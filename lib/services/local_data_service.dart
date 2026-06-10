import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/session_manager.dart';
import '../models/booking.dart';
import '../models/doctor.dart';

class LocalDataService {
  const LocalDataService._();

  static const _bookingsKey = 'local_bookings';

  static List<Doctor> doctors() {
    return const [
      Doctor(
        id: 1,
        name: 'dr. Ayu Lestari',
        specialty: 'Dokter Umum',
        polyclinic: 'Poli Umum',
        phone: '081234567801',
        email: 'ayu@klinikmawon.test',
        practiceTime: 'Senin - Jumat, 08:00-12:00',
        imageUrl: '',
        availableDates: ['2026-06-10', '2026-06-11', '2026-06-12'],
        availableTimes: ['08:00', '09:30', '11:00'],
        fee: 50000,
      ),
      Doctor(
        id: 2,
        name: 'drg. Bima Pratama',
        specialty: 'Dokter Gigi',
        polyclinic: 'Poli Gigi',
        phone: '081234567802',
        email: 'bima@klinikmawon.test',
        practiceTime: 'Selasa - Sabtu, 10:00-14:00',
        imageUrl: '',
        availableDates: ['2026-06-10', '2026-06-13', '2026-06-15'],
        availableTimes: ['10:00', '12:00', '13:30'],
        fee: 75000,
      ),
      Doctor(
        id: 3,
        name: 'dr. Citra Maharani',
        specialty: 'Spesialis Anak',
        polyclinic: 'Poli Anak',
        phone: '081234567803',
        email: 'citra@klinikmawon.test',
        practiceTime: 'Senin, Rabu, Jumat, 15:00-18:00',
        imageUrl: '',
        availableDates: ['2026-06-11', '2026-06-12', '2026-06-15'],
        availableTimes: ['15:00', '16:30', '17:30'],
        fee: 100000,
      ),
    ];
  }

  static Future<List<Booking>> bookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookingsKey);
    if (raw == null || raw.isEmpty) return const <Booking>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <Booking>[];
      return decoded
          .whereType<Map>()
          .map((item) => Booking.fromJson(_normalizeMap(item)))
          .toList();
    } on FormatException {
      return const <Booking>[];
    }
  }

  static Future<void> addBooking(Booking booking) async {
    final current = await bookings();
    await _saveBookings([booking, ...current]);
  }

  static Future<void> upsertBooking(Booking booking) async {
    final current = await bookings();
    final index = current.indexWhere((item) {
      final sameId = booking.id != null && item.id == booking.id;
      return sameId || item.code == booking.code;
    });

    if (index == -1) {
      await _saveBookings([booking, ...current]);
      return;
    }

    final updated = List<Booking>.of(current);
    updated[index] = booking;
    await _saveBookings(updated);
  }

  static Booking createLocalBooking({
    required Doctor doctor,
    required String date,
    required String time,
    required String complaint,
    required String paymentMethod,
  }) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch;
    final code = 'KM-${now.year}${_two(now.month)}${_two(now.day)}-$id';
    return Booking(
      id: id,
      code: code,
      queueNumber: 'A${(id % 90 + 10).toString()}',
      patientName: SessionManager.getDisplayName(),
      doctor: doctor,
      date: date,
      time: time,
      complaint: complaint,
      paymentMethod: paymentMethod,
      status: 'Menunggu pembayaran',
      total: doctor.fee > 0 ? doctor.fee : 50000,
    );
  }

  static Future<void> _saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookingsKey,
      jsonEncode(bookings.map(_bookingToJson).toList()),
    );
  }

  static Map<String, dynamic> _bookingToJson(Booking booking) {
    return {
      'id': booking.id,
      'code': booking.code,
      'queue_number': booking.queueNumber,
      'patient_name': booking.patientName,
      'doctor': _doctorToJson(booking.doctor),
      'date': booking.date,
      'time': booking.time,
      'complaint': booking.complaint,
      'payment_method': booking.paymentMethod,
      'status': booking.status,
      'total': booking.total,
    };
  }

  static Map<String, dynamic> _doctorToJson(Doctor doctor) {
    return {
      'id': doctor.id,
      'name': doctor.name,
      'specialty': doctor.specialty,
      'polyclinic': doctor.polyclinic,
      'phone': doctor.phone,
      'email': doctor.email,
      'practice_time': doctor.practiceTime,
      'image_url': doctor.imageUrl,
      'available_dates': doctor.availableDates,
      'available_times': doctor.availableTimes,
      'fee': doctor.fee,
    };
  }

  static Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
