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
    final source = payload.isEmpty ? <String, dynamic>{} : payload;
    return Booking.fromJson({
      ...source,
      if (source.isEmpty) 'status': 'Terjadwal',
    }).copyWith(
      id: booking.id,
      code:
          source['code']?.toString() ??
          source['booking_code']?.toString() ??
          source['kode_booking']?.toString() ??
          booking.code,
      queueNumber:
          source['queue_number']?.toString() ??
          source['nomor_antrian']?.toString() ??
          source['no_antrian']?.toString() ??
          booking.queueNumber,
      patientName:
          source['patient_name']?.toString() ??
          source['nama_pasien']?.toString() ??
          booking.patientName,
      doctor: booking.doctor,
      date:
          source['date']?.toString() ??
          source['tanggal']?.toString() ??
          booking.date,
      time:
          source['time']?.toString() ??
          source['jam']?.toString() ??
          booking.time,
      complaint:
          source['complaint']?.toString() ??
          source['keluhan']?.toString() ??
          booking.complaint,
      paymentMethod:
          source['payment_method']?.toString() ??
          source['metode_pembayaran']?.toString() ??
          booking.paymentMethod,
      status: source['status']?.toString() ?? 'Terjadwal',
      total: int.tryParse(source['total']?.toString() ?? '') ?? booking.total,
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
