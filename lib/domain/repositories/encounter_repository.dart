// NgakaAssist
// Repository contract: Encounters.

import 'dart:typed_data';

import '../../core/result.dart';
import '../../core/services/local_speech_to_text_service.dart';
import '../entities/encounter.dart';
import '../entities/icd10_suggestion.dart';
import '../entities/soap_draft_note.dart';

abstract class EncounterRepository {
  Future<AppResult<Encounter>> startEncounter({required String patientId, required String type});

  Future<AppResult<Encounter>> getEncounter(String encounterId);

  // TODO(ngakaassist): Real audio capture + upload (multipart) + permissions.
  Future<AppResult<void>> uploadAudio({required String encounterId, required Uint8List bytes, required String filename});

  Future<AppResult<String>> getTranscript(String encounterId);

  RecorderState get recorderState;
  String get transcriptDraft;

  Future<AppResult<void>> startRecording();
  Future<AppResult<void>> pauseRecording();
  Future<AppResult<void>> resumeRecording();
  Future<AppResult<void>> stopRecording();
  Future<AppResult<void>> deleteRecording();
  Future<AppResult<String>> transcribeRecording();

  Future<AppResult<SoapDraftNote>> submitTranscriptForNlp({required String encounterId, required String transcript});

  Future<AppResult<SoapDraftNote>> getSoapDraft(String encounterId);

  Future<AppResult<SoapDraftNote>> updateSoapDraft(SoapDraftNote draft);

  Future<AppResult<List<Icd10Suggestion>>> getIcd10Suggestions(String encounterId);


  // Persist an accepted suggestion as a diagnosis.
  Future<AppResult<void>> addDiagnosis({required String encounterId, required Icd10Suggestion suggestion});

  Future<AppResult<Encounter>> signEncounter(String encounterId);
}
