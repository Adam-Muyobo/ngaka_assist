// NgakaAssist
// Encounter controller.
// Owns transcript + SOAP draft + ICD-10 suggestions + signing state.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result.dart';
import '../../core/services/local_speech_to_text_service.dart';
import '../../data/repositories/encounter_repository_impl.dart';
import '../../domain/entities/icd10_suggestion.dart';
import '../../domain/entities/soap_draft_note.dart';
import '../../domain/repositories/encounter_repository.dart';
import 'providers.dart';

class EncounterState {
  const EncounterState({
    required this.encounterId,
    required this.transcript,
    required this.soapDraft,
    required this.icd10,
    required this.isSigned,
    required this.audioRef,
    required this.isProcessingSpeech,
    required this.lastNlpSyncAt,
    required this.recorderState,
  });

  final String encounterId;
  final AsyncValue<String> transcript;
  final AsyncValue<SoapDraftNote> soapDraft;
  final AsyncValue<List<Icd10Suggestion>> icd10;
  final bool isSigned;
  final String? audioRef;
  final bool isProcessingSpeech;
  final DateTime? lastNlpSyncAt;
  final RecorderState recorderState;

  EncounterState copyWith({
    AsyncValue<String>? transcript,
    AsyncValue<SoapDraftNote>? soapDraft,
    AsyncValue<List<Icd10Suggestion>>? icd10,
    bool? isSigned,
    String? audioRef,
    bool? isProcessingSpeech,
    DateTime? lastNlpSyncAt,
    RecorderState? recorderState,
  }) {
    return EncounterState(
      encounterId: encounterId,
      transcript: transcript ?? this.transcript,
      soapDraft: soapDraft ?? this.soapDraft,
      icd10: icd10 ?? this.icd10,
      isSigned: isSigned ?? this.isSigned,
      audioRef: audioRef ?? this.audioRef,
      isProcessingSpeech: isProcessingSpeech ?? this.isProcessingSpeech,
      lastNlpSyncAt: lastNlpSyncAt ?? this.lastNlpSyncAt,
      recorderState: recorderState ?? this.recorderState,
    );
  }
}

final encounterControllerProvider = NotifierProviderFamily<EncounterController, EncounterState, String>(
  EncounterController.new,
);

class EncounterController extends FamilyNotifier<EncounterState, String> {
  late final EncounterRepository _repo;

  EncounterRepositoryImpl? get _impl => switch (_repo) {
        EncounterRepositoryImpl v => v,
        _ => null,
      };

  @override
  EncounterState build(String encounterId) {
    _repo = ref.watch(encounterRepositoryProvider);
    state = EncounterState(
      encounterId: encounterId,
      transcript: const AsyncLoading(),
      soapDraft: const AsyncLoading(),
      icd10: const AsyncLoading(),
      isSigned: false,
      audioRef: null,
      isProcessingSpeech: false,
      lastNlpSyncAt: null,
      recorderState: _repo.recorderState,
    );

    _loadAll();
    return state;
  }

  Future<void> _loadAll() async {
    await Future.wait([loadTranscript(), loadSoapDraft(), loadIcd10()]);

    state = state.copyWith(
      audioRef: _impl?.mockGetAudioRef(state.encounterId),
      isSigned: (_impl?.mockGetSignedAt(state.encounterId) != null),
      recorderState: _repo.recorderState,
    );
  }

  Future<void> loadTranscript() async {
    final res = await _repo.getTranscript(state.encounterId);
    if (res.isOk) {
      state = state.copyWith(transcript: AsyncData(res.data ?? ''));
    } else {
      state = state.copyWith(transcript: AsyncError(res.failure!, StackTrace.current));
    }
  }

  Future<void> loadSoapDraft() async {
    final res = await _repo.getSoapDraft(state.encounterId);
    if (res.isOk) {
      final d = res.data as SoapDraftNote;
      state = state.copyWith(soapDraft: AsyncData(d), transcript: AsyncData(d.transcript));
    } else {
      state = state.copyWith(soapDraft: AsyncError(res.failure!, StackTrace.current));
    }
  }

  Future<void> loadIcd10() async {
    final res = await _repo.getIcd10Suggestions(state.encounterId);
    if (res.isOk) {
      state = state.copyWith(icd10: AsyncData(res.data ?? const <Icd10Suggestion>[]));
    } else {
      state = state.copyWith(icd10: AsyncError(res.failure!, StackTrace.current));
    }
  }

