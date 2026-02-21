// NgakaAssist
// Patient search controller.
// Manages query + results with a single source of truth for the screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/patient.dart';
import '../state/providers.dart';

class PatientSearchState {
  const PatientSearchState({required this.query, required this.results, this.errorMessage});

  final String query;
  final AsyncValue<List<Patient>> results;
  final String? errorMessage;

  PatientSearchState copyWith({String? query, AsyncValue<List<Patient>>? results, String? errorMessage}) {
    return PatientSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }
}

final patientSearchControllerProvider = NotifierProvider<PatientSearchController, PatientSearchState>(
  PatientSearchController.new,
);

class PatientSearchController extends Notifier<PatientSearchState> {
  @override
  PatientSearchState build() {
    // Default: show seeded patients.
    state = const PatientSearchState(query: '', results: AsyncLoading());
    _search('');
    return state;
  }

  Future<void> search(String query) async {
    state = state.copyWith(query: query, results: const AsyncLoading(), errorMessage: null);
    await _search(query);
  }

  Future<void> _search(String query) async {
    final usecase = ref.read(searchPatientsUsecaseProvider);
    final res = await usecase(query);
    if (res.isOk) {
      state = state.copyWith(results: AsyncData(res.data ?? const <Patient>[]));
    } else {
      state = state.copyWith(results: AsyncData(const <Patient>[]), errorMessage: res.failure?.message);
    }
  }
}
