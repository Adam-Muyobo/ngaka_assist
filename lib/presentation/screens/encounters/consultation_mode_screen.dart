// NgakaAssist
// Screen: Consultation mode.
// Voice-first UI prototype: local transcription + transcript-to-backend NLP handoff.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../state/encounter_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class ConsultationModeScreen extends ConsumerStatefulWidget {
  const ConsultationModeScreen({super.key, required this.encounterId});

  final String encounterId;

  @override
  ConsumerState<ConsultationModeScreen> createState() => _ConsultationModeScreenState();
}

class _ConsultationModeScreenState extends ConsumerState<ConsultationModeScreen> {
  bool _recording = false;
  final _transcriptCtrl = TextEditingController();
  final _transcriptFocus = FocusNode();

  @override
  void dispose() {
    _transcriptCtrl.dispose();
    _transcriptFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(encounterControllerProvider(widget.encounterId));
    final ctrl = ref.read(encounterControllerProvider(widget.encounterId).notifier);
    final transcript = vm.transcript.valueOrNull ?? '';
    if (!_transcriptFocus.hasFocus && _transcriptCtrl.text != transcript) {
      _transcriptCtrl.text = transcript;
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Consultation'),
          actions: [
            FilledButton.tonal(
              onPressed: () => context.go('/encounters/${widget.encounterId}/soap'),
              child: const Text('SOAP'),
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
                    SectionCard(
                      title: 'Recording',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _recording ? 'Recording (placeholder)...' : 'Ready to record (placeholder).',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: vm.isSigned || vm.isProcessingSpeech
                                      ? null
                                      : () {
                                          setState(() => _recording = !_recording);
                                        },
                                  icon: Icon(_recording ? Icons.stop : Icons.mic),
                                  label: Text(_recording ? 'Stop' : 'Record'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: vm.isSigned || vm.isProcessingSpeech
                                      ? null
                                      : () async {
                                          final res = await ctrl.transcribeAndSendRecording();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                res.isOk
                                                    ? 'Local transcription sent to backend NLP'
                                                    : (res.failure?.message ?? 'Transcription failed'),
                                              ),
                                            ),
                                          );
                                        },
                                  icon: vm.isProcessingSpeech
                                      ? const Icon(Icons.hourglass_top)
                                      : const Icon(Icons.translate_outlined),
                                  label: Text(vm.isProcessingSpeech ? 'Processing...' : 'Transcribe + Send Text'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (vm.lastNlpSyncAt != null)
                            Text(
                              'Last NLP sync: ${DateFormat('y-MM-dd HH:mm').format(vm.lastNlpSyncAt!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            'Audio is transcribed locally in-app first, then only the transcript text is sent for NLP.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      title: 'Transcript',
                      trailing: vm.isSigned ? const Icon(Icons.lock) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            enabled: !vm.isSigned,
                            minLines: 8,
                            maxLines: 16,
                            focusNode: _transcriptFocus,
                            controller: _transcriptCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Transcript will appear here...',
                            ),
                            onChanged: ctrl.updateTranscriptLocal,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: vm.isSigned
                                      ? null
                                      : () async {
                                          final res = await ctrl.saveTranscriptToDraft();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                res.isOk ? 'Transcript saved' : (res.failure?.message ?? 'Save failed'),
                                              ),
                                            ),
                                          );
                                        },
                                  child: const Text('Save transcript'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonal(
                                  onPressed: () => context.go('/encounters/${widget.encounterId}/soap'),
                                  child: const Text('Continue to SOAP'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
