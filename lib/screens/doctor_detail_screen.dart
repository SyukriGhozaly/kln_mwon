import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'booking_confirm_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late String _date = widget.doctor.availableDates.first;
  late String _time = widget.doctor.availableTimes.first;

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Jadwal Dokter')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.lightBlue,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(doctor.specialty, style: const TextStyle(color: AppColors.textGrey)),
                          const SizedBox(height: 8),
                          Text(doctor.practiceTime),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('Tanggal Praktik', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: doctor.availableDates.map((date) {
                  return ChoiceChip(
                    label: Text(date),
                    selected: _date == date,
                    onSelected: (_) => setState(() => _date = date),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text('Jam Praktik', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: doctor.availableTimes.map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: _time == time,
                    onSelected: (_) => setState(() => _time = time),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              PrimaryCard(
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: AppColors.success),
                    SizedBox(width: 10),
                    Text('Status jadwal tersedia'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingConfirmScreen(
                      doctor: doctor,
                      date: _date,
                      time: _time,
                    ),
                  ),
                ),
                child: const Text('LANJUT BOOKING'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
