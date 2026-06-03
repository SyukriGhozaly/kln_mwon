import 'doctor.dart';

class Booking {
  const Booking({
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
}
