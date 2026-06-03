import 'package:flutter/material.dart';

import '../services/dummy_data_service.dart';
import '../services/doctor_service.dart';
import '../widgets/doctor_card.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late final Future<void> _loadDoctors = _fetchDoctors();
  var _doctors = DummyDataService.doctors;
  String? _errorMessage;

  Future<void> _fetchDoctors() async {
    try {
      final doctors = await DoctorService().getDoctors();
      if (!mounted || doctors.isEmpty) return;
      setState(() {
        _doctors = doctors;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Gagal memuat dokter dari API: $error');
      setState(() {
        _errorMessage = 'API belum tersambung, sementara memakai data dummy.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelayanan Klinik')),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadDoctors,
          builder: (context, snapshot) {
            final doctors = _doctors;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length + (_errorMessage == null ? 0 : 1),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (_errorMessage != null && index == 0) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFC2410C),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_errorMessage!)),
                      ],
                    ),
                  );
                }

                final offset = _errorMessage == null ? index : index - 1;
                final doctor = doctors[offset];
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
