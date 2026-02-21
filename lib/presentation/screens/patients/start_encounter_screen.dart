// NgakaAssist
// Screen: Start encounter.
// Creates an encounter record and routes into Consultation Mode.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/providers.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class StartEncounterScreen extends ConsumerStatefulWidget {
  const StartEncounterScreen({super.key, required this.patientId});

  final String patientId;

  @override
  ConsumerState<StartEncounterScreen> createState() => _StartEncounterScreenState();
}

class _StartEncounterScreenState extends ConsumerState<StartEncounterScreen> {
  String _type = 'OPD';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Start encounter')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SectionCard(
                  title: 'Encounter type',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'OPD', child: Text('OPD consultation')),
                          DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
                          DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? 'OPD'),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _start(context),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_busy ? 'Starting...' : 'Start'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'TODO(ngakaassist): Add triage context, clinician selection, and facility/ward metadata.',
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
    );
  }

  Future<void> _start(BuildContext context) async {
    setState(() => _busy = true);
    final repo = ref.read(encounterRepositoryProvider);
    final res = await repo.startEncounter(patientId: widget.patientId, type: _type);
    if (!mounted) return;
    setState(() => _busy = false);

    if (res.isOk) {
      final encounter = res.data!;
      context.go('/encounters/${encounter.id}/consult');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.failure?.message ?? 'Could not start encounter')));
    }
  }
}
