import 'package:dio/dio.dart';
import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/validation/safe_json.dart';
import 'package:smart_memories/features/auth/data/models/auth_dtos.dart';
import 'package:smart_memories/features/auth/data/models/user_dto.dart';

/// The auth endpoints. Methods return DTOs and THROW on failure (a
/// DioException or a DtoParsingException); the repository wraps every call
/// in safeApiCall, which turns those into an ApiFailure.
abstract interface class AuthRemoteDataSource {
  /// POST /auth/login -> the tokens.
  Future<TokensDto> login(LoginRequestDto request);

  /// POST /auth/signup -> the created user. No tokens are issued.
  Future<UserDto> register(RegisterRequestDto request);

  /// GET /users/me -> the signed-in user.
  Future<UserDto> me();

  Future<void> logout(String? refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<TokensDto> login(LoginRequestDto request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return parseDto(
      unwrapData(response.data),
      TokensDto.fromJson,
      name: 'TokensDto',
    );
  }

  @override
  Future<UserDto> register(RegisterRequestDto request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.signup,
      data: request.toJson(),
    );
    return _parseUser(response.data);
  }

  @override
  Future<UserDto> me() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    return _parseUser(response.data);
  }

  @override
  Future<void> logout(String? refreshToken) async {
    await _dio.post<dynamic>(
      ApiEndpoints.logout,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
  }

  /// The user arrives as `data: { user: {...} }` from signup. GET /users/me
  /// is not implemented on the backend yet, so this also accepts the user
  /// directly in `data`.
  UserDto _parseUser(Object? body) {
    final data = unwrapData(body);
    final user = data is Map && data['user'] is Map ? data['user'] : data;
    return parseDto(user, UserDto.fromJson, name: 'UserDto');
  }
}