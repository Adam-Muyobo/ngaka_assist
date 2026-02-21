// NgakaAssist
// Screen: SOAP note draft editor.
// Edits S/O/A/P sections and saves via EncounterRepository.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/soap_draft_note.dart';
import '../../state/encounter_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class SoapEditorScreen extends ConsumerStatefulWidget {
  const SoapEditorScreen({super.key, required this.encounterId});

  final String encounterId;

  @override
  ConsumerState<SoapEditorScreen> createState() => _SoapEditorScreenState();
}

class _SoapEditorScreenState extends ConsumerState<SoapEditorScreen> {
  final _s = TextEditingController();
  final _o = TextEditingController();
  final _a = TextEditingController();
  final _p = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _s.dispose();
    _o.dispose();
    _a.dispose();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(encounterControllerProvider(widget.encounterId));
    final ctrl = ref.read(encounterControllerProvider(widget.encounterId).notifier);

    final draft = vm.soapDraft.valueOrNull;
    if (!_seeded && draft != null) {
      _seeded = true;
      _s.text = draft.subjective;
      _o.text = draft.objective;
      _a.text = draft.assessment;
      _p.text = draft.plan;
    }

    final locked = vm.isSigned;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('SOAP draft'),
          actions: [
            FilledButton.tonal(
              onPressed: () => context.go('/encounters/${widget.encounterId}/icd10'),
              child: const Text('ICD-10'),
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
                child: vm.soapDraft.when(
                  data: (d) => ListView(
                    children: [
                      if (d.aiGenerated)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text('AI draft (review carefully)'),
                            ],
                          ),
                        ),
                      SectionCard(
                        title: 'S — Subjective',
                        trailing: locked ? const Icon(Icons.lock) : null,
                        child: TextField(
                          enabled: !locked,
                          controller: _s,
                          minLines: 3,
                          maxLines: 8,
                          decoration: const InputDecoration(hintText: 'Chief complaint, symptoms, history...'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SectionCard(
                        title: 'O — Objective',
                        trailing: locked ? const Icon(Icons.lock) : null,
                        child: TextField(
                          enabled: !locked,
                          controller: _o,
                          minLines: 3,
                          maxLines: 8,
                          decoration: const InputDecoration(hintText: 'Vitals, exam findings, labs...'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SectionCard(
                        title: 'A — Assessment',
                        trailing: locked ? const Icon(Icons.lock) : null,
                        child: TextField(
                          enabled: !locked,
                          controller: _a,
                          minLines: 3,
                          maxLines: 8,
                          decoration: const InputDecoration(hintText: 'Impression, differential...'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SectionCard(
                        title: 'P — Plan',
                        trailing: locked ? const Icon(Icons.lock) : null,
                        child: TextField(
                          enabled: !locked,
                          controller: _p,
                          minLines: 3,
                          maxLines: 10,
                          decoration: const InputDecoration(hintText: 'Treatment, tests, follow-up...'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: locked
                                  ? null
                                  : () => _save(context, ctrl, d.copyWith(
                                        subjective: _s.text.trim(),
                                        objective: _o.text.trim(),
                                        assessment: _a.text.trim(),
                                        plan: _p.text.trim(),
                                      )),
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: () => context.go('/encounters/${widget.encounterId}/review'),
                              child: const Text('Review & sign'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'TODO(ngakaassist): Add medication prescribing, lab orders, and allergy capture within SOAP workflow.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, EncounterController ctrl, SoapDraftNote updated) async {
    final res = await ctrl.saveSoapDraft(updated);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isOk ? 'SOAP saved' : (res.failure?.message ?? 'Save failed'))),
    );
  }
}
