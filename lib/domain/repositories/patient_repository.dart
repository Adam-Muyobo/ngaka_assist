// NgakaAssist
// Repository contract: Patients.

import '../../core/result.dart';
import '../entities/patient.dart';
import '../entities/encounter.dart';

abstract class PatientRepository {
  Future<AppResult<List<Patient>>> searchPatients(String query);

  Future<AppResult<Patient>> createPatient(Patient patient);

  Future<AppResult<Patient>> getPatient(String id);

  // MVP convenience: encounter history per patient.
  // TODO(ngakaassist): Move encounter history to EncounterRepository once backend provides endpoint.
  Future<AppResult<List<Encounter>>> getEncounterHistory(String patientId);
}
