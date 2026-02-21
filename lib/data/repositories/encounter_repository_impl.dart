// NgakaAssist
// Repository implementation: Encounters.
// Mock mode persists transcript + draft locally and returns static ICD-10 suggestions.

import 'dart:typed_data';

import '../../core/constants.dart';
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
  })  : _remote = remote,
        _mock = mock,
        _mockPatients = mockPatients;

  final EncounterRemoteDataSource _remote;
  final MockEncounterDataSource _mock;
  final MockPatientDataSource _mockPatients;

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
  Future<AppResult<void>> signEncounter(String encounterId) {
    return kUseMockData ? _mock.signEncounter(encounterId) : _remote.signEncounter(encounterId);
  }

  Encounter? mockGetEncounter(String id) => _mock.getEncounter(id);
  String? mockGetAudioRef(String id) => _mock.getAudioRef(id);
  DateTime? mockGetSignedAt(String id) => _mock.getSignedAt(id);
}
