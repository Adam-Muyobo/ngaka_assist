// NgakaAssist
// Dio client with interceptors.
// Adds auth header, maps errors to AppFailure, and centralizes base URL/timeouts.

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/result.dart';
import '../../core/storage/token_store.dart';
import 'api_constants.dart';

class DioClient {
  DioClient({required TokenStore tokenStore, Dio? httpClient})
      : _tokenStore = tokenStore,
        dio = httpClient ?? Dio(),
        _refreshDio = Dio() {
    this.dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: kApiConnectTimeout,
      receiveTimeout: kApiReceiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    );

    _refreshDio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: kApiConnectTimeout,
      receiveTimeout: kApiReceiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    );

    // Auth header interceptor.
    this.dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final override = options.extra['authTokenOverride']?.toString();
          if (override != null && override.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $override';
          } else {
            final token = await _tokenStore.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final res = error.response;
          final status = res?.statusCode;
          final req = error.requestOptions;

          final alreadyRetried = req.extra['retried'] == true;
          final skipRefresh = req.extra['skipAuthRefresh'] == true;

          if (status == 401 && !alreadyRetried && !skipRefresh) {
            final refreshed = await _refreshOnce();
            if (refreshed) {
              try {
                final access = await _tokenStore.readAccessToken();
                final retryOptions = req..extra['retried'] = true;
                if (access != null && access.isNotEmpty) {
                  retryOptions.headers['Authorization'] = 'Bearer $access';
                }
                final clone = await this.dio.fetch<dynamic>(retryOptions);
                return handler.resolve(clone);
              } catch (_) {
                // Fall through to original error.
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final TokenStore _tokenStore;
  final Dio dio;

  final Dio _refreshDio;
  Future<bool>? _refreshing;

  Future<bool> _refreshOnce() async {
    _refreshing ??= _refreshTokens();
    try {
      return await _refreshing!;
    } finally {
      _refreshing = null;
    }
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final res = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.authRefresh,
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json',
          },
          extra: const {'skipAuthRefresh': true},
        ),
      );
      final body = res.data ?? const <String, dynamic>{};
      if (body['success'] != true) return false;

      final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final tokens = (data['tokens'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};

      final access = (tokens['access'] ?? '').toString();
      final refresh = (tokens['refresh'] ?? '').toString();
      if (access.isEmpty || refresh.isEmpty) return false;

      await _tokenStore.saveTokens(accessToken: access, refreshToken: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }
}

AppFailure mapDioError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final message = (data is Map
            ? (data['message']?.toString() ?? error.message)
            : error.message) ??
        'Network error';
    return AppFailure(message: message, code: status?.toString(), cause: error);
  }
  return AppFailure(message: 'Unexpected error', cause: error);
}
