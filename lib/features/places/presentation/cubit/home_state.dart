import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.success({
    required String firstName,
    required List<Memory> recent,

    /// Null when nothing happened on this date in earlier years.
    Memory? onThisDay,
  }) = HomeSuccess;
  const factory HomeState.failure(ApiError error) = HomeFailure;
}
