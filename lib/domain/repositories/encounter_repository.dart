// NgakaAssist
// Repository contract: Encounters.

import 'dart:typed_data';

import '../../core/result.dart';
import '../entities/encounter.dart';
import '../entities/icd10_suggestion.dart';
import '../entities/soap_draft_note.dart';

abstract class EncounterRepository {
  Future<AppResult<Encounter>> startEncounter({required String patientId, required String type});

  // TODO(ngakaassist): Real audio capture + upload (multipart) + permissions.
  Future<AppResult<void>> uploadAudio({required String encounterId, required Uint8List bytes, required String filename});

  Future<AppResult<String>> getTranscript(String encounterId);

  Future<AppResult<SoapDraftNote>> getSoapDraft(String encounterId);

  Future<AppResult<SoapDraftNote>> updateSoapDraft(SoapDraftNote draft);

  Future<AppResult<List<Icd10Suggestion>>> getIcd10Suggestions(String encounterId);

  Future<AppResult<void>> signEncounter(String encounterId);
}
