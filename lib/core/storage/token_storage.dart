import 'package:smart_memories/core/constants/storage_keys.dart';
import 'package:smart_memories/core/storage/local_storage.dart';

/// Reads and writes the access and refresh tokens. Always constructed with
/// the SECURE LocalStorage (see core/di/injection.dart).
class TokenStorage {
  const TokenStorage(this._storage);

  final LocalStorage _storage;

  Future<String?> readAccessToken() => _storage.read(StorageKeys.accessToken);

  Future<String?> readRefreshToken() => _storage.read(StorageKeys.refreshToken);

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(StorageKeys.accessToken, accessToken);
    await _storage.write(StorageKeys.refreshToken, refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(StorageKeys.accessToken);
    await _storage.delete(StorageKeys.refreshToken);
  }

  Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
