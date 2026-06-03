import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'main_shell.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kode Antrian')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 76,
              ),
              const SizedBox(height: 10),
              const Text(
                'Pendaftaran Berhasil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              PrimaryCard(
                child: Column(
                  children: [
                    const Text(
                      'Nomor Antrian',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.queueNumber,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 138,
                      height: 138,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, size: 112),
                    ),
                    const SizedBox(height: 16),
                    _TicketRow(label: 'Kode Booking', value: booking.code),
                    _TicketRow(label: 'Pasien', value: booking.patientName),
                    _TicketRow(label: 'Dokter', value: booking.doctor.name),
                    _TicketRow(
                      label: 'Jadwal',
                      value: '${booking.date}, ${booking.time}',
                    ),
                    _TicketRow(label: 'Status', value: 'Terjadwal'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                ),
                child: const Text('KEMBALI KE HOME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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
