/// A validation problem tied to one request field.
class FieldError {
  const FieldError({required this.field, required this.message});

  final String field;
  final String message;
}

/// Stable codes for errors that are produced on the device, not by the server.
abstract final class ApiErrorCodes {
  static const String timeout = 'TIMEOUT';
  static const String noConnection = 'NO_CONNECTION';
  static const String cancelled = 'CANCELLED';
  static const String insecureConnection = 'INSECURE_CONNECTION';
  static const String parsing = 'PARSING_ERROR';
  static const String unauthenticated = 'UNAUTHENTICATED';
  static const String unknown = 'UNKNOWN';
}

/// The one error type the rest of the app sees. [message] is always short and
/// safe to show to the user. [debugMessage] is for logs only.
class ApiError {
  const ApiError({
    required this.message,
    this.code = ApiErrorCodes.unknown,
    this.statusCode,
    this.fieldErrors = const <FieldError>[],
    this.debugMessage,
  });

  final String message;
  final String code;
  final int? statusCode;
  final List<FieldError> fieldErrors;
  final String? debugMessage;

  bool get isUnauthorized => statusCode == 401;

  /// The server's message for one field, or null if that field was fine.
  String? messageFor(String field) {
    for (final error in fieldErrors) {
      if (error.field == field) return error.message;
    }
    return null;
  }

  @override
  String toString() =>
      'ApiError(code: $code, statusCode: $statusCode, message: $message)';
}
