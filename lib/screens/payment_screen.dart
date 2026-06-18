import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/utils/formatters.dart';
import '../models/booking.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'ticket_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.booking});

  final Booking booking;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentService = PaymentService();
  bool _isSubmitting = false;

  int get _safeTotal => widget.booking.total > 0 ? widget.booking.total : 50000;

  String get _total => AppFormatters.rupiah(_safeTotal);

  bool get _canConfirmOnline => widget.booking.id != null;

  Future<void> _confirmPayment() async {
    if (!_canConfirmOnline) {
      _showError(
        'Booking belum tersimpan ke server. Pastikan koneksi API aktif lalu buat booking ulang.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final confirmedBooking = await _paymentService.confirmPayment(
        widget.booking.copyWith(total: _safeTotal),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TicketScreen(booking: confirmedBooking),
        ),
      );
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Konfirmasi pembayaran gagal. $error');
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

  String get _paymentTitle {
    return switch (widget.booking.paymentMethod.toLowerCase()) {
      'cash' => 'Bayar di Tempat',
      'transfer' => 'Transfer Bank',
      'qris' => 'Scan QRIS',
      _ => AppFormatters.paymentMethod(widget.booking.paymentMethod),
    };
  }

  String get _paymentInstruction {
    return switch (widget.booking.paymentMethod.toLowerCase()) {
      'cash' =>
        'Datang sesuai jadwal, lalu konfirmasi untuk mendapatkan nomor antrian.',
      'transfer' =>
        'Transfer sesuai nominal tagihan, lalu tekan konfirmasi pembayaran.',
      'qris' => 'Scan QRIS sesuai nominal tagihan, lalu tekan konfirmasi.',
      _ => 'Tekan konfirmasi untuk melanjutkan proses pembayaran.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PrimaryCard(
                child: Column(
                  children: [
                    const Text(
                      'Total Tagihan',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _total,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.booking.code),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.booking.doctor.name} - ${AppFormatters.bookingDate(widget.booking.date)}, ${widget.booking.time}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryCard(
                child: Column(
                  children: [
                    Text(
                      _paymentTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.booking.paymentMethod.toLowerCase() == 'qris')
                      const _FakeQr(size: 180)
                    else
                      _PaymentIcon(method: widget.booking.paymentMethod),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_balance_wallet_rounded),
                      title: Text(
                        AppFormatters.paymentMethod(
                          widget.booking.paymentMethod,
                        ),
                      ),
                      subtitle: Text(_paymentInstruction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _isSubmitting || !_canConfirmOnline
                    ? null
                    : _confirmPayment,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('KONFIRMASI PEMBAYARAN'),
              ),
              if (!_canConfirmOnline) ...[
                const SizedBox(height: 8),
                const Text(
                  'Booking ini masih lokal, belum bisa dikonfirmasi ke backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.danger),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  const _PaymentIcon({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method.toLowerCase()) {
      'cash' => Icons.payments_rounded,
      'transfer' => Icons.account_balance_rounded,
      _ => Icons.account_balance_wallet_rounded,
    };

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.primary, size: 82),
    );
  }
}

class _FakeQr extends StatelessWidget {
  const _FakeQr({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (_, index) {
          final dark =
              index % 2 == 0 || index % 7 == 0 || index == 10 || index == 70;
          return Container(
            margin: const EdgeInsets.all(1.5),
            color: dark ? AppColors.textDark : Colors.white,
          );
        },
      ),
    );
  }
}
