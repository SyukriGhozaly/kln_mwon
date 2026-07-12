import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/session_manager.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';
import 'edit_profile_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<void> _loadProfile;
  ProfileData _profile = ProfileData(
    name: SessionManager.getDisplayName(),
    email: _sessionValue(['email'], '-'),
    phone: _sessionValue(['phone', 'no_hp'], '-'),
    address: _sessionValue(['address', 'alamat'], '-'),
  );

  @override
  void initState() {
    super.initState();
    _loadProfile = _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await ProfileService().getProfile();
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  void _reload() {
    setState(() => _loadProfile = _fetchProfile());
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun Klinik Mawon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;

    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  static String _sessionValue(List<String> keys, String fallback) {
    final user = SessionManager.user;
    if (user == null) return fallback;

    for (final key in keys) {
      final value = user[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : snapshot.error.toString();
              return _ProfileState(
                message: 'Gagal memuat profil.\n$message',
                onRetry: _reload,
              );
            }

            return RefreshIndicator(
              onRefresh: _fetchProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    _ProfileAvatar(photoUrl: _profile.photoUrl),
                  const SizedBox(height: 12),
                  Text(
                    _profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile.email,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 20),
                  PrimaryCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileMenu(
                          icon: Icons.edit_rounded,
                          title: 'Edit Profil',
                          onTap: () async {
                            final updated = await Navigator.of(context)
                                .push<ProfileData>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProfileScreen(profile: _profile),
                                  ),
                                );
                            if (!mounted) return;
                            if (updated != null) {
                              setState(() => _profile = updated);
                            } else {
                              _reload();
                            }
                          },
                        ),
                        _ProfileInfo(
                          icon: Icons.phone_outlined,
                          label: 'No HP',
                          value: _profile.phone,
                        ),
                        _ProfileInfo(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat',
                          value: _profile.address,
                        ),
                        _ProfileMenu(
                          icon: Icons.history_rounded,
                          title: 'Riwayat',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          ),
                        ),
                        _ProfileMenu(
                          icon: Icons.settings_rounded,
                          title: 'Pengaturan',
                          onTap: () => _showInfo(
                            'Pengaturan',
                            'Pengaturan aplikasi belum tersedia.',
                          ),
                        ),
                        _ProfileMenu(
                          icon: Icons.help_outline_rounded,
                          title: 'Bantuan',
                          onTap: () => _showInfo(
                            'Bantuan',
                            'Hubungi 0857-0109-4305 jika ada kendala booking atau pembayaran. ',
                          ),
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
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim() ?? '';
    return Container(
      width: 96,
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightBlue,
      ),
      child: url.isEmpty
          ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 58)
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 58,
              ),
            ),
    );
  }
}

class _ProfileState extends StatelessWidget {
  const _ProfileState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty || value == '-'
        ? 'Belum diisi'
        : value;

    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(displayValue),
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
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
