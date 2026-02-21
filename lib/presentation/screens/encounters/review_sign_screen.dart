// NgakaAssist
// Screen: Review & Sign.
// Locks encounter after signing (mock persists a signed_at marker locally).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/encounter_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class ReviewSignScreen extends ConsumerWidget {
  const ReviewSignScreen({super.key, required this.encounterId});

  final String encounterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(encounterControllerProvider(encounterId));
    final ctrl = ref.read(encounterControllerProvider(encounterId).notifier);

    final draft = vm.soapDraft.valueOrNull;
    final accepted = (vm.icd10.valueOrNull ?? const []).where((s) => s.accepted).toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Review & sign'),
          actions: [
            FilledButton.tonal(
              onPressed: () => context.go('/encounters/$encounterId/consult'),
              child: const Text('Back to consult'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    if (vm.isSigned)
                      SectionCard(
                        title: 'Signed',
                        child: Text(
                          'This encounter is locked. Editing is disabled.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      SectionCard(
                        title: 'Ready to sign',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Confirm the SOAP note and diagnoses are correct.'),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () async {
                                final res = await ctrl.sign();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.isOk ? 'Signed' : (res.failure?.message ?? 'Sign failed')),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.verified),
                              label: const Text('Sign encounter'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'TODO(ngakaassist): Add clinician PIN/biometric signing and audit log entry.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    SectionCard(
                      title: 'SOAP summary',
                      child: draft == null
                          ? const Text('Loading...')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('S: ${draft.subjective}'),
                                const SizedBox(height: 8),
                                Text('O: ${draft.objective}'),
                                const SizedBox(height: 8),
                                Text('A: ${draft.assessment}'),
                                const SizedBox(height: 8),
                                Text('P: ${draft.plan}'),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      title: 'Diagnoses (ICD-10 accepted)',
                      child: accepted.isEmpty
                          ? const Text('None accepted yet.')
                          : Column(
                              children: [
                                for (final d in accepted)
                                  ListTile(
                                    title: Text('${d.code} — ${d.description}'),
                                    trailing: Text('${(d.confidence * 100).round()}%'),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => context.go('/encounters/$encounterId/soap'),
                            child: const Text('Edit SOAP'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => context.go('/encounters/$encounterId/icd10'),
                            child: const Text('Edit ICD-10'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
