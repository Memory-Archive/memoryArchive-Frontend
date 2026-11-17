import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/features/memories/domain/repositories/memories_repository.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_detail_state.dart';

class MemoryDetailCubit extends Cubit<MemoryDetailState> {
  MemoryDetailCubit(this._repository)
    : super(const MemoryDetailState.initial());

  final MemoriesRepository _repository;

  Future<void> load(String id) async {
    emit(const MemoryDetailState.loading());
    final result = await _repository.getById(id);
    if (isClosed) return;
    emit(
      result.when(
        success: MemoryDetailState.success,
        failure: MemoryDetailState.failure,
      ),
    );
  }

  Future<void> delete(String id) async {
    emit(const MemoryDetailState.loading());
    final result = await _repository.delete(id);
    if (isClosed) return;
    emit(
      result.when(
        success: (_) => const MemoryDetailState.deleted(),
        failure: MemoryDetailState.failure,
      ),
    );
  }
}
