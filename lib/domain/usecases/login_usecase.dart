// NgakaAssist
// Usecase: Login.
// Thin layer today, becomes a policy boundary as features grow.

import '../../core/result.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  const LoginUsecase(this._repo);

  final AuthRepository _repo;

  Future<AppResult<AuthSession>> call({required String username, required String password}) {
    return _repo.login(username: username, password: password);
  }
}
