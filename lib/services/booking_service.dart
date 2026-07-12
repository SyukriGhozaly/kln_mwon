import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';
import '../models/booking.dart';
import '../models/doctor.dart';

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

    return const <Booking>[];
  }

  Future<Booking> createBooking({
    required Doctor doctor,
    required String date,
    required String time,
    required String complaint,
    required String paymentMethod,
  }) async {
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
    if (complaint.trim().isEmpty) {
      throw const ApiException('Keluhan wajib diisi.');
    }
    if (!_validPaymentMethods.contains(paymentMethod)) {
      throw const ApiException('Silakan pilih metode pembayaran terlebih dahulu.');
    }

    final requestTotal = _safeTotal(doctor.fee);
    final payload = {
      'doctor_id': doctor.id,
      'date': date,
      'time': time,
      'complaint': complaint,
      'keluhan': complaint,
      'payment_method': paymentMethod,
      'total': requestTotal,
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
        return booking;
      } on ApiException catch (error) {
        if (!_canTryNextEndpoint(error)) rethrow;
      }
    }

    throw const ApiException('Endpoint booking tidak tersedia.');
  }

  static const _validPaymentMethods = {'qris', 'bank_transfer', 'cash'};

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
