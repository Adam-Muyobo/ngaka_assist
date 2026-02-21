// NgakaAssist
// Remote datasource: Auth.
// Calls POST /auth/login.

import 'package:dio/dio.dart';

import '../../api/api_paths.dart';
import '../../api/dio_client.dart';
import '../../../core/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<AppResult<AuthSession>> login({required String username, required String password}) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiPaths.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = res.data ?? const <String, dynamic>{};
      final token = (data['token'] ?? '').toString();
      final user = User.fromJson((data['user'] as Map?)?.cast<String, dynamic>() ?? const {});

      if (token.isEmpty) {
        return AppResult.err(AppFailure(message: 'Invalid login response'));
      }
      return AppResult.ok(AuthSession(token: token, user: user));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }
}
