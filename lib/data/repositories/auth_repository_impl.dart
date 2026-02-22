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
        await _tokenStore.saveTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
        return AppResult.ok(session);
      },
      err: (f) async => AppResult.err(f),
    );
  }

  @override
  Future<AppResult<void>> logout() async {
    try {
      if (!kUseMockData) {
        final refresh = await _tokenStore.readRefreshToken();
        if (refresh != null && refresh.isNotEmpty) {
          await _remote.logout(refreshToken: refresh);
        }
      }
      await _tokenStore.clear();
      return AppResult.ok(null);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to logout', cause: e));
    }
  }

  @override
  Future<AppResult<AuthSession?>> currentSession() async {
    try {
      final access = await _tokenStore.readAccessToken();
      final refresh = await _tokenStore.readRefreshToken();
      if (access == null || access.isEmpty) return AppResult.ok(null);
      if (refresh == null || refresh.isEmpty) return AppResult.ok(null);

      // In mock mode, reconstruct a simple user.
      if (kUseMockData) {
        return AppResult.ok(
          AuthSession(
            accessToken: access,
            refreshToken: refresh,
            user: const User(id: 'u_001', name: 'Clinician', role: 'clinician'),
          ),
        );
      }

      final meRes = await _remote.me();
      if (!meRes.isOk || meRes.data == null) return AppResult.ok(null);
      return AppResult.ok(AuthSession(accessToken: access, refreshToken: refresh, user: meRes.data as User));
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to read session', cause: e));
    }
  }
}
