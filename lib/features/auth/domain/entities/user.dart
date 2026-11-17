import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// The logged-in person. Pure Dart: no JSON, no Flutter.
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String username,
    required String email,
    String? displayName,
    String? bio,
    DateTime? passwordChangedAt,
  }) = _User;

  /// The name to show: the display name when set, otherwise the username.
  String get name {
    final value = displayName?.trim() ?? '';
    return value.isEmpty ? username : value;
  }
}
