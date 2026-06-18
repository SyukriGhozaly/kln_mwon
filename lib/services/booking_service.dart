import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';
import '../models/booking.dart';
import '../models/doctor.dart';
import 'local_data_service.dart';

class BookingService {
  BookingService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Booking>> getBookings() async {
    for (final path in ApiConfig.bookingReadPaths) {
      try {
        final response = await _api.get(path);
        final bookings = _extractList(response).map(Booking.fromJson).toList();
        if (bookings.isNotEmpty) return bookings;
      } on ApiException catch (error) {
        if (!_canTryNextEndpoint(error)) rethrow;
      }
    }

    return LocalDataService.bookings();
  }

  Future<Booking> createBooking({
    required Doctor doctor,
    required String date,
    required String time,
    required String complaint,
    required String paymentMethod,
  }) async {
    final userId = _currentUserId();
    if (!SessionManager.hasSession) {
      throw const ApiException(
        'Sesi login tidak ditemukan. Silakan login ulang.',
      );
    }
    if (doctor.id <= 0) {
      throw const ApiException('Data dokter tidak valid untuk booking.');
    }
    if (date.trim().isEmpty || time.trim().isEmpty) {
      throw const ApiException('Tanggal dan jam booking wajib dipilih.');
    }

    final requestTotal = _safeTotal(doctor.fee);
    final payload = {
      ..._userPayload(userId),
      'doctor_id': doctor.id,
      'id_dokter': doctor.id,
      'dokter_id': doctor.id,
      'date': date,
      'tanggal': date,
      'tanggal_booking': date,
      'time': time,
      'jam': time,
      'jam_booking': time,
      'complaint': complaint,
      'keluhan': complaint,
      'payment_method': paymentMethod,
      'metode_pembayaran': paymentMethod,
      'total': requestTotal,
      'status': 'Menunggu pembayaran',
    };

    for (final path in ApiConfig.bookingCreatePaths) {
      try {
        final response = await _api.post(path, payload);
        final responsePayload = _extractObject(response);
        final booking = Booking.fromJson(responsePayload).copyWith(
          doctor: doctor,
          patientName: _patientName(responsePayload),
          date:
              responsePayload['date']?.toString() ??
              responsePayload['tanggal']?.toString() ??
              date,
          time:
              responsePayload['time']?.toString() ??
              responsePayload['jam']?.toString() ??
              time,
          complaint:
              responsePayload['complaint']?.toString() ??
              responsePayload['keluhan']?.toString() ??
              complaint,
          paymentMethod:
              responsePayload['payment_method']?.toString() ??
              responsePayload['metode_pembayaran']?.toString() ??
              paymentMethod,
          total: _safeTotal(_readTotal(responsePayload) ?? requestTotal),
        );
        await LocalDataService.upsertBooking(booking);
        return booking;
      } on ApiException catch (error) {
        if (!_canTryNextEndpoint(error)) rethrow;
      }
    }

    final localBooking = LocalDataService.createLocalBooking(
      doctor: doctor,
      date: date,
      time: time,
      complaint: complaint,
      paymentMethod: paymentMethod,
    );
    await LocalDataService.addBooking(localBooking);
    return localBooking;
  }

  bool _canTryNextEndpoint(ApiException error) {
    return error.statusCode == null || error.statusCode == 404;
  }

  int _safeTotal(int total) => total > 0 ? total : 50000;

  String _patientName(Map<String, dynamic> payload) {
    for (final key in ['patient_name', 'nama_pasien', 'name', 'nama']) {
      final value = payload[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return SessionManager.getDisplayName();
  }

  int? _readTotal(Map<String, dynamic> payload) {
    for (final key in ['total', 'biaya', 'fee']) {
      final value = payload[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
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

  Map<String, int> _userPayload(int? userId) {
    if (userId == null) return const {};
    return {
      'user_id': userId,
      'id_user': userId,
      'pasien_id': userId,
      'id_pasien': userId,
    };
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    final rawList = switch (response) {
      List<dynamic> value => value,
      {'data': List<dynamic> value} => value,
      {'data': {'bookings': List<dynamic> value}} => value,
      {'data': {'booking': List<dynamic> value}} => value,
      {'data': {'appointments': List<dynamic> value}} => value,
      {'data': {'appointment': List<dynamic> value}} => value,
      {'data': {'riwayat': List<dynamic> value}} => value,
      {'bookings': List<dynamic> value} => value,
      {'booking': List<dynamic> value} => value,
      {'appointments': List<dynamic> value} => value,
      {'appointment': List<dynamic> value} => value,
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
      {'appointment': Map value} => value,
      Map value => value,
      _ => const <String, dynamic>{},
    };

    final normalized = payload.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    for (final key in ['booking', 'appointment']) {
      final nestedBooking = normalized[key];
      if (nestedBooking is Map) {
        return nestedBooking.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    }

    return normalized;
  }
}
