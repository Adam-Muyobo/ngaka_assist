// NgakaAssist
// Repository implementation: Encounters.
// Mock mode persists transcript + draft locally and returns static ICD-10 suggestions.

import 'dart:typed_data';

import '../../core/constants.dart';
import '../../core/services/local_speech_to_text_service.dart';
import '../../core/result.dart';
import '../../domain/entities/encounter.dart';
import '../../domain/entities/icd10_suggestion.dart';
import '../../domain/entities/soap_draft_note.dart';
import '../../domain/repositories/encounter_repository.dart';
import '../datasources/mock/mock_encounter_datasource.dart';
import '../datasources/mock/mock_patient_datasource.dart';
import '../datasources/remote/encounter_remote_datasource.dart';

class EncounterRepositoryImpl implements EncounterRepository {
  EncounterRepositoryImpl({
    required EncounterRemoteDataSource remote,
    required MockEncounterDataSource mock,
    required MockPatientDataSource mockPatients,
    required LocalSpeechToTextService speechToText,
  })  : _remote = remote,
        _mock = mock,
        _mockPatients = mockPatients,
        _speechToText = speechToText;

  final EncounterRemoteDataSource _remote;
  final MockEncounterDataSource _mock;
  final MockPatientDataSource _mockPatients;
  final LocalSpeechToTextService _speechToText;

  @override
  Future<AppResult<Encounter>> startEncounter({required String patientId, required String type}) async {
    if (!kUseMockData) return _remote.startEncounter(patientId: patientId, type: type);
    final res = await _mock.startEncounter(patientId: patientId, type: type);
    res.when(
      ok: (enc) {
        _mockPatients.addToHistory(enc);
      },
      err: (_) {},
    );
    return res;
  }

  @override
  Future<AppResult<Encounter>> getEncounter(String encounterId) {
    if (!kUseMockData) return _remote.getEncounter(encounterId);
    final enc = _mock.getEncounter(encounterId);
    if (enc == null) return Future.value(AppResult.err(AppFailure(message: 'Encounter not found')));
    return Future.value(AppResult.ok(enc));
  }

  @override
  Future<AppResult<void>> uploadAudio({
    required String encounterId,
    required Uint8List bytes,
    required String filename,
  }) {
    return kUseMockData
        ? _mock.uploadAudio(encounterId: encounterId, bytes: bytes, filename: filename)
        : _remote.uploadAudio(encounterId: encounterId, bytes: bytes, filename: filename);
  }

  @override
  Future<AppResult<String>> getTranscript(String encounterId) {
    return kUseMockData ? _mock.getTranscript(encounterId) : _remote.getTranscript(encounterId);
  }

  Future<AppResult<void>> saveTranscript(String encounterId, String transcript) {
    // Mock-only helper used by Consultation Mode screen.
    // TODO(ngakaassist): Replace with streaming transcript endpoint when available.
    return _mock.saveTranscript(encounterId, transcript);
  }


  @override
  RecorderState get recorderState => _speechToText.recorderState;

  @override
  String get transcriptDraft => _speechToText.transcriptDraft;

  @override
  Future<AppResult<void>> startRecording() {
    return _speechToText.startRecording();
  }

  @override
  Future<AppResult<void>> pauseRecording() {
    return _speechToText.pauseRecording();
  }

  @override
  Future<AppResult<void>> resumeRecording() {
    return _speechToText.resumeRecording();
  }

  @override
  Future<AppResult<void>> stopRecording() {
    return _speechToText.stopRecording();
  }

  @override
  Future<AppResult<void>> deleteRecording() {
    return _speechToText.deleteRecording();
  }

  @override
  Future<AppResult<String>> transcribeRecording() {
    return _speechToText.transcribeRecording();
  }

  @override
  Future<AppResult<SoapDraftNote>> submitTranscriptForNlp({required String encounterId, required String transcript}) async {
    if (!kUseMockData) {
      return _remote.submitTranscriptForNlp(encounterId: encounterId, transcript: transcript);
    }

    final res = await _mock.submitTranscriptForNlp(encounterId: encounterId, transcript: transcript);
    if (!res.isOk) return AppResult.err(res.failure!);
    return _mock.getSoapDraft(encounterId);
  }

  @override
  Future<AppResult<SoapDraftNote>> getSoapDraft(String encounterId) {
    return kUseMockData ? _mock.getSoapDraft(encounterId) : _remote.getSoapDraft(encounterId);
  }

  @override
  Future<AppResult<SoapDraftNote>> updateSoapDraft(SoapDraftNote draft) {
    return kUseMockData ? _mock.updateSoapDraft(draft) : _remote.updateSoapDraft(draft);
  }

  @override
  Future<AppResult<List<Icd10Suggestion>>> getIcd10Suggestions(String encounterId) {
    return kUseMockData ? _mock.getIcd10Suggestions(encounterId) : _remote.getIcd10Suggestions(encounterId);
  }

  Future<AppResult<List<Icd10Suggestion>>> updateIcd10Suggestions(
    String encounterId,
    List<Icd10Suggestion> suggestions,
  ) {
    // Mock-only helper.
    return _mock.updateIcd10Suggestions(encounterId, suggestions);
  }

  @override
  Future<AppResult<void>> addDiagnosis({required String encounterId, required Icd10Suggestion suggestion}) {
    if (!kUseMockData) return _remote.addDiagnosis(encounterId: encounterId, suggestion: suggestion);
    // Mock mode: acceptance is local-only.
    return Future.value(AppResult.ok(null));
  }

  @override
  Future<AppResult<Encounter>> signEncounter(String encounterId) async {
    if (!kUseMockData) return _remote.signEncounter(encounterId);
    final res = await _mock.signEncounter(encounterId);
    if (!res.isOk) return AppResult.err(res.failure!);
    final enc = _mock.getEncounter(encounterId);
    if (enc == null) return AppResult.err(AppFailure(message: 'Encounter not found'));
    return AppResult.ok(enc);
  }

  Encounter? mockGetEncounter(String id) => _mock.getEncounter(id);
  String? mockGetAudioRef(String id) => _mock.getAudioRef(id);
  DateTime? mockGetSignedAt(String id) => _mock.getSignedAt(id);
}
