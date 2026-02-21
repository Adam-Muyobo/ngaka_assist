// NgakaAssist
// Screen: Patient profile + encounter history.
// Wide layouts keep content readable with a centered max width.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../state/patient_profile_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(patientProfileControllerProvider(patientId));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Patient profile'),
          actions: [
            FilledButton.tonal(
              onPressed: () => context.go('/patients/$patientId/start-encounter'),
              child: const Text('Start encounter'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: vm.when(
                  data: (state) {
                    final pVal = state.patient;
                    return pVal.when(
                      data: (p) {
                        return ListView(
                          children: [
                            SectionCard(
                              title: p.displayName,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Patient ID: ${p.id}'),
                                  const SizedBox(height: 6),
                                  Text('Gender: ${p.gender}'),
                                  if (p.phone != null) Text('Phone: ${p.phone}'),
                                  if (p.nationalId != null) Text('National ID: ${p.nationalId}'),
                                  const SizedBox(height: 12),
                                  Text(
                                    'TODO(ngakaassist): Allergies, chronic conditions, medications, labs, audit log.',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SectionCard(
                              title: 'Encounter history',
                              child: state.history.when(
                                data: (list) {
                                  if (list.isEmpty) {
                                    return EmptyState(
                                      title: 'No encounters yet',
                                      subtitle: 'Start a new encounter to begin documentation.',
                                      action: FilledButton(
                                        onPressed: () => context.go('/patients/$patientId/start-encounter'),
                                        child: const Text('Start encounter'),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: [
                                      for (final e in list)
                                        ListTile(
                                          leading: Icon(e.isSigned ? Icons.verified : Icons.edit_note),
                                          title: Text(e.type),
                                          subtitle: Text('Started: ${AppFormatters.dateTime(e.startedAt)}'),
                                          trailing: FilledButton.tonal(
                                            onPressed: () => context.go('/encounters/${e.id}/review'),
                                            child: const Text('Open'),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                                loading: () => const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                error: (e, _) => Text(e.toString()),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => EmptyState(title: 'Could not load patient', subtitle: e.toString()),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(title: 'Could not load profile', subtitle: e.toString()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
