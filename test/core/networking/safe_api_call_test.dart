import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/core/networking/safe_api_call.dart';
import 'package:smart_memories/core/validation/safe_json.dart';

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  Object? body,
  Object? cause,
}) {
  final request = RequestOptions(path: '/test');
  return DioException(
    requestOptions: request,
    type: type,
    error: cause,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: request,
            statusCode: statusCode,
            data: body,
          ),
  );
}

/// Runs safeApiCall with a call that throws [thrown] and returns the error.
Future<ApiError> _failWith(Object thrown) async {
  final result = await safeApiCall<int>(() async => throw thrown);
  expect(result, isA<ApiFailure<int>>());
  return (result as ApiFailure<int>).error;
}

void main() {
  group('safeApiCall', () {
    test('returns ApiSuccess with the data when the call succeeds', () async {
      final result = await safeApiCall(() async => 42);

      expect(result, isA<ApiSuccess<int>>());
      expect((result as ApiSuccess<int>).data, 42);
    });

    test('works for calls that return nothing', () async {
      final result = await safeApiCall<void>(() async {});

      expect(result, isA<ApiSuccess<void>>());
    });

    for (final type in <DioExceptionType>[
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('maps $type to a timeout error', () async {
        final error = await _failWith(_dioError(type));

        expect(error.code, ApiErrorCodes.timeout);
        expect(error.message, AppStrings.timeout);
      });
    }

    test('maps a dart:async TimeoutException to a timeout error', () async {
      final error = await _failWith(TimeoutException('too slow'));

      expect(error.code, ApiErrorCodes.timeout);
      expect(error.message, AppStrings.timeout);
    });

    test('maps a connection error to "no internet"', () async {
      final error = await _failWith(
        _dioError(DioExceptionType.connectionError),
      );

      expect(error.code, ApiErrorCodes.noConnection);
      expect(error.message, AppStrings.noConnection);
    });

    test('maps a cancelled request', () async {
      final error = await _failWith(_dioError(DioExceptionType.cancel));

      expect(error.code, ApiErrorCodes.cancelled);
    });

    test('reads message, code and field errors from the backend format', () async {
      final error = await _failWith(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 422,
          body: <String, dynamic>{
            'message': 'Please fix the highlighted fields.',
            'code': 'VALIDATION_ERROR',
            'errors': <Map<String, dynamic>>[
              <String, dynamic>{'field': 'email', 'message': 'Already registered.'},
              <String, dynamic>{'field': 'password', 'message': 'Too short.'},
            ],
          },
        ),
      );

      expect(error.statusCode, 422);
      expect(error.code, 'VALIDATION_ERROR');
      expect(error.message, 'Please fix the highlighted fields.');
      expect(error.fieldErrors, hasLength(2));
      expect(error.messageFor('email'), 'Already registered.');
      expect(error.messageFor('password'), 'Too short.');
      expect(error.messageFor('username'), isNull);
    });

    test('ignores malformed entries in the errors array', () async {
      final error = await _failWith(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 400,
          body: <String, dynamic>{
            'message': 'Bad request.',
            'errors': <Object?>[
              'not an object',
              <String, dynamic>{'field': 'email'},
              <String, dynamic>{'field': 'title', 'message': 'Required.'},
            ],
          },
        ),
      );

      expect(error.fieldErrors, hasLength(1));
      expect(error.messageFor('title'), 'Required.');
      expect(error.code, 'HTTP_400');
    });

    test('falls back to a friendly message when the body is not JSON', () async {
      final error = await _failWith(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 500,
          body: '<html>Internal Server Error</html>',
        ),
      );

      expect(error.statusCode, 500);
      expect(error.message, AppStrings.serverError);
      expect(error.code, 'HTTP_500');
    });

    test('falls back by status code when the message is missing', () async {
      final notFound = await _failWith(
        _dioError(
          DioExceptionType.badResponse,
          statusCode: 404,
          body: <String, dynamic>{},
        ),
      );
      final unauthorized = await _failWith(
        _dioError(DioExceptionType.badResponse, statusCode: 401),
      );

      expect(notFound.message, AppStrings.notFound);
      expect(unauthorized.message, AppStrings.unauthenticated);
      expect(unauthorized.isUnauthorized, isTrue);
    });

    test('maps a DTO parsing failure to "unexpected response"', () async {
      final error = await _failWith(
        const DtoParsingException('UserDto: field "email" is missing.'),
      );

      expect(error.code, ApiErrorCodes.parsing);
      expect(error.message, AppStrings.unexpectedResponse);
      expect(error.debugMessage, contains('email'));
    });

    test('maps a parsing failure wrapped in a DioException', () async {
      final error = await _failWith(
        _dioError(
          DioExceptionType.unknown,
          cause: const DtoParsingException('UserDto: expected an object.'),
        ),
      );

      expect(error.code, ApiErrorCodes.parsing);
    });

    test('never lets an unexpected exception escape', () async {
      final error = await _failWith(StateError('boom'));

      expect(error.code, ApiErrorCodes.unknown);
      expect(error.message, AppStrings.unknownError);
    });

    test('the user-facing message never contains technical details', () async {
      final error = await _failWith(StateError('NullPointer at line 42'));

      expect(error.message, isNot(contains('line 42')));
      expect(error.debugMessage, contains('line 42'));
    });
  });

  group('ApiResult', () {
    test('when() calls the matching branch', () {
      const ApiResult<int> success = ApiSuccess<int>(2);
      const ApiResult<int> failure = ApiFailure<int>(ApiError(message: 'no'));

      expect(success.when(success: (d) => 'ok $d', failure: (e) => 'bad'), 'ok 2');
      expect(failure.when(success: (d) => 'ok', failure: (e) => e.message), 'no');
    });

    test('map() converts data and keeps failures', () {
      const ApiResult<int> success = ApiSuccess<int>(2);
      const ApiResult<int> failure = ApiFailure<int>(ApiError(message: 'no'));

      expect((success.map((d) => d * 10) as ApiSuccess<int>).data, 20);
      expect(failure.map((d) => d * 10), isA<ApiFailure<int>>());
    });
  });
}
