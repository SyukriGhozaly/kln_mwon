import 'package:flutter/material.dart';

import '../widgets/primary_card.dart';
import 'doctor_list_screen.dart';

class PaymentEntryScreen extends StatelessWidget {
  const PaymentEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_available_rounded, size: 54),
                const SizedBox(height: 12),
                const Text(
                  'Mulai Booking Jadwal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih dokter dan jadwal praktik terlebih dahulu untuk melanjutkan pembayaran.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                  ),
                  child: const Text('PILIH JADWAL'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
