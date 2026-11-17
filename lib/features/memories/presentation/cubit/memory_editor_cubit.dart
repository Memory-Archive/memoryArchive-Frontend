import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';
import 'package:smart_memories/features/memories/domain/repositories/memories_repository.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_editor_state.dart';

class MemoryEditorCubit extends Cubit<MemoryEditorState> {
  MemoryEditorCubit(this._repository)
    : super(const MemoryEditorState.initial());

  final MemoriesRepository _repository;

  Future<void> save(MemoryDraft draft) async {
    emit(const MemoryEditorState.loading());
    final result = await _repository.create(draft);
    if (isClosed) return;
    emit(
      result.when(
        success: MemoryEditorState.success,
        failure: MemoryEditorState.failure,
      ),
    );
  }
}
