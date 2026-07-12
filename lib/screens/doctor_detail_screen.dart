import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../theme/app_theme.dart';
import '../widgets/doctor_avatar.dart';
import '../widgets/primary_card.dart';
import 'booking_confirm_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late final Map<String, List<String>> _scheduleOptions =
      _initialScheduleOptions();
  late List<String> _dates = _scheduleOptions.keys.toList();
  List<String> _times = const <String>[];
  String? _date;
  String? _time;

  @override
  void initState() {
    super.initState();
    _selectFirstAvailableSlot();
  }

  Map<String, List<String>> _initialScheduleOptions() {
    if (widget.doctor.availableDates.isEmpty) {
      if (widget.doctor.availableTimes.isEmpty) return const {};
      return {_todayIso(): List.of(widget.doctor.availableTimes)};
    }

    return {
      for (final date in widget.doctor.availableDates)
        date: List.of(widget.doctor.availableTimes),
    };
  }

  void _selectFirstAvailableSlot() {
    _dates = _scheduleOptions.keys.toList()..sort();
    _date = _dates.isEmpty ? null : _dates.first;
    _times = _date == null
        ? const <String>[]
        : List.of(_scheduleOptions[_date] ?? const <String>[]);
    _time = _times.isEmpty ? null : _times.first;
  }

  String _todayIso() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  void _selectDate(String date) {
    setState(() {
      _date = date;
      _times = List.of(_scheduleOptions[date] ?? const <String>[]);
      _time = _times.isEmpty ? null : _times.first;
    });
  }

  String _dateLabel(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(parsed.year, parsed.month, parsed.day);
    final difference = selectedDate.difference(todayDate).inDays;
    final dayName = switch (parsed.weekday) {
      DateTime.monday => 'Senin',
      DateTime.tuesday => 'Selasa',
      DateTime.wednesday => 'Rabu',
      DateTime.thursday => 'Kamis',
      DateTime.friday => 'Jumat',
      DateTime.saturday => 'Sabtu',
      _ => 'Minggu',
    };

    final prefix = switch (difference) {
      0 => 'Hari ini',
      1 => 'Besok',
      _ => dayName,
    };
    return '$prefix\n${parsed.day}/${parsed.month}/${parsed.year}';
  }

  String _statusText() {
    if (widget.doctor.id <= 0) return 'Data dokter tidak valid.';
    if (_date == null || _time == null) return 'Jadwal belum tersedia.';
    return 'Jadwal tersedia pada ${_dateLabel(_date!).replaceAll('\n', ', ')} pukul $_time';
  }

  Color _statusColor() {
    if (widget.doctor.id <= 0 || _date == null || _time == null) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  IconData _statusIcon() {
    if (widget.doctor.id <= 0 || _date == null || _time == null) {
      return Icons.info_outline_rounded;
    }
    return Icons.check_circle_rounded;
  }

  List<Widget> _dateChips() {
    if (_dates.isEmpty) return [const Text('Tanggal belum tersedia.')];
    return _dates.map((date) {
      return ChoiceChip(
        label: Text(_dateLabel(date), textAlign: TextAlign.center),
        selected: _date == date,
        onSelected: (_) => _selectDate(date),
      );
    }).toList();
  }

  List<Widget> _timeChips() {
    if (_times.isEmpty) return [const Text('Jam praktik belum tersedia.')];
    return _times.map((time) {
      return ChoiceChip(
        label: Text(time),
        selected: _time == time,
        onSelected: (_) {
          setState(() => _time = time);
        },
      );
    }).toList();
  }

  void _continueBooking(Doctor doctor) {
    final selectedDate = _date;
    final selectedTime = _time;
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal dan jam praktik terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingConfirmScreen(
          doctor: doctor,
          date: selectedDate,
          time: selectedTime,
        ),
      ),
    );
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
                    DoctorAvatar(doctor: doctor, radius: 38),
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
                          Text(doctor.schedule),
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
              Wrap(spacing: 10, runSpacing: 10, children: _dateChips()),
              const SizedBox(height: 18),
              const Text(
                'Jam Praktik',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 10, runSpacing: 10, children: _timeChips()),
              const SizedBox(height: 18),
              PrimaryCard(
                child: Row(
                  children: [
                    Icon(_statusIcon(), color: _statusColor()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusText(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: !canBook ? null : () => _continueBooking(doctor),
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
