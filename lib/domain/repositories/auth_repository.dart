// NgakaAssist
// Repository contract: Authentication.
// Remote implementation calls /auth/login; mock implementation returns dummy user.

import '../../core/result.dart';
import '../entities/user.dart';

class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final User user;
}

abstract class AuthRepository {
  Future<AppResult<AuthSession>> login({required String username, required String password});

  Future<AppResult<void>> logout();

  Future<AppResult<AuthSession?>> currentSession();
}
