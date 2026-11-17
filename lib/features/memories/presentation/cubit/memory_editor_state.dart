import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/core/networking/api_error.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';

part 'memory_editor_state.freezed.dart';

@freezed
sealed class MemoryEditorState with _$MemoryEditorState {
  const factory MemoryEditorState.initial() = MemoryEditorInitial;

  /// Saving.
  const factory MemoryEditorState.loading() = MemoryEditorLoading;

  /// Saved; carries the created memory so the screen can open it.
  const factory MemoryEditorState.success(Memory memory) = MemoryEditorSuccess;
  const factory MemoryEditorState.failure(ApiError error) = MemoryEditorFailure;
}
