// NgakaAssist
// Remote datasource: Encounters.
// Implements scaffolding for required encounter endpoints.

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../api/dio_client.dart';
import '../../api/api_constants.dart';
import '../../../core/result.dart';
import '../../../domain/entities/encounter.dart';
import '../../../domain/entities/icd10_suggestion.dart';
import '../../../domain/entities/soap_draft_note.dart';

class EncounterRemoteDataSource {
  EncounterRemoteDataSource(this._client);

  final DioClient _client;

  Map<String, dynamic> _unwrap(Map<String, dynamic>? body) {
    final b = body ?? const <String, dynamic>{};
    if (b['success'] != true) {
      throw AppFailure(message: (b['message'] ?? 'Request failed').toString());
    }
    final data = b['data'];
    if (data is Map) return data.cast<String, dynamic>();
    return <String, dynamic>{'value': data};
  }

  Future<AppResult<Encounter>> startEncounter({required String patientId, required String type}) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.encounters,
        data: {
          'patient_id': patientId,
          'encounter_type': type,
        },
      );

      final data = _unwrap(res.data);
      return AppResult.ok(Encounter.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<Encounter>> getEncounter(String encounterId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiConstants.encounterById(encounterId));
      final data = _unwrap(res.data);
      return AppResult.ok(Encounter.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } on AppFailure catch (f) {
      return AppResult.err(f);
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<void>> uploadAudio({
    required String encounterId,
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      // Backend does not accept audio blobs (by design).
      // Keep this method for future sync queue work.
      return AppResult.err(
        AppFailure(message: 'Audio upload is not supported. Use on-device STT and send transcript text.'),
      );
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<String>> getTranscript(String encounterId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiConstants.encounterTranscript(encounterId));
      final data = _unwrap(res.data);
      final transcript = (data['transcript_text'] ?? '').toString();
      return AppResult.ok(transcript);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }


  Future<AppResult<SoapDraftNote>> submitTranscriptForNlp({
    required String encounterId,
    required String transcript,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.encounterTranscriptNlp(encounterId),
        data: {'transcript_text': transcript},
      );

      final data = _unwrap(res.data);
      return AppResult.ok(SoapDraftNote.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } on AppFailure catch (f) {
      return AppResult.err(f);
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<SoapDraftNote>> getSoapDraft(String encounterId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiConstants.encounterSoap(encounterId));
      final data = _unwrap(res.data);
      return AppResult.ok(SoapDraftNote.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<SoapDraftNote>> updateSoapDraft(SoapDraftNote draft) async {
    try {
      final res = await _client.dio.put<Map<String, dynamic>>(
        ApiConstants.encounterSoap(draft.encounterId),
        data: {
          'subjective': draft.subjective,
          'objective': draft.objective,
          'assessment': draft.assessment,
          'plan': draft.plan,
          'transcript_text': draft.transcript,
        },
      );
      final data = _unwrap(res.data);
      return AppResult.ok(SoapDraftNote.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<List<Icd10Suggestion>>> getIcd10Suggestions(String encounterId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiConstants.encounterDiagnosisSuggestions(encounterId));
      final data = _unwrap(res.data);
      final items = (data['suggestions'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
      final list = items
          .map((e) => Icd10Suggestion.fromJson(e.cast<String, dynamic>()))
          .toList();
      return AppResult.ok(list);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<void>> addDiagnosis({
    required String encounterId,
    required Icd10Suggestion suggestion,
  }) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.encounterDiagnosis(encounterId),
        data: {
          'icd10_code': suggestion.code,
          'description': suggestion.description,
          'ai_suggested': true,
          'confidence_score': (suggestion.confidence * 100).round(),
        },
      );
      _unwrap(res.data);
      return AppResult.ok(null);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } on AppFailure catch (f) {
      return AppResult.err(f);
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<Encounter>> signEncounter(String encounterId) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(ApiConstants.encounterSign(encounterId));
      final data = _unwrap(res.data);
      return AppResult.ok(Encounter.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } on AppFailure catch (f) {
      return AppResult.err(f);
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }
}
