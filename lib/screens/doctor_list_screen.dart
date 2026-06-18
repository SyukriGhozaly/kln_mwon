import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/doctor_card.dart';
import '../widgets/primary_card.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _searchController = TextEditingController();
  late Future<List<Doctor>> _loadDoctors;
  String _query = '';
  String _selectedSpecialty = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadDoctors = DoctorService().getDoctors();
  }

  void _reload() {
    setState(() => _loadDoctors = DoctorService().getDoctors());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filteredDoctors(List<Doctor> doctors) {
    final normalizedQuery = _query.toLowerCase().trim();
    return doctors.where((doctor) {
      final matchesSpecialty =
          _selectedSpecialty == 'Semua' ||
          doctor.specialty == _selectedSpecialty ||
          doctor.polyclinic == _selectedSpecialty;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          doctor.name.toLowerCase().contains(normalizedQuery) ||
          doctor.specialty.toLowerCase().contains(normalizedQuery) ||
          doctor.polyclinic.toLowerCase().contains(normalizedQuery);
      return matchesSpecialty && matchesQuery;
    }).toList();
  }

  List<String> _filterOptions(List<Doctor> doctors) {
    final values = <String>{'Semua'};
    for (final doctor in doctors) {
      if (doctor.specialty.trim().isNotEmpty) values.add(doctor.specialty);
      if (doctor.polyclinic.trim().isNotEmpty && doctor.polyclinic != 'Poli') {
        values.add(doctor.polyclinic);
      }
    }
    return values.toList();
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

            final filteredDoctors = _filteredDoctors(doctors);
            final filterOptions = _filterOptions(doctors);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PrimaryCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Cari nama dokter atau spesialis',
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filterOptions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final option = filterOptions[index];
                            return ChoiceChip(
                              label: Text(option),
                              selected: _selectedSpecialty == option,
                              onSelected: (_) {
                                setState(() => _selectedSpecialty = option);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (filteredDoctors.isEmpty)
                  _InlineEmptyState(
                    onReset: () {
                      setState(() {
                        _query = '';
                        _selectedSpecialty = 'Semua';
                        _searchController.clear();
                      });
                    },
                  )
                else
                  ...filteredDoctors.map(
                    (doctor) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DoctorCard(
                        doctor: doctor,
                        actionText: 'Detail',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctor: doctor),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.textGrey,
            size: 42,
          ),
          const SizedBox(height: 10),
          const Text(
            'Dokter tidak ditemukan.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci atau filter lain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onReset, child: const Text('Reset filter')),
        ],
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
