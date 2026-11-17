/// Shared copy: the app name and the default, user-friendly error messages.
abstract final class AppStrings {
  static const String appName = 'Memories Archive';

  static const String unknownError = 'Something went wrong. Please try again.';
  static const String timeout =
      'The server took too long to respond. Please try again.';
  static const String noConnection =
      'No internet connection. Check your network and try again.';
  static const String insecureConnection =
      'A secure connection could not be established.';
  static const String cancelled = 'The request was cancelled.';
  static const String unexpectedResponse =
      'We received an unexpected response. Please try again later.';

  static const String invalidRequest =
      'Some of the information is not valid. Please check it and try again.';
  static const String unauthenticated =
      'Your session has ended. Please log in again.';
  static const String forbidden = 'You do not have permission to do that.';
  static const String notFound = 'We could not find what you were looking for.';
  static const String conflict =
      'That conflicts with something that already exists.';
  static const String tooManyRequests =
      'Too many attempts. Please wait a moment and try again.';
  static const String serverError =
      'The server ran into a problem. Please try again later.';

  static const String notAvailableYet = 'This is not available yet.';
}
