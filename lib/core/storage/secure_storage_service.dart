import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _jwtTokenKey = 'jwt_token';

  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _jwtTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _jwtTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
