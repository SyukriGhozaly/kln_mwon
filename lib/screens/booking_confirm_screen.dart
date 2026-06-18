import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';
import '../core/utils/formatters.dart';
import '../models/doctor.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/doctor_avatar.dart';
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
  final _complaintController = TextEditingController(
    text: 'Konsultasi kesehatan',
  );
  final _bookingService = BookingService();
  String _paymentMethod = 'cash';
  bool _isSubmitting = false;

  int get _total => widget.doctor.fee > 0 ? widget.doctor.fee : 50000;

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _goToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final booking = await _bookingService.createBooking(
        doctor: widget.doctor,
        date: widget.date,
        time: widget.time,
        complaint: _complaintController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)),
      );
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Booking gagal. $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _profileValue(List<String> keys, String fallback) {
    if (keys.any((key) => ['name', 'nama', 'nama_lengkap'].contains(key))) {
      return SessionManager.getDisplayName();
    }

    final user = SessionManager.user;
    if (user == null) return fallback;

    for (final key in keys) {
      final value = user[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
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
                  rows: {
                    'Nama': _profileValue(['name', 'nama'], 'Pasien'),
                    'No HP': _profileValue(['phone', 'no_hp'], '-'),
                  },
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Jadwal Dokter',
                  leading: DoctorAvatar(doctor: widget.doctor, radius: 28),
                  rows: {
                    'Dokter': widget.doctor.name,
                    'Poli': widget.doctor.polyclinic,
                    'Tanggal': AppFormatters.bookingDate(widget.date),
                    'Jam': widget.time,
                    'Lokasi': 'Klinik Mawon, Ruang Pemeriksaan 1',
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Keluhan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _complaintController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan keluhan pasien',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Keluhan wajib diisi ya'
                      : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  items: const [
                    DropdownMenuItem(
                      value: 'cash',
                      child: Text('Bayar di Tempat'),
                    ),
                    DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfer Bank'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _paymentMethod = value ?? 'cash'),
                ),
                const SizedBox(height: 12),
                PrimaryCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Estimasi biaya: ${AppFormatters.rupiah(_total)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _goToPayment,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('PAYMENT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows, this.leading});

  final String title;
  final Map<String, String> rows;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
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
