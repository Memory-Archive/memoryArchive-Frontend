import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/networking/api_error.dart';

/// THE ONLY FILE that knows the shape of the backend's error body.
///
/// Assumed format (to be confirmed with the backend developer):
///
///   {
///     "message": "Email is already registered.",
///     "code": "EMAIL_TAKEN",
///     "errors": [{ "field": "email", "message": "Already registered." }]
///   }
///
/// If the backend uses different keys, change them here and nowhere else.
abstract final class BackendErrorKeys {
  static const String message = 'message';
  static const String code = 'code';
  static const String errors = 'errors';
  static const String field = 'field';
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

  final message = body[BackendErrorKeys.message];
  final code = body[BackendErrorKeys.code];
  final rawErrors = body[BackendErrorKeys.errors];

  final fieldErrors = <FieldError>[];
  if (rawErrors is List) {
    for (final item in rawErrors) {
      if (item is! Map) continue;
      final field = item[BackendErrorKeys.field];
      final fieldMessage = item[BackendErrorKeys.fieldMessage];
      if (field is String && fieldMessage is String) {
        fieldErrors.add(FieldError(field: field, message: fieldMessage));
      }
    }
  }

  return ApiError(
    message: message is String && message.trim().isNotEmpty
        ? message.trim()
        : fallbackMessage,
    code: code is String && code.isNotEmpty ? code : fallbackCode,
    statusCode: statusCode,
    fieldErrors: fieldErrors,
  );
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
    final int code when code >= 500 => AppStrings.serverError,
    _ => AppStrings.unknownError,
  };
}
