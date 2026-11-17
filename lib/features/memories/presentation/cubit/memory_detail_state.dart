import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';

part 'memory_detail_state.freezed.dart';

@freezed
sealed class MemoryDetailState with _$MemoryDetailState {
  const factory MemoryDetailState.initial() = MemoryDetailInitial;
  const factory MemoryDetailState.loading() = MemoryDetailLoading;
  const factory MemoryDetailState.success(Memory memory) = MemoryDetailSuccess;
  const factory MemoryDetailState.failure(ApiError error) = MemoryDetailFailure;

  /// The memory was deleted; the screen should close.
  const factory MemoryDetailState.deleted() = MemoryDetailDeleted;
}
