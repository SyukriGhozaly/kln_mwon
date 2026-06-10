import '../core/constants/api_config.dart';
import '../core/services/api_service.dart';
import '../models/booking.dart';

class PaymentService {
  PaymentService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Booking> confirmPayment(Booking booking) async {
    final bookingIdentifier = booking.id ?? booking.code;
    final total = _safeTotal(booking.total);
    final response = await _api.post(ApiConfig.paymentsPath, {
      'booking_id': bookingIdentifier,
      'id_booking': bookingIdentifier,
      'booking_code': booking.code,
      'kode_booking': booking.code,
      'payment_method': booking.paymentMethod,
      'metode_pembayaran': booking.paymentMethod,
      'amount': total,
      'total': total,
    });

    return _confirmedBooking(
      booking.copyWith(total: total),
      _extractObject(response),
    );
  }

  Booking _confirmedBooking(Booking booking, Map<String, dynamic> source) {
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
      total: _safeTotal(_readTotal(source) ?? booking.total),
    );
  }

  int _safeTotal(int total) => total > 0 ? total : 50000;

  int? _readTotal(Map<String, dynamic> source) {
    for (final key in ['total', 'amount', 'biaya', 'fee']) {
      final value = source[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
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
