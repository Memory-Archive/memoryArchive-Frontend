/// Build-time configuration, set with --dart-define.
///
///   flutter run --dart-define=USE_MOCK=true
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
abstract final class Env {
  /// 10.0.2.2 is the Android emulator's alias for the host machine.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// When true, every remote data source is replaced by an in-memory fake.
  static const bool useMock = bool.fromEnvironment('USE_MOCK');

  /// Connect, send and receive timeout for every request.
  static const Duration requestTimeout = Duration(seconds: 20);
}
