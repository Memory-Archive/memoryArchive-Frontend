import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// The four states every feature's Cubit uses. Screens read them with a
/// switch:
///
///   switch (state) {
///     AuthInitial() => ...,
///     AuthLoading() => ...,
///     AuthSuccess(:final user) => ...,
///     AuthFailure(:final error) => ...,
///   }
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.success(User user) = AuthSuccess;
  const factory AuthState.failure(ApiError error) = AuthFailure;
}
