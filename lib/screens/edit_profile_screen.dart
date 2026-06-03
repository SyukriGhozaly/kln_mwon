import 'package:flutter/material.dart';

import '../services/dummy_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _required(String? value) =>
      value == null || value.isEmpty ? 'Field wajib diisi' : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan.')),
    );
    Navigator.of(context).pop();
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
                    child: Icon(Icons.person_rounded, color: AppColors.primary, size: 52),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    initialValue: DummyDataService.userName,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: DummyDataService.userEmail,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: DummyDataService.userPhone,
                    decoration: const InputDecoration(labelText: 'No HP'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: 'Jl. Sehat Mawon No. 10',
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator: _required,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(onPressed: _save, child: const Text('SAVE')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
