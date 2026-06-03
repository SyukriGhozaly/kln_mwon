import 'package:flutter/material.dart';

import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'edit_profile_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.lightBlue,
                child: Icon(Icons.person_rounded, color: AppColors.primary, size: 58),
              ),
              const SizedBox(height: 12),
              const Text(
                DummyDataService.userName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                DummyDataService.userEmail,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              PrimaryCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileMenu(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profil',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ),
                    ),
                    _ProfileMenu(
                      icon: Icons.history_rounded,
                      title: 'Riwayat',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ),
                    ),
                    _ProfileMenu(
                      icon: Icons.settings_rounded,
                      title: 'Pengaturan',
                      onTap: () {},
                    ),
                    _ProfileMenu(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan',
                      onTap: () {},
                    ),
                    _ProfileMenu(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Klinik Mawon',
                        applicationVersion: '0.1.0',
                      ),
                    ),
                    _ProfileMenu(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      danger: true,
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textDark;

    return ListTile(
      leading: Icon(icon, color: danger ? AppColors.danger : AppColors.primary),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
