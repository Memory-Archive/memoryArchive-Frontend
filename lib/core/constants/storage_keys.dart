/// Keys used with LocalStorage. Token keys live in secure storage only.
abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // Non-sensitive settings (shared_preferences).
  static const String hasSeenOnboarding = 'has_seen_onboarding';
}
