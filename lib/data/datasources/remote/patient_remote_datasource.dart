// NgakaAssist
// Remote datasource: Patients.
// Calls GET/POST /patients and GET /patients/{id}.

import 'package:dio/dio.dart';

import '../../api/api_paths.dart';
import '../../api/dio_client.dart';
import '../../../core/result.dart';
import '../../../domain/entities/patient.dart';

class PatientRemoteDataSource {
  PatientRemoteDataSource(this._client);

  final DioClient _client;

  Future<AppResult<List<Patient>>> searchPatients(String query) async {
    try {
      final res = await _client.dio.get<List<dynamic>>(
        ApiPaths.patients,
        queryParameters: {'query': query},
      );
      final list = (res.data ?? const <dynamic>[]) //
          .whereType<Map>()
          .map((e) => Patient.fromJson(e.cast<String, dynamic>()))
          .toList();
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
        ApiPaths.patients,
        data: patient.toJson(),
      );
      return AppResult.ok(Patient.fromJson(res.data ?? const {}));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<Patient>> getPatient(String id) async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiPaths.patientById(id));
      return AppResult.ok(Patient.fromJson(res.data ?? const {}));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }
}
