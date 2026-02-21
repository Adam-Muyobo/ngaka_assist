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
  final _gender = ValueNotifier<String>('female');
  final _nationalId = TextEditingController();
  final _phone = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _nationalId.dispose();
    _phone.dispose();
    _gender.dispose();
    super.dispose();
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
                                DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                              ],
                              onChanged: (v) => _gender.value = v ?? 'unknown',
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
        dateOfBirth: null,
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
