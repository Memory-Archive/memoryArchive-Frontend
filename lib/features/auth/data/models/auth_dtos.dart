import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

/// Body of POST /auth/login.
@freezed
abstract class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String email,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

/// Body of POST /auth/signup.
@freezed
abstract class RegisterRequestDto with _$RegisterRequestDto {
  const factory RegisterRequestDto({
    required String username,
    required String email,
    required String password,
  }) = _RegisterRequestDto;

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);
}

/// `data` of POST /auth/login: the two tokens only. The user comes from
/// GET /users/me, and signup returns the user but no tokens, so signing up
/// is signup followed by login (see AuthRepositoryImpl).
@freezed
abstract class TokensDto with _$TokensDto {
  const factory TokensDto({
    required String accessToken,
    required String refreshToken,
  }) = _TokensDto;

  factory TokensDto.fromJson(Map<String, dynamic> json) =>
      _$TokensDtoFromJson(json);
}