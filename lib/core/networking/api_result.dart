import 'package:smart_memories/core/networking/api_error.dart';

/// The result of any repository call: either data or a user-friendly error.
/// Repositories never throw; they return one of these.
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(ApiError error) = ApiFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError error) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:final data) => success(data),
      ApiFailure<T>(:final error) => failure(error),
    };
  }

  /// Converts the data (for example DTO to entity) and keeps a failure as is.
  ApiResult<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      ApiSuccess<T>(:final data) => ApiSuccess<R>(transform(data)),
      ApiFailure<T>(:final error) => ApiFailure<R>(error),
    };
  }
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);

  final ApiError error;
}
