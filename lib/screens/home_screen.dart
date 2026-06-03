import 'package:flutter/material.dart';

import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/doctor_card.dart';
import '../widgets/primary_card.dart';
import 'doctor_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final doctors = DummyDataService.doctors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Hi, Rizky Mawon',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih layanan kesehatanmu',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking mudah tanpa antre panjang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cek dokter, pilih jadwal, bayar, lalu datang sesuai nomor antrian.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 58),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _QuickMenu(
                    icon: Icons.groups_rounded,
                    label: 'Dokter',
                    onTap: () => onOpenTab(1),
                  ),
                  _QuickMenu(
                    icon: Icons.calendar_month_rounded,
                    label: 'Jadwal',
                    onTap: () => onOpenTab(1),
                  ),
                  _QuickMenu(
                    icon: Icons.event_available_rounded,
                    label: 'Booking',
                    onTap: () => onOpenTab(2),
                  ),
                  _QuickMenu(
                    icon: Icons.receipt_long_rounded,
                    label: 'Riwayat',
                    onTap: () => onOpenTab(3),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SectionTitle(title: 'Daftar Dokter', action: 'Lihat semua', onTap: () => onOpenTab(1)),
              const SizedBox(height: 12),
              ...doctors.take(2).map(
                    (doctor) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DoctorCard(
                        doctor: doctor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctor: doctor),
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 10),
              const _SectionTitle(title: 'Jadwal Terdekat'),
              const SizedBox(height: 12),
              PrimaryCard(
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${doctors.first.name} - Hari ini pukul ${doctors.first.availableTimes.first}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}
