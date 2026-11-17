/// A minimal key-value store. Two implementations are registered in get_it:
///   * secure (flutter_secure_storage) for tokens,
///   * prefs  (shared_preferences)     for non-sensitive settings.
///
/// Code depends on this interface, never on a plugin directly, so storage can
/// be faked in tests.
abstract interface class LocalStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> clear();
}
