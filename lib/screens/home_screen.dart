import 'package:flutter/material.dart';

import '../core/services/session_manager.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/doctor_card.dart';
import '../widgets/primary_card.dart';
import 'doctor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Doctor>> _loadDoctors;

  @override
  void initState() {
    super.initState();
    _loadDoctors = DoctorService().getDoctors();
  }

  void _reloadDoctors() {
    setState(() => _loadDoctors = DoctorService().getDoctors());
  }

  String get _userName {
    return SessionManager.getDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Doctor>>(
          future: _loadDoctors,
          builder: (context, snapshot) {
            final doctors = snapshot.data ?? const <Doctor>[];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Hi, $_userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
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
                        Icon(
                          Icons.health_and_safety_rounded,
                          color: Colors.white,
                          size: 58,
                        ),
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
                        onTap: () => widget.onOpenTab(1),
                      ),
                      _QuickMenu(
                        icon: Icons.calendar_month_rounded,
                        label: 'Jadwal',
                        onTap: () => widget.onOpenTab(1),
                      ),
                      _QuickMenu(
                        icon: Icons.event_available_rounded,
                        label: 'Booking',
                        onTap: () => widget.onOpenTab(2),
                      ),
                      _QuickMenu(
                        icon: Icons.receipt_long_rounded,
                        label: 'Riwayat',
                        onTap: () => widget.onOpenTab(3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(
                    title: 'Daftar Dokter',
                    action: 'Lihat semua',
                    onTap: () => widget.onOpenTab(1),
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    _InlineState(
                      message: 'Gagal memuat dokter dari API.',
                      onRetry: _reloadDoctors,
                    )
                  else if (doctors.isEmpty)
                    _InlineState(
                      message: 'Belum ada dokter dari API.',
                      onRetry: _reloadDoctors,
                    )
                  else
                    ...doctors
                        .take(2)
                        .map(
                          (doctor) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DoctorCard(
                              doctor: doctor,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DoctorDetailScreen(doctor: doctor),
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  const _SectionTitle(title: 'Jadwal Terdekat'),
                  const SizedBox(height: 12),
                  if (doctors.isEmpty)
                    const PrimaryCard(child: Text('Jadwal belum tersedia.'))
                  else
                    PrimaryCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${doctors.first.name} - ${doctors.first.practiceTime}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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

class _InlineState extends StatelessWidget {
  const _InlineState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
