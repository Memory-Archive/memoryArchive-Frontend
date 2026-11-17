import 'package:flutter/foundation.dart';

/// Build-time configuration, set with --dart-define.
///
///   flutter run --dart-define=USE_MOCK=true
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000
///
/// The backend mounts its routes at the root (/auth/login, /memories, ...),
/// so the base URL has NO "/api" suffix.
abstract final class Env {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Used when API_BASE_URL is not set: Chrome reaches the host machine at
  /// localhost, while 10.0.2.2 is the Android emulator's alias for it.
  static String get apiBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  /// When true, every remote data source is replaced by an in-memory fake.
  static const bool useMock = bool.fromEnvironment('USE_MOCK');

  /// Connect, send and receive timeout for every request.
  static const Duration requestTimeout = Duration(seconds: 20);
}