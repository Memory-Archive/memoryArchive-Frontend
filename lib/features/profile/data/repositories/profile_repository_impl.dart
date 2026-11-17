import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/core/networking/safe_api_call.dart';
import 'package:smart_memories/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:smart_memories/features/profile/domain/entities/device_session.dart';
import 'package:smart_memories/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<ApiResult<List<DeviceSession>>> getSessions() {
    return safeApiCall(() async {
      final dtos = await _remote.getSessions();
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<void>> revokeSession(String id) {
    return safeApiCall(() => _remote.revokeSession(id));
  }
}
