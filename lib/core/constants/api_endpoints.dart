/// Every REST path the app calls. Paths are relative to Env.apiBaseUrl.
/// These are assumptions until the backend developer confirms them.
abstract final class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  static const String me = '/me';
  static const String sessions = '/me/sessions';
  static String session(String id) => '/me/sessions/$id';

  static const String memories = '/memories';
  static const String memoriesOnThisDay = '/memories/on-this-day';
  static String memory(String id) => '/memories/$id';

  /// Requests that are sent without an access token and never trigger a
  /// token refresh.
  static bool isPublic(String path) =>
      path.endsWith(login) || path.endsWith(register) || path.endsWith(refresh);

  /// Requests whose bodies carry passwords or tokens. They are never logged.
  static bool isSensitive(String path) => path.contains('/auth/');
}
