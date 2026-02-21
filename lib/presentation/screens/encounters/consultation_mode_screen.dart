// NgakaAssist
// Screen: Consultation mode.
// Voice-first UI with microphone recording controls and local STT to NLP handoff.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/local_speech_to_text_service.dart';
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
  final _transcriptCtrl = TextEditingController();
  final _transcriptFocus = FocusNode();

  @override
  void dispose() {
    _transcriptCtrl.dispose();
    _transcriptFocus.dispose();
    super.dispose();
  }

  Future<void> _runAction(Future<dynamic> Function() action, String okMessage) async {
    final res = await action();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.isOk ? okMessage : (res.failure?.message ?? 'Action failed'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(encounterControllerProvider(widget.encounterId));
    final ctrl = ref.read(encounterControllerProvider(widget.encounterId).notifier);
    final transcript = vm.transcript.valueOrNull ?? '';

    if (!_transcriptFocus.hasFocus && _transcriptCtrl.text != transcript) {
      _transcriptCtrl.text = transcript;
    }

    final isRecording = vm.recorderState == RecorderState.recording;
    final isPaused = vm.recorderState == RecorderState.paused;
    final canStart = vm.recorderState == RecorderState.idle || vm.recorderState == RecorderState.stopped;
    final canStop = isRecording || isPaused;
    final canDelete = vm.recorderState != RecorderState.idle;

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
                            switch (vm.recorderState) {
                              RecorderState.idle => 'Ready to record from microphone.',
                              RecorderState.recording => 'Recording from microphone...',
                              RecorderState.paused => 'Recording paused.',
                              RecorderState.stopped => 'Recording stopped. Ready to transcribe.',
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: vm.isSigned || vm.isProcessingSpeech || !canStart
                                    ? null
                                    : () => _runAction(ctrl.startRecording, 'Recording started'),
                                icon: const Icon(Icons.mic),
                                label: const Text('Record'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: vm.isSigned || vm.isProcessingSpeech || !isRecording
                                    ? null
                                    : () => _runAction(ctrl.pauseRecording, 'Recording paused'),
                                icon: const Icon(Icons.pause),
                                label: const Text('Pause'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: vm.isSigned || vm.isProcessingSpeech || !isPaused
                                    ? null
                                    : () => _runAction(ctrl.resumeRecording, 'Recording resumed'),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Resume'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: vm.isSigned || vm.isProcessingSpeech || !canStop
                                    ? null
                                    : () => _runAction(ctrl.stopRecording, 'Recording stopped'),
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: vm.isSigned || vm.isProcessingSpeech || !canDelete
                                    ? null
                                    : () => _runAction(ctrl.deleteRecording, 'Recording deleted'),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: vm.isSigned || vm.isProcessingSpeech || !canStop
                                ? null
                                : () => _runAction(
                                      ctrl.transcribeAndSendRecording,
                                      'Local transcript sent to backend NLP',
                                    ),
                            icon: vm.isProcessingSpeech
                                ? const Icon(Icons.hourglass_top)
                                : const Icon(Icons.translate_outlined),
                            label: Text(vm.isProcessingSpeech ? 'Processing...' : 'Transcribe + Send Text'),
                          ),
                          const SizedBox(height: 10),
                          if (vm.lastNlpSyncAt != null)
                            Text(
                              'Last NLP sync: ${DateFormat('y-MM-dd HH:mm').format(vm.lastNlpSyncAt!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            'Record, pause/resume, stop or delete. Only transcript text is sent to backend NLP.',
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
                            decoration: const InputDecoration(hintText: 'Transcript will appear here...'),
                            onChanged: ctrl.updateTranscriptLocal,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: vm.isSigned
                                      ? null
                                      : () => _runAction(ctrl.saveTranscriptToDraft, 'Transcript saved'),
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
