import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/helpers/session_helper.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/core/networking/safe_api_call.dart';
import 'package:smart_memories/core/storage/token_storage.dart';
import 'package:smart_memories/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:smart_memories/features/auth/data/models/auth_dtos.dart';
import 'package:smart_memories/features/auth/data/models/user_dto.dart';
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

  /// POST /auth/login returns tokens only, so the user is fetched afterwards.
  @override
  Future<ApiResult<User>> login({
    required String email,
    required String password,
  }) async {
    final tokens = await safeApiCall(
      () => _remote.login(LoginRequestDto(email: email, password: password)),
    );
    return _finishSignIn(tokens);
  }

  /// POST /auth/signup creates the account but issues no tokens, so signing
  /// up is signup followed by login. The user from signup is reused.
  @override
  Future<ApiResult<User>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final created = await safeApiCall(
      () => _remote.register(
        RegisterRequestDto(username: username, email: email, password: password),
      ),
    );
    switch (created) {
      case ApiFailure<UserDto>(:final error):
        return ApiFailure<User>(error);
      case ApiSuccess<UserDto>(:final data):
        final tokens = await safeApiCall(
          () => _remote.login(LoginRequestDto(email: email, password: password)),
        );
        return _finishSignIn(tokens, knownUser: data.toEntity());
    }
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
        break;
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

  /// Saves the tokens, resolves the user (fetching it unless [knownUser] is
  /// given) and marks the session as signed in. If the user cannot be
  /// fetched, the tokens are removed again so nothing is left half signed in.
  Future<ApiResult<User>> _finishSignIn(
    ApiResult<TokensDto> tokensResult, {
    User? knownUser,
  }) async {
    switch (tokensResult) {
      case ApiFailure<TokensDto>(:final error):
        return ApiFailure<User>(error);
      case ApiSuccess<TokensDto>(:final data):
        await _tokens.save(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
        if (knownUser != null) {
          _session.markAuthenticated();
          return ApiSuccess<User>(knownUser);
        }
        final me = await getCurrentUser();
        if (me is ApiFailure<User>) {
          await _tokens.clear();
          return me;
        }
        _session.markAuthenticated();
        return me;
    }
  }
}
