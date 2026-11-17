import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/core/helpers/date_formatter.dart';
import 'package:smart_memories/core/validation/safe_json.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';

part 'memory_dto.freezed.dart';
part 'memory_dto.g.dart';

/// A memory exactly as the API sends it.
@freezed
abstract class MemoryDto with _$MemoryDto {
  const MemoryDto._();

  const factory MemoryDto({
    required String id,
    required String title,

    /// "YYYY-MM-DD".
    required String memoryDate,
    String? description,
    String? memoryTime,
    String? placeName,
    String? coverUrl,
    @Default(<String>[]) List<String> photoUrls,
    @Default(0) int photoCount,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> taggedPeople,
    String? musicUrl,
    String? collectionName,
    @Default(0) int sharedWithCount,
  }) = _MemoryDto;

  factory MemoryDto.fromJson(Map<String, dynamic> json) =>
      _$MemoryDtoFromJson(json);

  Memory toEntity() {
    return Memory(
      id: id,
      title: title,
      memoryDate: parseDate(memoryDate, field: 'memoryDate'),
      description: description,
      memoryTime: memoryTime,
      placeName: placeName,
      coverUrl: coverUrl,
      photoUrls: photoUrls,
      photoCount: photoCount,
      tags: tags,
      taggedPeople: taggedPeople,
      musicUrl: musicUrl,
      collectionName: collectionName,
      sharedWithCount: sharedWithCount,
    );
  }
}

/// Body of POST /memories.
@freezed
abstract class CreateMemoryRequestDto with _$CreateMemoryRequestDto {
  const factory CreateMemoryRequestDto({
    required String title,
    required String memoryDate,
    String? memoryTime,
    String? placeName,
    String? description,
  }) = _CreateMemoryRequestDto;

  factory CreateMemoryRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMemoryRequestDtoFromJson(json);

  factory CreateMemoryRequestDto.fromDraft(MemoryDraft draft) {
    return CreateMemoryRequestDto(
      title: draft.title,
      memoryDate: AppDateFormat.iso(draft.memoryDate),
      memoryTime: draft.memoryTime,
      placeName: draft.placeName,
      description: draft.description,
    );
  }
}
