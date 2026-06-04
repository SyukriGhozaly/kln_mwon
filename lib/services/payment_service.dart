import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../models/booking.dart';

class PaymentService {
  PaymentService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Booking> confirmPayment(Booking booking) async {
    final bookingIdentifier = booking.id ?? booking.code;
    final response = await _api.post(ApiConfig.paymentsPath, {
      'booking_id': bookingIdentifier,
      'id_booking': bookingIdentifier,
      'booking_code': booking.code,
      'kode_booking': booking.code,
      'payment_method': booking.paymentMethod,
      'metode_pembayaran': booking.paymentMethod,
      'amount': booking.total,
      'total': booking.total,
    });

    final payload = _extractObject(response);
    if (payload.isEmpty) {
      return booking.copyWith(status: 'Terjadwal');
    }

    return Booking.fromJson(payload).copyWith(
      id: booking.id,
      code:
          payload['code']?.toString() ??
          payload['booking_code']?.toString() ??
          payload['kode_booking']?.toString() ??
          booking.code,
      queueNumber:
          payload['queue_number']?.toString() ??
          payload['nomor_antrian']?.toString() ??
          payload['no_antrian']?.toString() ??
          booking.queueNumber,
      patientName:
          payload['patient_name']?.toString() ??
          payload['nama_pasien']?.toString() ??
          booking.patientName,
      doctor: booking.doctor,
      date:
          payload['date']?.toString() ??
          payload['tanggal']?.toString() ??
          booking.date,
      time:
          payload['time']?.toString() ??
          payload['jam']?.toString() ??
          booking.time,
      complaint:
          payload['complaint']?.toString() ??
          payload['keluhan']?.toString() ??
          booking.complaint,
      paymentMethod:
          payload['payment_method']?.toString() ??
          payload['metode_pembayaran']?.toString() ??
          booking.paymentMethod,
      status: payload['status']?.toString() ?? 'Terjadwal',
      total: int.tryParse(payload['total']?.toString() ?? '') ?? booking.total,
    );
  }

  Map<String, dynamic> _extractObject(dynamic response) {
    final payload = switch (response) {
      {'data': Map value} => value,
      {'payment': Map value} => value,
      {'booking': Map value} => value,
      Map value => value,
      _ => const <String, dynamic>{},
    };

    final normalized = payload.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    for (final key in ['booking', 'payment']) {
      final nested = normalized[key];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    return normalized;
  }
}
