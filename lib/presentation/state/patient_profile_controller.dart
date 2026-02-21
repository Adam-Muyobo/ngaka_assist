// NgakaAssist
// Patient profile controller.
// Loads patient details and encounter history.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/encounter.dart';
import '../../domain/entities/patient.dart';
import 'providers.dart';

class PatientProfileState {
  const PatientProfileState({required this.patient, required this.history});

  final AsyncValue<Patient> patient;
  final AsyncValue<List<Encounter>> history;
}

final patientProfileControllerProvider = AsyncNotifierProviderFamily<PatientProfileController, PatientProfileState, String>(
  PatientProfileController.new,
);

class PatientProfileController extends FamilyAsyncNotifier<PatientProfileState, String> {
  @override
  Future<PatientProfileState> build(String patientId) async {
    final repo = ref.watch(patientRepositoryProvider);
    final p = await repo.getPatient(patientId);
    final h = await repo.getEncounterHistory(patientId);

    return PatientProfileState(
      patient: p.isOk ? AsyncData(p.data!) : AsyncError(p.failure!, StackTrace.current),
      history: h.isOk ? AsyncData(h.data ?? const <Encounter>[]) : AsyncData(const <Encounter>[]),
    );
  }
}
