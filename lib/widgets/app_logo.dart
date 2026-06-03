import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 86});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.local_hospital_rounded,
        color: AppColors.primary,
        size: size * 0.56,
      ),
    );
  }
}
