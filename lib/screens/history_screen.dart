import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/utils/formatters.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'payment_screen.dart';
import 'ticket_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Booking>> _loadBookings;
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadBookings = BookingService().getBookings();
  }

  void _reload() {
    setState(() => _loadBookings = BookingService().getBookings());
  }

  List<Booking> _filteredBookings(List<Booking> bookings) {
    if (_selectedStatus == 'Semua') return bookings;
    return bookings
        .where((booking) => booking.status == _selectedStatus)
        .toList();
  }

  List<String> _statusFilters(List<Booking> bookings) {
    return ['Semua', ...bookings.map((booking) => booking.status).toSet()];
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
                message: 'Belum ada riwayat kunjungan.',
                actionText: 'Muat ulang',
                onAction: _reload,
              );
            }

            final filteredBookings = _filteredBookings(bookings);
            final filters = _statusFilters(bookings);

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount:
                  1 + (filteredBookings.isEmpty ? 1 : filteredBookings.length),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _HistoryFilters(
                    filters: filters,
                    selected: _selectedStatus,
                    onSelected: (status) {
                      setState(() => _selectedStatus = status);
                    },
                  );
                }

                if (filteredBookings.isEmpty) {
                  return _InlineState(
                    message:
                        'Tidak ada booking dengan status $_selectedStatus.',
                    actionText: 'Tampilkan semua',
                    onAction: () {
                      setState(() => _selectedStatus = 'Semua');
                    },
                  );
                }

                final booking = filteredBookings[index - 1];
                return _HistoryCard(booking: booking, onChanged: _reload);
              },
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

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return ChoiceChip(
            label: Text(filter),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _InlineState extends StatelessWidget {
  const _InlineState({
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        children: [
          const Icon(Icons.filter_alt_off_rounded, size: 42),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.booking, required this.onChanged});

  final Booking booking;
  final VoidCallback onChanged;

  Color get _statusColor {
    return switch (booking.status) {
      'Selesai' => AppColors.success,
      'Terjadwal' => AppColors.primary,
      'Dibatalkan' => AppColors.danger,
      _ => AppColors.warning,
    };
  }

  bool get _canPay => booking.status == 'Menunggu pembayaran';
  bool get _hasTicket => booking.status == 'Terjadwal';

  Future<void> _openPayment(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PaymentScreen(booking: booking)));
    onChanged();
  }

  void _openTicket(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)));
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.code,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Pasien', value: booking.patientName),
            _DetailRow(label: 'Dokter', value: booking.doctor.name),
            _DetailRow(label: 'Poli', value: booking.doctor.polyclinic),
            _DetailRow(
              label: 'Jadwal',
              value:
                  '${AppFormatters.bookingDate(booking.date)}, ${booking.time}',
            ),
            _DetailRow(label: 'Keluhan', value: booking.complaint),
            _DetailRow(
              label: 'Pembayaran',
              value: AppFormatters.paymentMethod(booking.paymentMethod),
            ),
            _DetailRow(
              label: 'Total',
              value: AppFormatters.rupiah(booking.total),
            ),
            _DetailRow(label: 'Antrian', value: booking.queueNumber),
            _DetailRow(label: 'Status', value: booking.status),
            const SizedBox(height: 16),
            if (_canPay)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openPayment(context);
                },
                child: const Text('LANJUT PEMBAYARAN'),
              )
            else if (_hasTicket)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openTicket(context);
                },
                child: const Text('LIHAT TIKET'),
              ),
          ],
        ),
      ),
    );
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
              Text(
                '${AppFormatters.bookingDate(booking.date)}, ${booking.time}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDetail(context),
                  child: const Text('Detail'),
                ),
              ),
              if (_canPay) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openPayment(context),
                    child: const Text('Bayar'),
                  ),
                ),
              ] else if (_hasTicket) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openTicket(context),
                    child: const Text('Tiket'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
