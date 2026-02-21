// NgakaAssist
// Repository implementation: Patients.
// Mock mode provides in-memory patients and encounter history.

import '../../core/constants.dart';
import '../../core/result.dart';
import '../../domain/entities/encounter.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/mock/mock_patient_datasource.dart';
import '../datasources/remote/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl({required PatientRemoteDataSource remote, required MockPatientDataSource mock})
      : _remote = remote,
        _mock = mock;

  final PatientRemoteDataSource _remote;
  final MockPatientDataSource _mock;

  @override
  Future<AppResult<List<Patient>>> searchPatients(String query) {
    return kUseMockData ? _mock.searchPatients(query) : _remote.searchPatients(query);
  }

  @override
  Future<AppResult<Patient>> createPatient(Patient patient) {
    return kUseMockData ? _mock.createPatient(patient) : _remote.createPatient(patient);
  }

  @override
  Future<AppResult<Patient>> getPatient(String id) {
    return kUseMockData ? _mock.getPatient(id) : _remote.getPatient(id);
  }

  @override
  Future<AppResult<List<Encounter>>> getEncounterHistory(String patientId) {
    return kUseMockData
        ? _mock.getEncounterHistory(patientId)
        : Future.value(AppResult.err(AppFailure(message: 'Encounter history endpoint not implemented yet')));
  }
}
