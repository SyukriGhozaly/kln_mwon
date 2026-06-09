import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
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

  String get _total =>
      'Rp ${widget.booking.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  Future<void> _confirmPayment() async {
    setState(() => _isSubmitting = true);
    try {
      final confirmedBooking = await _paymentService.confirmPayment(
        widget.booking,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryCard(
                child: Column(
                  children: [
                    const Text(
                      'Scan QRIS / Transfer Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _FakeQr(size: 180),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_balance_wallet_rounded),
                      title: Text(widget.booking.paymentMethod),
                      subtitle: const Text(
                        'Status: menunggu konfirmasi pembayaran',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmPayment,
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
            ],
          ),
        ),
      ),
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
