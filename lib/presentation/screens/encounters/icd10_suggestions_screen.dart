// NgakaAssist
// Screen: ICD-10 suggestions.
// Accept/reject suggestions (mock persists locally; backend persistence is TODO).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/encounter_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';

class Icd10SuggestionsScreen extends ConsumerWidget {
  const Icd10SuggestionsScreen({super.key, required this.encounterId});

  final String encounterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(encounterControllerProvider(encounterId));
    final ctrl = ref.read(encounterControllerProvider(encounterId).notifier);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('ICD-10 suggestions'),
          actions: [
            FilledButton.tonal(
              onPressed: () => context.go('/encounters/$encounterId/review'),
              child: const Text('Review'),
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
                child: vm.icd10.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const EmptyState(
                        title: 'No suggestions yet',
                        subtitle: 'Continue the consultation or edit the SOAP draft.',
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final s = list[i];
                        return SectionCard(
                          title: '${s.code} — ${s.description}',
                          trailing: Text('${(s.confidence * 100).round()}%'),
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: vm.isSigned
                                      ? null
                                      : () async {
                                          final res = await ctrl.setIcdAccepted(s.code, true);
                                          if (!context.mounted) return;
                                          if (!res.isOk) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(res.failure?.message ?? 'Could not accept diagnosis')),
                                            );
                                          }
                                        },
                                  child: Text(s.accepted ? 'Accepted' : 'Accept'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonal(
                                  onPressed: vm.isSigned
                                      ? null
                                      : () async {
                                          final res = await ctrl.setIcdAccepted(s.code, false);
                                          if (!context.mounted) return;
                                          if (!res.isOk) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(res.failure?.message ?? 'Could not reject diagnosis')),
                                            );
                                          }
                                        },
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(title: 'Could not load suggestions', subtitle: e.toString()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
