// NgakaAssist
// Remote datasource: Patients.
// Calls GET/POST /patients and GET /patients/{id}.

import 'package:dio/dio.dart';

import '../../api/dio_client.dart';
import '../../api/api_constants.dart';
import '../../../core/result.dart';
import '../../../domain/entities/encounter.dart';
import '../../../domain/entities/patient.dart';

class PatientRemoteDataSource {
  PatientRemoteDataSource(this._client);

  final DioClient _client;

  Future<AppResult<List<Patient>>> searchPatients(String query) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.patients,
        queryParameters: {'search': query},
      );

      final body = res.data ?? const <String, dynamic>{};
      if (body['success'] != true) {
        return AppResult.err(
          AppFailure(message: (body['message'] ?? 'Request failed').toString()),
        );
      }
      final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final items = (data['items'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
      final list = items.map((e) => Patient.fromJson(e.cast<String, dynamic>())).toList();
      return AppResult.ok(list);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<Patient>> createPatient(Patient patient) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.patients,
        data: patient.toJson(),
      );

      final body = res.data ?? const <String, dynamic>{};
      if (body['success'] != true) {
        return AppResult.err(AppFailure(message: (body['message'] ?? 'Request failed').toString()));
      }
      final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      return AppResult.ok(Patient.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<Patient>> getPatient(String id) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiConstants.patientById(id));
      final body = res.data ?? const <String, dynamic>{};
      if (body['success'] != true) {
        return AppResult.err(AppFailure(message: (body['message'] ?? 'Request failed').toString()));
      }
      final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      return AppResult.ok(Patient.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<List<Encounter>>> getEncounterHistory(String patientId) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.encounters,
        queryParameters: {
          'patient_id': patientId,
          // Keep it simple for now; backend uses cursor pagination.
          'page[size]': 50,
        },
      );

      final body = res.data ?? const <String, dynamic>{};
      if (body['success'] != true) {
        return AppResult.err(AppFailure(message: (body['message'] ?? 'Request failed').toString()));
      }
      final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final items = (data['items'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
      final list = items.map((e) => Encounter.fromJson(e.cast<String, dynamic>())).toList();
      return AppResult.ok(list);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }
}
