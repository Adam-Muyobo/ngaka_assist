// NgakaAssist
// Riverpod providers wiring data + domain layers.
// Keeps construction centralized and testable.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/local_speech_to_text_service.dart';
import '../../core/storage/token_store.dart';
import '../../data/api/dio_client.dart';
import '../../data/datasources/mock/mock_auth_datasource.dart';
import '../../data/datasources/mock/mock_encounter_datasource.dart';
import '../../data/datasources/mock/mock_patient_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/encounter_remote_datasource.dart';
import '../../data/datasources/remote/patient_remote_datasource.dart';
import '../../data/local/hive_sync_queue.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/encounter_repository_impl.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/encounter_repository.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/search_patients_usecase.dart';

// Core providers.
final localSpeechToTextProvider = Provider<LocalSpeechToTextService>((ref) => PlaceholderLocalSpeechToTextService());

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(tokenStore: ref.watch(tokenStoreProvider));
});

// Datasources.
final authRemoteDsProvider = Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSource(ref.watch(dioClientProvider)));
final patientRemoteDsProvider = Provider<PatientRemoteDataSource>((ref) => PatientRemoteDataSource(ref.watch(dioClientProvider)));
final encounterRemoteDsProvider = Provider<EncounterRemoteDataSource>((ref) => EncounterRemoteDataSource(ref.watch(dioClientProvider)));

final authMockDsProvider = Provider<MockAuthDataSource>((ref) => MockAuthDataSource());

// Keep mock patient datasource as a singleton for a consistent demo.
final patientMockDsProvider = Provider<MockPatientDataSource>((ref) => MockPatientDataSource());
final encounterMockDsProvider = Provider<MockEncounterDataSource>((ref) => MockEncounterDataSource());

final hiveSyncQueueProvider = Provider<HiveSyncQueue>((ref) => HiveSyncQueue());

// Repositories.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    tokenStore: ref.watch(tokenStoreProvider),
    remote: ref.watch(authRemoteDsProvider),
    mock: ref.watch(authMockDsProvider),
  );
});

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(
    remote: ref.watch(patientRemoteDsProvider),
    mock: ref.watch(patientMockDsProvider),
  );
});

final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  return EncounterRepositoryImpl(
    remote: ref.watch(encounterRemoteDsProvider),
    mock: ref.watch(encounterMockDsProvider),
    mockPatients: ref.watch(patientMockDsProvider),
    speechToText: ref.watch(localSpeechToTextProvider),
  );
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final impl = SyncRepositoryImpl(ref.watch(hiveSyncQueueProvider));
  // Best effort seeding.
  impl.ensureSeeded();
  return impl;
});

// Usecases.
final loginUsecaseProvider = Provider<LoginUsecase>((ref) => LoginUsecase(ref.watch(authRepositoryProvider)));
final searchPatientsUsecaseProvider = Provider<SearchPatientsUsecase>(
  (ref) => SearchPatientsUsecase(ref.watch(patientRepositoryProvider)),
);
