import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Doctor>> _loadDoctors;

  @override
  void initState() {
    super.initState();
    _loadDoctors = DoctorService().getDoctors();
  }

  void _reload() {
    setState(() => _loadDoctors = DoctorService().getDoctors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelayanan Klinik')),
      body: SafeArea(
        child: FutureBuilder<List<Doctor>>(
          future: _loadDoctors,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _StateMessage(
                icon: Icons.error_outline_rounded,
                message: 'Gagal memuat data dokter.\n${snapshot.error}',
                actionText: 'Coba lagi',
                onAction: _reload,
              );
            }

            final doctors = snapshot.data ?? const <Doctor>[];
            if (doctors.isEmpty) {
              return _StateMessage(
                icon: Icons.medical_services_outlined,
                message: 'Belum ada data dokter dari API.',
                actionText: 'Muat ulang',
                onAction: _reload,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorCard(
                  doctor: doctor,
                  actionText: 'Detail',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailScreen(doctor: doctor),
                    ),
                  ),
                );
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
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
