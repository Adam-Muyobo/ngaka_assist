// NgakaAssist
// Token storage wrapper.
// Uses flutter_secure_storage so auth can work on mobile + web.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _kAccessTokenKey = 'ngaka_access_token';
  static const _kRefreshTokenKey = 'ngaka_refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _kAccessTokenKey, value: accessToken);
    await _storage.write(key: _kRefreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _kAccessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _kRefreshTokenKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
  }
}
