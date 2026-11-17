import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/constants/env.dart';
import 'package:smart_memories/core/networking/auth_interceptor.dart';
import 'package:smart_memories/core/storage/token_storage.dart';

/// Builds the single Dio instance every feature shares (registered in get_it).
abstract final class DioFactory {
  static Dio create({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
  }) {
    final dio = Dio(_baseOptions());

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        bareDio: Dio(_baseOptions()),
        onSessionExpired: onSessionExpired,
      ),
    );

    // Debug builds only. Headers are never logged (they carry the access
    // token) and /auth/ calls are skipped entirely (their bodies carry
    // passwords and tokens).
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          compact: true,
          filter: (options, args) => !ApiEndpoints.isSensitive(options.path),
        ),
      );
    }

    return dio;
  }

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: Env.requestTimeout,
      sendTimeout: Env.requestTimeout,
      receiveTimeout: Env.requestTimeout,
      contentType: Headers.jsonContentType,
      headers: <String, dynamic>{'Accept': Headers.jsonContentType},
    );
  }
}
