// NgakaAssist
// Dio client with interceptors.
// Adds auth header, maps errors to AppFailure, and centralizes base URL/timeouts.

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/result.dart';
import '../../core/storage/token_store.dart';

class DioClient {
  DioClient({required TokenStore tokenStore, Dio? dio})
      : _tokenStore = tokenStore,
        dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: kBackendBaseUrl,
      connectTimeout: kApiConnectTimeout,
      receiveTimeout: kApiReceiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // Auth header interceptor.
    this.dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // TODO(ngakaassist): Add refresh-token flow + 401 retry.
  }

  final TokenStore _tokenStore;
  final Dio dio;
}

AppFailure mapDioError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final message = (error.response?.data is Map
            ? (error.response?.data['message']?.toString() ?? error.message)
            : error.message) ??
        'Network error';
    return AppFailure(message: message, code: status?.toString(), cause: error);
  }
  return AppFailure(message: 'Unexpected error', cause: error);
}
