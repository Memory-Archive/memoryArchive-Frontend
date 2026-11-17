import 'package:dio/dio.dart';
import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/validation/safe_json.dart';
import 'package:smart_memories/features/auth/data/models/auth_dtos.dart';
import 'package:smart_memories/features/auth/data/models/user_dto.dart';

/// The auth endpoints. Methods return DTOs and THROW on failure (a
/// DioException or a DtoParsingException); the repository wraps every call
/// in safeApiCall, which turns those into an ApiFailure.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseDto> login(LoginRequestDto request);

  Future<AuthResponseDto> register(RegisterRequestDto request);

  Future<UserDto> me();

  Future<void> logout(String? refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return parseDto(
      response.data,
      AuthResponseDto.fromJson,
      name: 'AuthResponseDto',
    );
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return parseDto(
      response.data,
      AuthResponseDto.fromJson,
      name: 'AuthResponseDto',
    );
  }

  @override
  Future<UserDto> me() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    return parseDto(response.data, UserDto.fromJson, name: 'UserDto');
  }

  @override
  Future<void> logout(String? refreshToken) async {
    await _dio.post<dynamic>(
      ApiEndpoints.logout,
      data: <String, dynamic>{'refreshToken': refreshToken},
    );
  }
}
