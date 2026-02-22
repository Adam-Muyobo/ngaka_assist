// NgakaAssist
// Screen: Create patient.
// UI-only MVP; persists through PatientRepository (mock by default).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/entities/patient.dart';
import '../../state/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class CreatePatientScreen extends ConsumerStatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  ConsumerState<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends ConsumerState<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _dob = TextEditingController();
  final _gender = ValueNotifier<String>('female');
  final _nationalId = TextEditingController();
  final _phone = TextEditingController();

  DateTime? _dobValue;

  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _dob.dispose();
    _nationalId.dispose();
    _phone.dispose();
    _gender.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dobValue ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dobValue = DateTime(picked.year, picked.month, picked.day);
      _dob.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Create patient')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SectionCard(
                  title: 'Patient details',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _first,
                                decoration: const InputDecoration(labelText: 'First name'),
                                validator: (v) => Validators.requiredField(v, label: 'First name'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _last,
                                decoration: const InputDecoration(labelText: 'Last name'),
                                validator: (v) => Validators.requiredField(v, label: 'Last name'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dob,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Date of birth'),
                          onTap: _saving ? null : _pickDob,
                          validator: (v) => Validators.requiredField(v, label: 'Date of birth'),
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder(
                          valueListenable: _gender,
                          builder: (context, g, _) {
                            return DropdownButtonFormField<String>(
                              value: g,
                              decoration: const InputDecoration(labelText: 'Gender'),
                              items: const [
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (v) => _gender.value = v ?? 'other',
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nationalId,
                          decoration: const InputDecoration(labelText: 'National ID (optional)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phone,
                          decoration: const InputDecoration(labelText: 'Phone (optional)'),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : () => _onSave(context),
                          child: Text(_saving ? 'Saving...' : 'Create patient'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'TODO(ngakaassist): Add DOB picker, address fields, next-of-kin, and patient identifiers.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(patientRepositoryProvider);
    final res = await repo.createPatient(
      Patient(
        id: '',
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        dateOfBirth: _dobValue,
        gender: _gender.value,
        nationalId: _nationalId.text.trim().isEmpty ? null : _nationalId.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (res.isOk) {
      final created = res.data as Patient;
      context.go('/patients/${created.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.failure?.message ?? 'Could not create patient')));
    }
  }
}
