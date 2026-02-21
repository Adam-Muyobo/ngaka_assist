// NgakaAssist
// Token storage wrapper.
// Uses flutter_secure_storage so auth can work on mobile + web.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _kTokenKey = 'ngaka_token';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _kTokenKey);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kTokenKey);
  }
}
