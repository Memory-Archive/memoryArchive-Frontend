import 'package:dio/dio.dart';
import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/validation/safe_json.dart';
import 'package:smart_memories/features/memories/data/models/memory_dto.dart';

abstract interface class MemoriesRemoteDataSource {
  Future<List<MemoryDto>> getRecent({required int limit});

  Future<List<MemoryDto>> getOnThisDay();

  Future<MemoryDto> getById(String id);

  Future<MemoryDto> create(CreateMemoryRequestDto request);

  Future<void> delete(String id);
}

class MemoriesRemoteDataSourceImpl implements MemoriesRemoteDataSource {
  const MemoriesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<MemoryDto>> getRecent({required int limit}) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.memories,
      queryParameters: <String, dynamic>{'limit': limit, 'sort': 'newest'},
    );
    return parseDtoList(
      unwrapData(response.data),
      MemoryDto.fromJson,
      name: 'MemoryDto',
    );
  }

  @override
  Future<List<MemoryDto>> getOnThisDay() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.memoriesOnThisDay);
    return parseDtoList(
      unwrapData(response.data),
      MemoryDto.fromJson,
      name: 'MemoryDto',
    );
  }

  @override
  Future<MemoryDto> getById(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.memory(id));
    return parseDto(
      unwrapData(response.data),
      MemoryDto.fromJson,
      name: 'MemoryDto',
    );
  }

  @override
  Future<MemoryDto> create(CreateMemoryRequestDto request) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.memories,
      data: request.toJson(),
    );
    return parseDto(
      unwrapData(response.data),
      MemoryDto.fromJson,
      name: 'MemoryDto',
    );
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<dynamic>(ApiEndpoints.memory(id));
  }
}