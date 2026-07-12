import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoFilename;
  String? _photoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile ?? _profileFromSession();
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _addressController = TextEditingController(text: profile.address);
    _photoUrl = profile.photoUrl;
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
      photoUrl: _photoBytes != null ? null : _photoUrl,
    );

    try {
      final updated = await _profileService.updateProfile(
        profile,
        photoBytes: _photoBytes,
        photoFilename: _photoFilename,
      );
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

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoFilename = picked.name;
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
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.lightBlue,
                        foregroundImage: _photoBytes != null
                          ? MemoryImage(_photoBytes!) as ImageProvider
                          : (_photoUrl != null && _photoUrl!.trim().isNotEmpty)
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: _photoBytes == null && (_photoUrl == null || _photoUrl!.trim().isEmpty)
                          ? const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 52,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pilih Foto Profil'),
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
