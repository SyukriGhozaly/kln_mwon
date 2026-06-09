import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Booking>> _loadBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings = BookingService().getBookings();
  }

  void _reload() {
    setState(() => _loadBookings = BookingService().getBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kunjungan')),
      body: SafeArea(
        child: FutureBuilder<List<Booking>>(
          future: _loadBookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : snapshot.error.toString();
              return _StateMessage(
                message: 'Gagal memuat riwayat.\n$message',
                actionText: 'Coba lagi',
                onAction: _reload,
              );
            }

            final bookings = snapshot.data ?? const <Booking>[];
            if (bookings.isEmpty) {
              return _StateMessage(
                message: 'Belum ada riwayat booking dari API.',
                actionText: 'Muat ulang',
                onAction: _reload,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _HistoryCard(booking: bookings[index]),
            );
          },
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
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
