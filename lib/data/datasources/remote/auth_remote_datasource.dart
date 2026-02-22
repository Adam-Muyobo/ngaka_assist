// NgakaAssist
// Remote datasource: Auth.
// Calls POST /auth/login.

import 'package:dio/dio.dart';

import '../../api/dio_client.dart';
import '../../api/api_constants.dart';
import '../../../core/result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Map<String, dynamic> _unwrap(Map<String, dynamic>? body) {
    final b = body ?? const <String, dynamic>{};
    if (b['success'] != true) {
      throw AppFailure(message: (b['message'] ?? 'Request failed').toString());
    }
    final data = b['data'];
    if (data is Map) return data.cast<String, dynamic>();
    return <String, dynamic>{'value': data};
  }

  Future<AppResult<AuthSession>> login({required String username, required String password}) async {
    try {
      final res = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = _unwrap(res.data);
      final tokens = (data['tokens'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final access = (tokens['access'] ?? '').toString();
      final refresh = (tokens['refresh'] ?? '').toString();
      final user = User.fromJson((data['user'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{});

      if (access.isEmpty || refresh.isEmpty) {
        return AppResult.err(AppFailure(message: 'Invalid login response (missing tokens)'));
      }
      return AppResult.ok(AuthSession(accessToken: access, refreshToken: refresh, user: user));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } on AppFailure catch (f) {
      return AppResult.err(f);
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<User>> me() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>(ApiConstants.authMe);
      final data = _unwrap(res.data);
      // Backend returns a Practitioner-like resource.
      return AppResult.ok(User.fromJson(data));
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } on AppFailure catch (f) {
      return AppResult.err(f);
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }

  Future<AppResult<void>> logout({required String refreshToken}) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.authLogout,
        options: Options(extra: {'authTokenOverride': refreshToken, 'skipAuthRefresh': true}),
      );
      return AppResult.ok(null);
    } on DioException catch (e) {
      return AppResult.err(mapDioError(e));
    } catch (e) {
      return AppResult.err(mapDioError(e));
    }
  }
}
