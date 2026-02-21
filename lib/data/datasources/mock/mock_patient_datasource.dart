// NgakaAssist
// Mock datasource: Patients.
// Holds a simple in-memory list plus basic search.

import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../../domain/entities/encounter.dart';
import '../../../domain/entities/patient.dart';
import 'mock_seed_data.dart';

class MockPatientDataSource {
  MockPatientDataSource() {
    _patients.addAll(MockSeedData.patients());
  }

  final _uuid = const Uuid();
  final List<Patient> _patients = <Patient>[];
  final Map<String, List<Encounter>> _historyByPatient = <String, List<Encounter>>{};

  Future<AppResult<List<Patient>>> searchPatients(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return AppResult.ok(_patients.take(20).toList());
    final results = _patients.where((p) {
      return p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q) ||
          (p.nationalId ?? '').toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();
    return AppResult.ok(results);
  }

  Future<AppResult<Patient>> createPatient(Patient patient) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final created = Patient(
      id: patient.id.isEmpty ? 'p_${_uuid.v4()}' : patient.id,
      firstName: patient.firstName,
      lastName: patient.lastName,
      dateOfBirth: patient.dateOfBirth,
      gender: patient.gender,
      nationalId: patient.nationalId,
      phone: patient.phone,
    );
    _patients.insert(0, created);
    return AppResult.ok(created);
  }

  Future<AppResult<Patient>> getPatient(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final p = _patients.firstWhere((x) => x.id == id, orElse: () => const Patient(
          id: 'unknown',
          firstName: 'Unknown',
          lastName: 'Patient',
          dateOfBirth: null,
          gender: 'unknown',
        ));
    return AppResult.ok(p);
  }

  Future<AppResult<List<Encounter>>> getEncounterHistory(String patientId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return AppResult.ok(List<Encounter>.from(_historyByPatient[patientId] ?? const <Encounter>[]));
  }

  void addToHistory(Encounter encounter) {
    final list = _historyByPatient.putIfAbsent(encounter.patientId, () => <Encounter>[]);
    list.insert(0, encounter);
  }
}
