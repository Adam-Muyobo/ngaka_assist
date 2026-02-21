// NgakaAssist
// Remote datasource: Encounters.
// Implements scaffolding for required encounter endpoints.

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../api/api_paths.dart';
import '../../api/dio_client.dart';
import '../../../core/result.dart';
import '../../../domain/entities/encounter.dart';
import '../../../domain/entities/icd10_suggestion.dart';
import '../../../domain/entities/soap_draft_note.dart';

class EncounterRemoteDataSource {
  EncounterRemoteDataSource(this._client);

  final DioClient _client;

  Future<AppResult<Encounter>> startEncounter({required String patientId, required String type}) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.encounters,
        data: {
          'patient_id': patientId,
          'type': type,
        },
      );
      return AppResult.ok(Encounter.fromJson(res.data ?? const {}));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
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
      // Web-friendly multipart: send bytes.
      // TODO(ngakaassist): Real recorder integration (mobile + web) and large file chunking.
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      await _client.dio.post<void>(
        ApiPaths.encounterAudio(encounterId),
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      return AppResult.ok(null);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<String>> getTranscript(String encounterId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiPaths.encounterTranscript(encounterId));
      final transcript = (res.data?['transcript'] ?? '').toString();
      return AppResult.ok(transcript);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<SoapDraftNote>> getSoapDraft(String encounterId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiPaths.encounterSoapDraft(encounterId));
      return AppResult.ok(SoapDraftNote.fromJson(res.data ?? const {}));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<SoapDraftNote>> updateSoapDraft(SoapDraftNote draft) async {
    try {
      final res = await _client.dio.put<Map<String, dynamic>>(
        ApiPaths.encounterSoapDraft(draft.encounterId),
        data: draft.toJson(),
      );
      return AppResult.ok(SoapDraftNote.fromJson(res.data ?? const {}));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<List<Icd10Suggestion>>> getIcd10Suggestions(String encounterId) async {
    try {
      final res = await _client.dio.get<List<dynamic>>(ApiPaths.encounterIcd10Suggestions(encounterId));
      final list = (res.data ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => Icd10Suggestion.fromJson(e.cast<String, dynamic>()))
          .toList();
      return AppResult.ok(list);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<void>> signEncounter(String encounterId) async {
    try {
      await _client.dio.post<void>(ApiPaths.encounterSign(encounterId));
      return AppResult.ok(null);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }
}
