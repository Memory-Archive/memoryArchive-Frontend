import 'dart:async';

import 'package:dio/dio.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/core/networking/backend_error_format.dart';
import 'package:smart_memories/core/validation/safe_json.dart';

/// Runs [call] and converts anything it throws into an [ApiFailure] with a
/// short, user-friendly message. Every repository method goes through this,
/// so no exception from the network layer reaches a Cubit or a screen.
Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return ApiSuccess<T>(await call());
  } on DioException catch (e) {
    return ApiFailure<T>(mapDioException(e));
  } on TimeoutException {
    return ApiFailure<T>(
      const ApiError(message: AppStrings.timeout, code: ApiErrorCodes.timeout),
    );
  } on DtoParsingException catch (e) {
    return ApiFailure<T>(_parsingError(e.message));
  } catch (e) {
    return ApiFailure<T>(
      ApiError(
        message: AppStrings.unknownError,
        code: ApiErrorCodes.unknown,
        debugMessage: e.toString(),
      ),
    );
  }
}

ApiError mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const ApiError(
        message: AppStrings.timeout,
        code: ApiErrorCodes.timeout,
      );
    case DioExceptionType.connectionError:
      return const ApiError(
        message: AppStrings.noConnection,
        code: ApiErrorCodes.noConnection,
      );
    case DioExceptionType.badCertificate:
      return const ApiError(
        message: AppStrings.insecureConnection,
        code: ApiErrorCodes.insecureConnection,
      );
    case DioExceptionType.cancel:
      return const ApiError(
        message: AppStrings.cancelled,
        code: ApiErrorCodes.cancelled,
      );
    case DioExceptionType.badResponse:
      return parseBackendError(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    case DioExceptionType.unknown:
      final cause = e.error;
      if (cause is DtoParsingException) return _parsingError(cause.message);
      return ApiError(
        message: AppStrings.unknownError,
        code: ApiErrorCodes.unknown,
        debugMessage: e.message,
      );
  }
}

ApiError _parsingError(String debugMessage) {
  return ApiError(
    message: AppStrings.unexpectedResponse,
    code: ApiErrorCodes.parsing,
    debugMessage: debugMessage,
  );
}
