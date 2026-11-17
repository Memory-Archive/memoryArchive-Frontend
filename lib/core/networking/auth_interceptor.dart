import 'package:dio/dio.dart';
import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/storage/token_storage.dart';
import 'package:smart_memories/core/validation/safe_json.dart';

/// Attaches the access token to every non-public request and, on a 401,
/// refreshes the token ONCE and replays the request. If the refresh fails
/// (or the replay is rejected again) the session is ended and the app
/// returns to the login screen.
///
/// QueuedInterceptor handles errors one at a time, so several requests that
/// fail together share a single refresh instead of each starting their own.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio bareDio,
    required Future<void> Function() onSessionExpired,
  }) : _tokens = tokenStorage,
       _bareDio = bareDio,
       _onSessionExpired = onSessionExpired;

  static const String _authHeader = 'Authorization';
  static const String _retriedKey = 'auth_retried';

  final TokenStorage _tokens;

  /// A Dio with the same base options but NO interceptors, used for the
  /// refresh call and the replay so they cannot loop back through here.
  final Dio _bareDio;
  final Future<void> Function() _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!ApiEndpoints.isPublic(options.path)) {
      final token = await _tokens.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[_authHeader] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        !ApiEndpoints.isPublic(request.path) &&
        request.extra[_retriedKey] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final String token;
    try {
      token = await _freshAccessToken(sentHeader: request.headers[_authHeader]);
    } catch (_) {
      await _onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      request.headers[_authHeader] = 'Bearer $token';
      request.extra[_retriedKey] = true;
      handler.resolve(await _bareDio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) await _onSessionExpired();
      handler.next(retryError);
    }
  }

  /// Returns a usable access token, refreshing only if nobody else already
  /// has: when the stored token differs from the one this request was sent
  /// with, an earlier queued request has refreshed it and we reuse that.
  Future<String> _freshAccessToken({Object? sentHeader}) async {
    final current = await _tokens.readAccessToken();
    if (current != null &&
        current.isNotEmpty &&
        sentHeader != 'Bearer $current') {
      return current;
    }

    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token stored.');
    }

    final response = await _bareDio.post<dynamic>(
      ApiEndpoints.refresh,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
    final body = unwrapData(response.data);
    final Object? access = body is Map ? body['accessToken'] : null;
    final Object? rotated = body is Map ? body['refreshToken'] : null;
    if (access is! String || access.isEmpty) {
      throw StateError('Refresh response did not contain an accessToken.');
    }

    await _tokens.save(
      accessToken: access,
      refreshToken: rotated is String && rotated.isNotEmpty
          ? rotated
          : refreshToken,
    );
    return access;
  }
}