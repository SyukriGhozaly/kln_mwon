import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/doctor.dart';
import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'payment_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  final Doctor doctor;
  final String date;
  final String time;

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController(text: 'Konsultasi kesehatan');
  String _paymentMethod = 'QRIS';

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  void _goToPayment() {
    if (!_formKey.currentState!.validate()) return;
    final booking = Booking(
      code: DummyDataService.nextBookingCode(),
      queueNumber: DummyDataService.nextQueueNumber(widget.doctor.polyclinic),
      patientName: DummyDataService.userName,
      doctor: widget.doctor,
      date: widget.date,
      time: widget.time,
      complaint: _complaintController.text,
      paymentMethod: _paymentMethod,
      status: 'Menunggu pembayaran',
      total: widget.doctor.fee,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Jadwal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoCard(
                  title: 'Data Pasien',
                  rows: const {
                    'Nama': DummyDataService.userName,
                    'No HP': DummyDataService.userPhone,
                  },
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Jadwal Dokter',
                  rows: {
                    'Dokter': widget.doctor.name,
                    'Poli': widget.doctor.polyclinic,
                    'Tanggal': widget.date,
                    'Jam': widget.time,
                    'Lokasi': 'Klinik Mawon, Ruang Pemeriksaan 1',
                  },
                ),
                const SizedBox(height: 12),
                const Text('Keluhan', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _complaintController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Tuliskan keluhan pasien'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Keluhan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                    DropdownMenuItem(value: 'Transfer Bank', child: Text('Transfer Bank')),
                    DropdownMenuItem(value: 'Bayar di Tempat', child: Text('Bayar di Tempat')),
                  ],
                  onChanged: (value) => setState(() => _paymentMethod = value ?? 'QRIS'),
                ),
                const SizedBox(height: 22),
                ElevatedButton(onPressed: _goToPayment, child: const Text('PAYMENT')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...rows.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 82,
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
