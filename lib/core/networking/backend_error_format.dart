import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/networking/api_error.dart';

/// THE ONLY FILE that knows the shape of the backend's error body.
///
///
/// `details` is only a list for validation errors (400). Other errors, such as
/// 409 "Email is already registered", carry just a message. There is no
/// `code` key, so the app falls back to HTTP status codes.
///
/// If the backend format changes, change it here and nowhere else.
abstract final class BackendErrorKeys {
  static const String message = 'message';
  static const String code = 'code';
  static const String details = 'details';
  static const String fieldPath = 'path';
  static const String fieldMessage = 'message';
}

ApiError parseBackendError(Object? body, {int? statusCode}) {
  final fallbackMessage = defaultMessageForStatus(statusCode);
  final fallbackCode = 'HTTP_${statusCode ?? 0}';

  if (body is! Map) {
    return ApiError(
      message: fallbackMessage,
      code: fallbackCode,
      statusCode: statusCode,
    );
  }

  final rawMessage = body[BackendErrorKeys.message];
  final message = rawMessage is String && rawMessage.trim().isNotEmpty
      ? rawMessage.trim()
      : fallbackMessage;
  final code = body[BackendErrorKeys.code];
  final rawDetails = body[BackendErrorKeys.details];

  final fieldErrors = <FieldError>[];
  if (rawDetails is List) {
    for (final item in rawDetails) {
      if (item is! Map) continue;
      final path = item[BackendErrorKeys.fieldPath];
      final fieldMessage = item[BackendErrorKeys.fieldMessage];
      if (path is String && path.isNotEmpty && fieldMessage is String) {
        fieldErrors.add(FieldError(field: path, message: fieldMessage));
      }
    }
  }

  if (fieldErrors.isEmpty) {
    fieldErrors.addAll(_fieldErrorsFromConflict(statusCode, message));
  }

  return ApiError(
    message: message,
    code: code is String && code.isNotEmpty ? code : fallbackCode,
    statusCode: statusCode,
    fieldErrors: fieldErrors,
  );
}

/// The backend reports a taken email or username as a 409 with only a message
/// ("Email is already registered", "Username is already taken"). Attach it to
/// the matching form field so the sign-up screen shows it under that field.
List<FieldError> _fieldErrorsFromConflict(int? statusCode, String message) {
  if (statusCode != 409) return const <FieldError>[];
  final lower = message.toLowerCase();
  if (lower.startsWith('email')) {
    return <FieldError>[FieldError(field: 'email', message: message)];
  }
  if (lower.startsWith('username')) {
    return <FieldError>[FieldError(field: 'username', message: message)];
  }
  return const <FieldError>[];
}

/// Used when the server sends no usable message.
String defaultMessageForStatus(int? statusCode) {
  return switch (statusCode) {
    400 || 422 => AppStrings.invalidRequest,
    401 => AppStrings.unauthenticated,
    403 => AppStrings.forbidden,
    404 => AppStrings.notFound,
    409 => AppStrings.conflict,
    429 => AppStrings.tooManyRequests,
    501 => AppStrings.notImplemented,
    final int code when code >= 500 => AppStrings.serverError,
    _ => AppStrings.unknownError,
  };
}