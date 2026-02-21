// NgakaAssist
// Usecase: Search patients.

import '../../core/result.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class SearchPatientsUsecase {
  const SearchPatientsUsecase(this._repo);

  final PatientRepository _repo;

  Future<AppResult<List<Patient>>> call(String query) {
    return _repo.searchPatients(query);
  }
}
