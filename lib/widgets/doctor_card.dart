import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../theme/app_theme.dart';
import 'primary_card.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.actionText = 'Booking',
  });

  final Doctor doctor;
  final VoidCallback onTap;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lightBlue,
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${doctor.specialty} - ${doctor.polyclinic}',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.practiceTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(actionText)),
        ],
      ),
    );
  }
}
