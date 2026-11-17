import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/helpers/session_helper.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/core/networking/safe_api_call.dart';
import 'package:smart_memories/core/storage/token_storage.dart';
import 'package:smart_memories/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:smart_memories/features/auth/data/models/auth_dtos.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';
import 'package:smart_memories/features/auth/domain/repositories/auth_repository.dart';

/// The pattern every repository follows:
///   1. call the remote data source inside safeApiCall (so nothing throws),
///   2. apply side effects on success (here: save tokens, mark the session),
///   3. map the DTO to a domain entity.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage tokenStorage,
    required SessionHelper session,
  }) : _remote = remote,
       _tokens = tokenStorage,
       _session = session;

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;
  final SessionHelper _session;

  @override
  Future<ApiResult<User>> login({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _remote.login(LoginRequestDto(email: email, password: password)),
    );
  }

  @override
  Future<ApiResult<User>> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _remote.register(
        RegisterRequestDto(username: username, email: email, password: password),
      ),
    );
  }

  @override
  Future<ApiResult<User>> restoreSession() async {
    if (!await _session.hasStoredSession()) {
      await _session.end();
      return const ApiFailure<User>(
        ApiError(
          message: AppStrings.unauthenticated,
          code: ApiErrorCodes.unauthenticated,
          statusCode: 401,
        ),
      );
    }

    final result = await getCurrentUser();
    switch (result) {
      case ApiSuccess<User>():
        _session.markAuthenticated();
      case ApiFailure<User>(:final error):
        // Only a rejected token ends the session. A network problem leaves
        // the tokens in place so the splash screen can offer "Try again".
        if (error.isUnauthorized) await _session.end();
    }
    return result;
  }

  @override
  Future<ApiResult<User>> getCurrentUser() async {
    final result = await safeApiCall(_remote.me);
    return result.map((dto) => dto.toEntity());
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    // Best effort: the device session ends even if the server call fails.
    await safeApiCall(() => _remote.logout(refreshToken));
    await _session.end();
  }

  Future<ApiResult<User>> _authenticate(
    Future<AuthResponseDto> Function() call,
  ) async {
    final result = await safeApiCall(call);
    switch (result) {
      case ApiSuccess<AuthResponseDto>(:final data):
        await _tokens.save(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
        _session.markAuthenticated();
        return ApiSuccess<User>(data.user.toEntity());
      case ApiFailure<AuthResponseDto>(:final error):
        return ApiFailure<User>(error);
    }
  }
}
