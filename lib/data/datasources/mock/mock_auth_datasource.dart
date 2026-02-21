// NgakaAssist
// Mock datasource: Auth.
// Default credentials are not enforced (MVP demo behavior).

import '../../../core/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

class MockAuthDataSource {
  Future<AppResult<AuthSession>> login({required String username, required String password}) async {
    // Simulate latency.
    await Future<void>.delayed(const Duration(milliseconds: 450));

    // TODO(ngakaassist): Add mock roles (clinician, nurse, admin) + RBAC rules in UI.
    final user = User(id: 'u_001', name: username.isEmpty ? 'Clinician' : username, role: 'clinician');
    return AppResult.ok(AuthSession(token: 'mock-token', user: user));
  }
}
