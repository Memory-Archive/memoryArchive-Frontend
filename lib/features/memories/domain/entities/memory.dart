import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory.freezed.dart';

/// One saved memory.
@freezed
abstract class Memory with _$Memory {
  const factory Memory({
    required String id,
    required String title,
    required DateTime memoryDate,
    String? description,

    /// "HH:mm", optional.
    String? memoryTime,
    String? placeName,
    String? coverUrl,
    @Default(<String>[]) List<String> photoUrls,

    /// Total photos including the cover; may exceed [photoUrls].length when
    /// the list endpoint returns only a preview.
    @Default(0) int photoCount,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> taggedPeople,
    String? musicUrl,
    String? collectionName,

    /// How many collection members can see this memory. 0 means private.
    @Default(0) int sharedWithCount,
  }) = _Memory;
}

/// What the editor collects before a memory exists.
@freezed
abstract class MemoryDraft with _$MemoryDraft {
  const factory MemoryDraft({
    required String title,
    required DateTime memoryDate,
    String? memoryTime,
    String? placeName,
    String? description,
  }) = _MemoryDraft;
}
