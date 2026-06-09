import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/schedule_service.dart';
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
  late Future<void> _loadSchedules;
  late List<String> _dates = _initialDates();
  late List<String> _times = List.of(widget.doctor.availableTimes);
  String? _date;
  String? _time;

  @override
  void initState() {
    super.initState();
    _date = _dates.isEmpty ? null : _dates.first;
    _time = _times.isEmpty ? null : _times.first;
    _loadSchedules = _fetchSchedules();
  }

  List<String> _initialDates() {
    if (widget.doctor.availableDates.isNotEmpty) {
      return List.of(widget.doctor.availableDates);
    }
    if (widget.doctor.availableTimes.isNotEmpty) {
      return [_todayIso()];
    }
    return const <String>[];
  }

  String _todayIso() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _fetchSchedules() async {
    final schedules = await ScheduleService().getSchedules(
      doctorId: widget.doctor.id,
    );
    if (schedules.isEmpty || !mounted) return;

    final dates = <String>{};
    final times = <String>{};
    for (final schedule in schedules) {
      final doctorId = _readInt(schedule, ['doctor_id', 'id_dokter']);
      if (doctorId != null && doctorId != widget.doctor.id) continue;

      final date = _readString(schedule, ['date', 'tanggal', 'day', 'hari']);
      final time = _readString(schedule, [
        'time',
        'jam',
        'start_time',
        'jam_mulai',
      ]);
      if (date.isNotEmpty) dates.add(date);
      if (time.isNotEmpty) times.add(time);
    }

    if (dates.isEmpty && times.isEmpty) return;
    setState(() {
      if (dates.isNotEmpty) {
        _dates = dates.toList();
        _date = _dates.first;
      }
      if (times.isNotEmpty) {
        _times = times.toList();
        _time = _times.first;
      }
    });
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final canBook =
        doctor.id > 0 &&
        (_date?.trim().isNotEmpty ?? false) &&
        (_time?.trim().isNotEmpty ?? false);

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
                          Text(
                            doctor.specialty,
                            style: const TextStyle(color: AppColors.textGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(doctor.practiceTime),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tanggal Praktik',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              FutureBuilder<void>(
                future: _loadSchedules,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _dates.isEmpty) {
                    return const CircularProgressIndicator();
                  }
                  if (_dates.isEmpty) {
                    return const Text('Tanggal belum tersedia.');
                  }
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _dates.map((date) {
                      return ChoiceChip(
                        label: Text(date),
                        selected: _date == date,
                        onSelected: (_) => setState(() => _date = date),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Jam Praktik',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (_times.isEmpty)
                const Text('Jam praktik belum tersedia.')
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _times.map((time) {
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
                onPressed: !canBook
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmScreen(
                            doctor: doctor,
                            date: _date!,
                            time: _time!,
                          ),
                        ),
                      ),
                child: const Text('LANJUT BOOKING'),
              ),
              if (!canBook) ...[
                const SizedBox(height: 8),
                Text(
                  doctor.id <= 0
                      ? 'Data dokter tidak valid untuk booking.'
                      : 'Pilih tanggal dan jam praktik terlebih dahulu.',
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
