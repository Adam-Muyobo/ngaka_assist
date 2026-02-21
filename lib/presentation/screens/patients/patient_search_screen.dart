// NgakaAssist
// Screen: Patient search.
// Wide layouts show a preview pane for a selected patient.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../state/patient_search_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';

class PatientSearchScreen extends ConsumerStatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  ConsumerState<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends ConsumerState<PatientSearchScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String? _selectedPatientId;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(patientSearchControllerProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Patients'),
          actions: [
            IconButton(
              tooltip: 'Create patient',
              onPressed: () => context.go('/patients/create'),
              icon: const Icon(Icons.person_add_alt_1),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = isWide(constraints.maxWidth);

              final listPane = Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Name, national ID, or patient ID',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) {
                        _debounce?.cancel();
                        _debounce = Timer(kUiDebounce, () {
                          ref.read(patientSearchControllerProvider.notifier).search(v);
                        });
                      },
                      onSubmitted: (v) => ref.read(patientSearchControllerProvider.notifier).search(v),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: vm.results.when(
                        data: (patients) {
                          if (patients.isEmpty) {
                            return EmptyState(
                              title: 'No patients found',
                              subtitle: 'Try a different query or create a new patient.',
                              action: FilledButton.tonal(
                                onPressed: () => context.go('/patients/create'),
                                child: const Text('Create patient'),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: patients.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final p = patients[i];
                              final selected = _selectedPatientId == p.id;
                              return SectionCard(
                                title: p.displayName,
                                trailing: selected ? const Icon(Icons.check_circle) : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${p.id}  •  Gender: ${p.gender}'),
                                    if ((p.nationalId ?? '').isNotEmpty) Text('National ID: ${p.nationalId}'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton.tonal(
                                            onPressed: () {
                                              if (wide) {
                                                setState(() => _selectedPatientId = p.id);
                                              } else {
                                                context.go('/patients/${p.id}');
                                              }
                                            },
                                            child: Text(wide ? 'Preview' : 'Open'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () => context.go('/patients/${p.id}/start-encounter'),
                                            child: const Text('Start encounter'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => EmptyState(title: 'Could not load patients', subtitle: e.toString()),
                      ),
                    ),
                  ],
                ),
              );

              if (!wide) return listPane;

              final previewId = _selectedPatientId;
              final previewPane = Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                child: SectionCard(
                  title: 'Preview',
                  child: previewId == null
                      ? const EmptyState(
                          title: 'Select a patient',
                          subtitle: 'Use Preview to see details side-by-side.',
                        )
                      : _PatientPreview(patientId: previewId),
                ),
              );

              return Row(
                children: [
                  Expanded(flex: 6, child: listPane),
                  Expanded(flex: 5, child: previewPane),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PatientPreview extends StatelessWidget {
  const _PatientPreview({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Patient ID: $patientId'),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => context.go('/patients/$patientId'),
          child: const Text('Open full profile'),
        ),
        const SizedBox(height: 10),
        FilledButton.tonal(
          onPressed: () => context.go('/patients/$patientId/start-encounter'),
          child: const Text('Start encounter'),
        ),
        const SizedBox(height: 10),
        Text(
          'TODO(ngakaassist): Show vitals, allergies, chronic problems, and last encounter summary here.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
