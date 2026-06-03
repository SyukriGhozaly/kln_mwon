import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = DummyDataService.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kunjungan')),
      body: SafeArea(
        child: bookings.isEmpty
            ? const Center(child: Text('Belum ada riwayat booking.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _HistoryCard(booking: bookings[index]),
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
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status,
                  style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(booking.doctor.polyclinic, style: const TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.textGrey),
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