  void updateTranscriptLocal(String value) {
    state = state.copyWith(transcript: AsyncData(value));
  }

  Future<AppResult<void>> startRecording() async {
    final res = await _repo.startRecording();
    state = state.copyWith(recorderState: _repo.recorderState);
    return res;
  }

  Future<AppResult<void>> pauseRecording() async {
    final res = await _repo.pauseRecording();
    state = state.copyWith(
      recorderState: _repo.recorderState,
      transcript: AsyncData(_repo.transcriptDraft),
    );
    return res;
  }

  Future<AppResult<void>> resumeRecording() async {
    final res = await _repo.resumeRecording();
    state = state.copyWith(recorderState: _repo.recorderState);
    return res;
  }

  Future<AppResult<void>> stopRecording() async {
    final res = await _repo.stopRecording();
    state = state.copyWith(
      recorderState: _repo.recorderState,
      transcript: AsyncData(_repo.transcriptDraft),
    );
    return res;
  }

  Future<AppResult<void>> deleteRecording() async {
    final res = await _repo.deleteRecording();
    state = state.copyWith(
      recorderState: _repo.recorderState,
      transcript: const AsyncData(''),
    );
    return res;
  }

  Future<AppResult<SoapDraftNote>> saveTranscriptToDraft() async {
    final draft = state.soapDraft.valueOrNull;
    if (draft == null) {
      return AppResult.err(AppFailure(message: 'SOAP draft not loaded'));
    }
    final t = state.transcript.valueOrNull ?? '';
    final res = await _repo.updateSoapDraft(draft.copyWith(transcript: t));
    if (res.isOk) {
      state = state.copyWith(soapDraft: AsyncData(res.data as SoapDraftNote));
    }
    return res;
  }

  Future<AppResult<void>> transcribeAndSendRecording() async {
    if (state.isSigned) {
      return AppResult.err(AppFailure(message: 'Encounter is signed (locked)'));
    }

    state = state.copyWith(isProcessingSpeech: true);

    final transcriptionRes = await _repo.transcribeRecording();
    if (!transcriptionRes.isOk) {
      state = state.copyWith(isProcessingSpeech: false);
      return AppResult.err(transcriptionRes.failure!);
    }

    final transcript = transcriptionRes.data ?? '';
    state = state.copyWith(transcript: AsyncData(transcript));

    final nlpRes = await _repo.submitTranscriptForNlp(
      encounterId: state.encounterId,
      transcript: transcript,
    );

    if (!nlpRes.isOk) {
      state = state.copyWith(isProcessingSpeech: false);
      return nlpRes;
    }

    final saveRes = await saveTranscriptToDraft();
    state = state.copyWith(
      isProcessingSpeech: false,
      lastNlpSyncAt: DateTime.now(),
      recorderState: _repo.recorderState,
    );

    if (!saveRes.isOk) {
      return AppResult.err(saveRes.failure!);
    }

    return AppResult.ok(null);
  }

  Future<AppResult<SoapDraftNote>> saveSoapDraft(SoapDraftNote updated) async {
    if (state.isSigned) {
      return AppResult.err(AppFailure(message: 'Encounter is signed (locked)'));
    }
    state = state.copyWith(soapDraft: const AsyncLoading());
    final res = await _repo.updateSoapDraft(updated);
    if (res.isOk) {
      state = state.copyWith(soapDraft: AsyncData(res.data as SoapDraftNote));
    } else {
      state = state.copyWith(soapDraft: AsyncError(res.failure!, StackTrace.current));
    }
    return res;
  }

  void setIcdAccepted(String code, bool accepted) {
    final current = state.icd10.valueOrNull ?? const <Icd10Suggestion>[];
    final next = current.map((s) => s.code == code ? s.copyWith(accepted: accepted) : s).toList();
    state = state.copyWith(icd10: AsyncData(next));
    _impl?.updateIcd10Suggestions(state.encounterId, next);
  }

  Future<AppResult<void>> sign() async {
    if (state.isSigned) return AppResult.ok(null);
    final res = await _repo.signEncounter(state.encounterId);
    if (res.isOk) {
      state = state.copyWith(isSigned: true);
    }
    return res;
  }
}
