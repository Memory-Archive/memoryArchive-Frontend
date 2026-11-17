import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/core/networking/safe_api_call.dart';
import 'package:smart_memories/features/memories/data/data_sources/memories_remote_data_source.dart';
import 'package:smart_memories/features/memories/data/models/memory_dto.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';
import 'package:smart_memories/features/memories/domain/repositories/memories_repository.dart';

class MemoriesRepositoryImpl implements MemoriesRepository {
  const MemoriesRepositoryImpl(this._remote);

  final MemoriesRemoteDataSource _remote;

  // DTO -> entity conversion runs inside safeApiCall, so a bad date in the
  // response becomes an ApiFailure like any other parsing problem.

  @override
  Future<ApiResult<List<Memory>>> getRecent({int limit = 3}) {
    return safeApiCall(() async {
      final dtos = await _remote.getRecent(limit: limit);
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<List<Memory>>> getOnThisDay() {
    return safeApiCall(() async {
      final dtos = await _remote.getOnThisDay();
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<Memory>> getById(String id) {
    return safeApiCall(() async => (await _remote.getById(id)).toEntity());
  }

  @override
  Future<ApiResult<Memory>> create(MemoryDraft draft) {
    return safeApiCall(() async {
      final dto = await _remote.create(CreateMemoryRequestDto.fromDraft(draft));
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<void>> delete(String id) {
    return safeApiCall(() => _remote.delete(id));
  }
}
