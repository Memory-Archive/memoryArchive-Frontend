import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/helpers/date_formatter.dart';
import 'package:smart_memories/core/networking/mock_http_error.dart';
import 'package:smart_memories/features/memories/data/data_sources/memories_remote_data_source.dart';
import 'package:smart_memories/features/memories/data/models/memory_dto.dart';

/// In-memory memories for --dart-define=USE_MOCK=true, seeded with the sample
/// content from the design. Created memories last until the app restarts.
class MockMemoriesRemoteDataSource implements MemoriesRemoteDataSource {
  MockMemoriesRemoteDataSource() {
    final now = DateTime.now();
    _memories.addAll(<MemoryDto>[
      // Dated three years ago today so the On This Day card always shows.
      MemoryDto(
        id: 'memory-dahab',
        title: 'Dahab with the cousins',
        memoryDate: AppDateFormat.iso(DateTime(now.year - 3, now.month, now.day)),
        placeName: 'Dahab, South Sinai',
        description:
            'We drove down overnight and reached the lagoon just after '
            'sunrise. Omar swore he saw a turtle. Nobody believed him until '
            'the last morning.',
        photoCount: 6,
        tags: const <String>['beach', 'family'],
        collectionName: 'Summer 2023',
        sharedWithCount: 3,
      ),
      MemoryDto(
        id: 'memory-corniche',
        title: 'Corniche at sunset',
        memoryDate: AppDateFormat.iso(now.subtract(const Duration(days: 7))),
        placeName: 'Alexandria',
        photoCount: 4,
      ),
      MemoryDto(
        id: 'memory-birthday',
        title: "Mum's birthday dinner",
        memoryDate: AppDateFormat.iso(now.subtract(const Duration(days: 13))),
        placeName: 'Zamalek, Cairo',
        photoCount: 9,
        tags: const <String>['family'],
      ),
      MemoryDto(
        id: 'memory-final-year',
        title: 'First day of final year',
        memoryDate: AppDateFormat.iso(now.subtract(const Duration(days: 49))),
        placeName: 'Campus',
        photoCount: 2,
      ),
    ]);
  }

  final List<MemoryDto> _memories = <MemoryDto>[];
  int _nextId = 1;

  @override
  Future<List<MemoryDto>> getRecent({required int limit}) async {
    await Future<void>.delayed(mockLatency);
    final sorted = List<MemoryDto>.of(_memories)
      ..sort((a, b) => b.memoryDate.compareTo(a.memoryDate));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<MemoryDto>> getOnThisDay() async {
    await Future<void>.delayed(mockLatency);
    final now = DateTime.now();
    final monthDay = AppDateFormat.iso(now).substring(4); // "-MM-DD"
    final thisYear = now.year.toString();
    return _memories
        .where(
          (m) =>
              m.memoryDate.endsWith(monthDay) &&
              !m.memoryDate.startsWith(thisYear),
        )
        .toList();
  }

  @override
  Future<MemoryDto> getById(String id) async {
    await Future<void>.delayed(mockLatency);
    for (final memory in _memories) {
      if (memory.id == id) return memory;
    }
    throw _notFound(id);
  }

  @override
  Future<MemoryDto> create(CreateMemoryRequestDto request) async {
    await Future<void>.delayed(mockLatency);
    final memory = MemoryDto(
      id: 'memory-new-${_nextId++}',
      title: request.title,
      memoryDate: request.memoryDate,
      memoryTime: request.memoryTime,
      placeName: request.placeName,
      description: request.description,
    );
    _memories.add(memory);
    return memory;
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(mockLatency);
    final before = _memories.length;
    _memories.removeWhere((m) => m.id == id);
    if (_memories.length == before) throw _notFound(id);
  }

  Exception _notFound(String id) {
    return mockHttpError(
      path: ApiEndpoints.memory(id),
      statusCode: 404,
      body: <String, dynamic>{
        'message': 'This memory no longer exists.',
      },
    );
  }
}