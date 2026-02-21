// NgakaAssist
// Repository contract: Authentication.
// Remote implementation calls /auth/login; mock implementation returns dummy user.

import '../../core/result.dart';
import '../entities/user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}

abstract class AuthRepository {
  Future<AppResult<AuthSession>> login({required String username, required String password});

  Future<AppResult<void>> logout();

  Future<AppResult<AuthSession?>> currentSession();
}
