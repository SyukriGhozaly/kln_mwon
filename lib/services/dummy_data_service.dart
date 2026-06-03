import '../models/booking.dart';
import '../models/doctor.dart';

class DummyDataService {
  static const userName = 'Rizky Mawon';
  static const userEmail = 'rizky@email.com';
  static const userPhone = '0812 3456 7890';

  static final doctors = <Doctor>[
    const Doctor(
      id: 1,
      name: 'dr. Aulia Putri',
      specialty: 'Dokter Umum',
      polyclinic: 'Poli Umum',
      practiceTime: 'Senin - Jumat, 08.00 - 12.00',
      imageUrl: '',
      availableDates: ['Hari ini', 'Besok', 'Jumat'],
      availableTimes: ['08.30', '09.30', '10.30'],
      fee: 75000,
    ),
    const Doctor(
      id: 2,
      name: 'drg. Bima Pratama',
      specialty: 'Dokter Gigi',
      polyclinic: 'Poli Gigi',
      practiceTime: 'Selasa - Sabtu, 10.00 - 15.00',
      imageUrl: '',
      availableDates: ['Hari ini', 'Kamis', 'Sabtu'],
      availableTimes: ['10.00', '11.30', '14.00'],
      fee: 110000,
    ),
    const Doctor(
      id: 3,
      name: 'dr. Nadya Sari',
      specialty: 'Kesehatan Anak',
      polyclinic: 'Poli Anak',
      practiceTime: 'Senin, Rabu, Jumat, 13.00 - 17.00',
      imageUrl: '',
      availableDates: ['Besok', 'Jumat', 'Senin'],
      availableTimes: ['13.30', '15.00', '16.00'],
      fee: 95000,
    ),
  ];

  static final history = <Booking>[
    Booking(
      code: 'KM-260601-021',
      queueNumber: 'A-021',
      patientName: userName,
      doctor: doctors[0],
      date: '1 Juni 2026',
      time: '09.30',
      complaint: 'Demam dan pusing',
      paymentMethod: 'QRIS',
      status: 'Selesai',
      total: 75000,
    ),
    Booking(
      code: 'KM-260528-014',
      queueNumber: 'G-014',
      patientName: userName,
      doctor: doctors[1],
      date: '28 Mei 2026',
      time: '11.30',
      complaint: 'Kontrol gigi',
      paymentMethod: 'Transfer Bank',
      status: 'Terjadwal',
      total: 110000,
    ),
  ];

  static void addBooking(Booking booking) {
    history.removeWhere((item) => item.code == booking.code);
    history.insert(0, booking);
  }

  static String nextBookingCode() {
    final number = (history.length + 33).toString().padLeft(3, '0');
    return 'KM-260603-$number';
  }

  static String nextQueueNumber(String polyclinic) {
    final prefix = polyclinic.contains('Gigi')
        ? 'G'
        : polyclinic.contains('Anak')
            ? 'C'
            : 'A';
    final number = (history.length + 33).toString().padLeft(3, '0');
    return '$prefix-$number';
  }
}
