import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';
import '../models/booking.dart';
import '../models/doctor.dart';

class BookingService {
  BookingService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Booking>> getBookings() async {
    final response = await _api.get(ApiConfig.bookingsPath);
    return _extractList(response).map(Booking.fromJson).toList();
  }

  Future<Booking> createBooking({
    required Doctor doctor,
    required String date,
    required String time,
    required String complaint,
    required String paymentMethod,
  }) async {
    final userId = _currentUserId();
    final response = await _api.post(ApiConfig.bookingsPath, {
      'user_id': ?userId,
      'id_user': ?userId,
      'doctor_id': doctor.id,
      'id_dokter': doctor.id,
      'date': date,
      'tanggal': date,
      'time': time,
      'jam': time,
      'complaint': complaint,
      'keluhan': complaint,
      'payment_method': paymentMethod,
      'metode_pembayaran': paymentMethod,
      'total': doctor.fee,
    });

    final payload = _extractObject(response);
    return Booking.fromJson(payload).copyWith(
      doctor: doctor,
      date:
          payload['date']?.toString() ?? payload['tanggal']?.toString() ?? date,
      time: payload['time']?.toString() ?? payload['jam']?.toString() ?? time,
      complaint:
          payload['complaint']?.toString() ??
          payload['keluhan']?.toString() ??
          complaint,
      paymentMethod:
          payload['payment_method']?.toString() ??
          payload['metode_pembayaran']?.toString() ??
          paymentMethod,
      total: int.tryParse(payload['total']?.toString() ?? '') ?? doctor.fee,
    );
  }

  int? _currentUserId() {
    final user = SessionManager.user;
    if (user == null) return null;

    for (final key in ['id', 'user_id', 'id_user']) {
      final value = user[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    final rawList = switch (response) {
      List<dynamic> value => value,
      {'data': List<dynamic> value} => value,
      {'bookings': List<dynamic> value} => value,
      {'booking': List<dynamic> value} => value,
      {'riwayat': List<dynamic> value} => value,
      _ => const <dynamic>[],
    };

    return rawList.whereType<Map>().map((item) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  Map<String, dynamic> _extractObject(dynamic response) {
    final payload = switch (response) {
      {'data': Map value} => value,
      {'booking': Map value} => value,
      Map value => value,
      _ => const <String, dynamic>{},
    };

    final normalized = payload.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final nestedBooking = normalized['booking'];
    if (nestedBooking is Map) {
      return nestedBooking.map((key, value) => MapEntry(key.toString(), value));
    }

    return normalized;
  }
}
