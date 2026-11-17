import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// The user object exactly as the API sends it.
@freezed
abstract class UserDto with _$UserDto {
  const UserDto._();

  const factory UserDto({
    required String id,
    required String username,
    required String email,
    String? displayName,
    String? bio,
    DateTime? passwordChangedAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      displayName: displayName,
      bio: bio,
      passwordChangedAt: passwordChangedAt,
    );
  }
}
