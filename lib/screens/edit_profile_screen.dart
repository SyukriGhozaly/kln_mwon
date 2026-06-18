import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/services/session_manager.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.profile});

  final ProfileData? profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _profileService = ProfileService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile ?? _profileFromSession();
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _addressController = TextEditingController(text: profile.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Field wajib diisi' : null;

  String? _emailValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final email = value!.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : 'Format email tidak valid';
  }

  String? _phoneValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final phone = value!.trim();
    if (phone.length < 8) return 'No HP terlalu pendek';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final profile = ProfileData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    try {
      final updated = await _profileService.updateProfile(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(updated);
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('Profil gagal disimpan. $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  ProfileData _profileFromSession() {
    final user = SessionManager.user ?? const <String, dynamic>{};
    return ProfileData.fromJson({
      'name': user['name'] ?? user['nama'] ?? '',
      'email': user['email'] ?? '',
      'phone': user['phone'] ?? user['no_hp'] ?? '',
      'address': user['address'] ?? user['alamat'] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: PrimaryCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.lightBlue,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'No HP'),
                    validator: _phoneValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator: _required,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('SAVE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
