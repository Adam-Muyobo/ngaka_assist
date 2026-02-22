// NgakaAssist
// Screen: Create patient.
// UI-only MVP; persists through PatientRepository (mock by default).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
    final cs = Theme.of(context).colorScheme;

    Widget fieldShell(Widget child) {
      final fill = Color.alphaBlend(cs.primary.withOpacity(0.03), cs.surface);
      final innerLight = Colors.white.withOpacity(0.85);
      final innerDark = Colors.black.withOpacity(0.18);
      return DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: innerLight,
              offset: const Offset(-3, -3),
              blurRadius: 10,
              spreadRadius: -2,
              blurStyle: BlurStyle.inner,
            ),
            BoxShadow(
              color: innerDark,
              offset: const Offset(3, 3),
              blurRadius: 12,
              spreadRadius: -2,
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, top: 2),
          child: child,
        ),
      );
    }

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
                  title: 'New patient',
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(cs.primary.withOpacity(0.12), cs.surface),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.75),
                                    offset: const Offset(-6, -6),
                                    blurRadius: 14,
                                    spreadRadius: -8,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    offset: const Offset(6, 6),
                                    blurRadius: 16,
                                    spreadRadius: -10,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.person_add_alt_1, color: cs.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Capture demographics and identifiers. Omang and phone are required for Botswana workflows.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: fieldShell(
                                TextFormField(
                                  controller: _first,
                                  decoration: const InputDecoration(
                                    labelText: 'First name',
                                    filled: false,
                                    border: InputBorder.none,
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => Validators.personName(v, label: 'First name'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: fieldShell(
                                TextFormField(
                                  controller: _last,
                                  decoration: const InputDecoration(
                                    labelText: 'Last name',
                                    filled: false,
                                    border: InputBorder.none,
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => Validators.personName(v, label: 'Last name'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        fieldShell(
                          TextFormField(
                            controller: _dob,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of birth',
                              filled: false,
                              border: InputBorder.none,
                              suffixIcon: Icon(Icons.calendar_month),
                            ),
                            onTap: _saving ? null : _pickDob,
                            validator: (v) => Validators.requiredField(v, label: 'Date of birth'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder(
                          valueListenable: _gender,
                          builder: (context, g, _) {
                            return fieldShell(
                              DropdownButtonFormField<String>(
                                value: g,
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  filled: false,
                                  border: InputBorder.none,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'female', child: Text('Female')),
                                  DropdownMenuItem(value: 'male', child: Text('Male')),
                                  DropdownMenuItem(value: 'other', child: Text('Other')),
                                ],
                                onChanged: (v) => _gender.value = v ?? 'other',
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        fieldShell(
                          TextFormField(
                            controller: _nationalId,
                            decoration: const InputDecoration(
                              labelText: 'Omang (National ID)',
                              hintText: '9 digits',
                              filled: false,
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            validator: (v) => Validators.bwNationalId(v, label: 'Omang'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        fieldShell(
                          TextFormField(
                            controller: _phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: '+267 7X XXX XXX',
                              filled: false,
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                              LengthLimitingTextInputFormatter(16),
                            ],
                            validator: (v) => Validators.bwPhoneNumber(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _saving ? null : () => _onSave(context),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(_saving ? 'Saving...' : 'Create patient'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tip: Enter Omang as 9 digits and we will store the phone in +267 format.',
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

    final omang = _nationalId.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final phone = Validators.normalizeBwPhoneNumber(_phone.text);
    final res = await repo.createPatient(
      Patient(
        id: '',
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        dateOfBirth: _dobValue,
        gender: _gender.value,
        nationalId: omang,
        phone: phone,
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
