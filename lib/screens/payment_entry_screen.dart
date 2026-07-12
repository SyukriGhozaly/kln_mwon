import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/utils/formatters.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'doctor_list_screen.dart';
import 'payment_screen.dart';

class PaymentEntryScreen extends StatefulWidget {
  const PaymentEntryScreen({super.key});

  @override
  State<PaymentEntryScreen> createState() => _PaymentEntryScreenState();
}

class _PaymentEntryScreenState extends State<PaymentEntryScreen> {
  late Future<List<Booking>> _loadPendingBookings;

  @override
  void initState() {
    super.initState();
    _loadPendingBookings = _pendingBookings();
  }

  Future<List<Booking>> _pendingBookings() async {
    final bookings = await BookingService().getBookings();
    return bookings
        .where((booking) => booking.status == 'Menunggu pembayaran')
        .toList();
  }

  void _reload() {
    setState(() => _loadPendingBookings = _pendingBookings());
  }

  Future<void> _refresh() async {
    final nextLoad = _pendingBookings();
    setState(() => _loadPendingBookings = nextLoad);
    await nextLoad;
  }

  Future<void> _openPayment(Booking booking) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)));
    if (!mounted) return;
    _reload();
  }

  void _openDoctorList() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DoctorListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SafeArea(
        child: FutureBuilder<List<Booking>>(
          future: _loadPendingBookings,
          builder: (context, snapshot) {
            final pendingBookings = snapshot.data ?? const <Booking>[];

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PrimaryCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_available_rounded,
                          color: AppColors.primary,
                          size: 54,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Mulai Booking Jadwal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih dokter dan jadwal praktik untuk membuat booking baru.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _openDoctorList,
                          child: const Text('PILIH JADWAL'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Menunggu Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    _PendingState(
                      icon: Icons.wifi_off_rounded,
                      message: snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Riwayat booking belum bisa dimuat.',
                      actionText: 'Coba lagi',
                      onAction: _reload,
                    )
                  else if (pendingBookings.isEmpty)
                    _PendingState(
                      icon: Icons.check_circle_outline_rounded,
                      message:
                          'Tidak ada booking yang menunggu pembayaran saat ini.',
                      actionText: 'Booking baru',
                      onAction: _openDoctorList,
                    )
                  else
                    ...pendingBookings.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PendingBookingCard(
                          booking: booking,
                          onPay: () => _openPayment(booking),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PendingBookingCard extends StatelessWidget {
  const _PendingBookingCard({required this.booking, required this.onPay});

  final Booking booking;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.doctor.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${AppFormatters.bookingDate(booking.date)}, ${booking.time}',
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.rupiah(booking.total),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onPay, child: const Text('LANJUT BAYAR')),
        ],
      ),
    );
  }
}

class _PendingState extends StatelessWidget {
  const _PendingState({
    required this.icon,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 44),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}
