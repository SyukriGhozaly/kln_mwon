import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
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
  late final Future<List<Doctor>> _loadDoctors = DoctorService().getDoctors();

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
              final error = snapshot.error;
              final message = error is ApiException
                  ? error.message
                  : 'Gagal memuat daftar dokter dari API.';
              return _ApiError(message: message);
            }

            final doctors = snapshot.data ?? const <Doctor>[];
            if (doctors.isEmpty) {
              return const Center(child: Text('Data dokter belum tersedia.'));
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

class _ApiError extends StatelessWidget {
  const _ApiError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
