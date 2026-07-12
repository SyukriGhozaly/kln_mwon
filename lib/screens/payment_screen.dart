import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/api_config.dart';
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

  bool get _canConfirmPayment {
    return widget.booking.id != null ||
        (widget.booking.code.trim().isNotEmpty && widget.booking.code != '-');
  }

  bool get _isCash => widget.booking.paymentMethod.toLowerCase() == 'cash';

  bool get _isQris => widget.booking.paymentMethod.toLowerCase() == 'qris';

  bool get _isBankTransfer =>
      widget.booking.paymentMethod.toLowerCase() == 'bank_transfer' ||
      widget.booking.paymentMethod.toLowerCase() == 'transfer';

  Future<void> _confirmPayment() async {
    if (!_canConfirmPayment) {
      _showError('Data booking belum lengkap. Silakan buat booking ulang.');
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
      'transfer' || 'bank_transfer' => 'Transfer Bank',
      'qris' => 'Scan QRIS',
      _ => AppFormatters.paymentMethod(widget.booking.paymentMethod),
    };
  }

  String get _paymentInstruction {
    return switch (widget.booking.paymentMethod.toLowerCase()) {
      'cash' => 'Pembayaran dilakukan di Klinik Mawon saat kunjungan.',
      'transfer' || 'bank_transfer' =>
        'Transfer sesuai nominal tagihan ke rekening Klinik Mawon.',
      'qris' => 'Scan QRIS berikut untuk melakukan pembayaran.',
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
                    if (_isQris)
                      _QrisImage(size: 190)
                    else
                      _PaymentIcon(method: widget.booking.paymentMethod),
                    const SizedBox(height: 16),
                    if (_isBankTransfer) const _BankTransferInfo(),
                    if (_isCash) const _CashInfo(),
                    if (_isBankTransfer || _isCash) const SizedBox(height: 12),
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
                onPressed: _isSubmitting || !_canConfirmPayment
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
                    : Text(
                        _isCash
                            ? 'Lihat Tiket Booking'
                            : 'Konfirmasi Pembayaran',
                      ),
              ),
              if (!_canConfirmPayment) ...[
                const SizedBox(height: 8),
                const Text(
                  'Data booking belum lengkap untuk dikonfirmasi.',
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
      'transfer' || 'bank_transfer' => Icons.account_balance_rounded,
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

class _QrisImage extends StatelessWidget {
  const _QrisImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        ApiConfig.publicFileUrl('img/qr.png'),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: AppColors.lightBlue,
          child: const Text('QRIS belum tersedia', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _BankTransferInfo extends StatelessWidget {
  const _BankTransferInfo();

  static const accountNumber = '1234567890';

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        children: [
          const _PaymentRow(label: 'Bank', value: 'BCA'),
          const _PaymentRow(label: 'No Rekening', value: accountNumber),
          const _PaymentRow(label: 'Atas Nama', value: 'Klinik Mawon'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: accountNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nomor rekening disalin.')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Salin'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashInfo extends StatelessWidget {
  const _CashInfo();

  @override
  Widget build(BuildContext context) {
    return const PrimaryCard(
      child: Text('Pembayaran dilakukan di Klinik Mawon saat kunjungan.'),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
