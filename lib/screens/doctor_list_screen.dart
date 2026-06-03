import 'package:flutter/material.dart';

import '../services/dummy_data_service.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = DummyDataService.doctors;

    return Scaffold(
      appBar: AppBar(title: const Text('Pelayanan Klinik')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return DoctorCard(
              doctor: doctor,
              actionText: 'Detail',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doctor)),
              ),
            );
          },
        ),
      ),
    );
  }
}
