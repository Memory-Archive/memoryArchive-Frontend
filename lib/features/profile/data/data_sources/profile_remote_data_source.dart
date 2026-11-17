import 'package:dio/dio.dart';
import 'package:smart_memories/core/constants/api_endpoints.dart';
import 'package:smart_memories/core/validation/safe_json.dart';
import 'package:smart_memories/features/profile/data/models/device_session_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<List<DeviceSessionDto>> getSessions();

  Future<void> revokeSession(String id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DeviceSessionDto>> getSessions() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.sessions);
    return parseDtoList(
      response.data,
      DeviceSessionDto.fromJson,
      name: 'DeviceSessionDto',
    );
  }

  @override
  Future<void> revokeSession(String id) async {
    await _dio.delete<dynamic>(ApiEndpoints.session(id));
  }
}
