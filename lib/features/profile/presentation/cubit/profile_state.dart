import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';
import 'package:smart_memories/features/profile/domain/entities/device_session.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;
  const factory ProfileState.success({
    required User user,
    required List<DeviceSession> sessions,
  }) = ProfileSuccess;
  const factory ProfileState.failure(ApiError error) = ProfileFailure;
}
