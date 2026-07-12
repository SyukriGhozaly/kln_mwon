import 'package:flutter/material.dart';

import '../core/constants/api_config.dart';
import '../models/doctor.dart';
import '../theme/app_theme.dart';

class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({super.key, required this.doctor, this.radius = 30});

  final Doctor doctor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.lightBlue,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _PlaceholderIcon(size: radius + 4)
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _PlaceholderIcon(size: radius + 4),
            ),
    );
  }

  String? get photoUrl {
    final photo = doctor.imageUrl.trim();
    if (photo.isEmpty) return null;
    return ApiConfig.publicFileUrl(photo);
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.person_rounded, color: AppColors.primary, size: size);
  }
}
