import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/networking/mock_http_error.dart';
import 'package:smart_memories/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:smart_memories/features/auth/data/models/auth_dtos.dart';
import 'package:smart_memories/features/auth/data/models/user_dto.dart';

/// In-memory auth for --dart-define=USE_MOCK=true.
///
/// Any email and password log in, except two that demonstrate errors:
///   * login with wrong@example.com     -> 401, a general error message
///   * register with taken@example.com  -> 409, an error under the email field
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  static const String wrongEmail = 'wrong@example.com';
  static const String takenEmail = 'taken@example.com';

  UserDto _user = UserDto(
    id: 'user-1',
    username: 'sara.h',
    email: 'sara@example.com',
    displayName: 'Sara Hassan',
    bio: 'Collecting small days so I do not lose them.',
    passwordChangedAt: DateTime(2026, 3, 9),
  );

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(mockLatency);
    if (request.email.toLowerCase() == wrongEmail) {
      throw mockHttpError(
        path: ApiEndpoints.login,
        statusCode: 401,
        body: <String, dynamic>{
          'message': 'Email or password is incorrect.',
          'code': 'INVALID_CREDENTIALS',
        },
      );
    }
    return _session();
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    await Future<void>.delayed(mockLatency);
    if (request.email.toLowerCase() == takenEmail) {
      throw mockHttpError(
        path: ApiEndpoints.register,
        statusCode: 409,
        body: <String, dynamic>{
          'message': 'Please fix the highlighted field.',
          'code': 'VALIDATION_ERROR',
          'errors': <Map<String, dynamic>>[
            <String, dynamic>{
              'field': 'email',
              'message': 'This email is already registered.',
            },
          ],
        },
      );
    }
    _user = UserDto(
      id: 'user-2',
      username: request.username,
      email: request.email,
      passwordChangedAt: DateTime.now(),
    );
    return _session();
  }

  @override
  Future<UserDto> me() async {
    await Future<void>.delayed(mockLatency);
    return _user;
  }

  @override
  Future<void> logout(String? refreshToken) async {
    await Future<void>.delayed(mockLatency);
  }

  AuthResponseDto _session() {
    return AuthResponseDto(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      user: _user,
    );
  }
}
