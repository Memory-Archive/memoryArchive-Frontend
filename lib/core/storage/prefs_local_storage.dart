import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_memories/core/storage/local_storage.dart';

/// Plain, unencrypted storage for non-sensitive settings.
/// Never put tokens or personal data here.
class PrefsLocalStorage implements LocalStorage {
  const PrefsLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
