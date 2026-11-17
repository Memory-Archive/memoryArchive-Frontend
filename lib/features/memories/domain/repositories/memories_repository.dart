import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';

abstract interface class MemoriesRepository {
  /// The newest memories, for the Home screen.
  Future<ApiResult<List<Memory>>> getRecent({int limit = 3});

  /// Memories from today's calendar date in earlier years.
  Future<ApiResult<List<Memory>>> getOnThisDay();

  Future<ApiResult<Memory>> getById(String id);

  Future<ApiResult<Memory>> create(MemoryDraft draft);

  Future<ApiResult<void>> delete(String id);
}
