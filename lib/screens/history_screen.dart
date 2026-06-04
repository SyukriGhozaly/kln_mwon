import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<void> _loadBookings = _fetchBookings();
  var _bookings = DummyDataService.history;
  String? _errorMessage;

  Future<void> _fetchBookings() async {
    try {
      final bookings = await BookingService().getBookings();
      if (!mounted || bookings.isEmpty) return;
      setState(() {
        _bookings = bookings;
        _errorMessage = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      debugPrint('Gagal memuat history dari API: $error');
      setState(() {
        _errorMessage =
            'API riwayat gagal: ${error.message}. Sementara memakai data lokal.';
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Gagal memuat history dari API: $error');
      setState(() {
        _errorMessage = 'API riwayat gagal. Sementara memakai data lokal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kunjungan')),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadBookings,
          builder: (context, snapshot) {
            final bookings = _bookings;
            if (bookings.isEmpty) {
              return const Center(child: Text('Belum ada riwayat booking.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length + (_errorMessage == null ? 0 : 1),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (_errorMessage != null && index == 0) {
                  return _ApiWarning(message: _errorMessage!);
                }

                final offset = _errorMessage == null ? index : index - 1;
                return _HistoryCard(booking: bookings[offset]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ApiWarning extends StatelessWidget {
  const _ApiWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFC2410C)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.booking});

  final Booking booking;

  Color get _statusColor {
    return switch (booking.status) {
      'Selesai' => AppColors.success,
      'Terjadwal' => AppColors.primary,
      'Dibatalkan' => AppColors.danger,
      _ => AppColors.warning,
    };
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.doctor.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.doctor.polyclinic,
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Text('${booking.date}, ${booking.time}'),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(booking.code),
                  content: Text(
                    'Keluhan: ${booking.complaint}\nPembayaran: ${booking.paymentMethod}\nNomor antrian: ${booking.queueNumber}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Lihat detail'),
          ),
        ],
      ),
    );
  }
}
