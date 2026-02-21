// NgakaAssist
// Repository implementation: Auth.
// Chooses mock vs remote based on core/constants.dart.

import '../../core/constants.dart';
import '../../core/result.dart';
import '../../core/storage/token_store.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock/mock_auth_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required TokenStore tokenStore,
    required AuthRemoteDataSource remote,
    required MockAuthDataSource mock,
  })  : _tokenStore = tokenStore,
        _remote = remote,
        _mock = mock;

  final TokenStore _tokenStore;
  final AuthRemoteDataSource _remote;
  final MockAuthDataSource _mock;

  @override
  Future<AppResult<AuthSession>> login({required String username, required String password}) async {
    final res = kUseMockData
        ? await _mock.login(username: username, password: password)
        : await _remote.login(username: username, password: password);

    return res.when(
      ok: (session) async {
        await _tokenStore.saveToken(session.token);
        return AppResult.ok(session);
      },
      err: (f) async => AppResult.err(f),
    );
  }

  @override
  Future<AppResult<void>> logout() async {
    try {
      await _tokenStore.clear();
      return AppResult.ok(null);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to logout', cause: e));
    }
  }

  @override
  Future<AppResult<AuthSession?>> currentSession() async {
    // MVP: only token is persisted; user is not.
    // TODO(ngakaassist): Persist user profile and validate token.
    try {
      final token = await _tokenStore.readToken();
      if (token == null || token.isEmpty) return AppResult.ok(null);
      // In mock mode, reconstruct a simple user.
      if (kUseMockData) {
        return AppResult.ok(
          AuthSession(token: token, user: const User(id: 'u_001', name: 'Clinician', role: 'clinician')),
        );
      }
      return AppResult.ok(null);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to read session', cause: e));
    }
  }
}
