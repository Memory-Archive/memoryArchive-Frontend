import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/features/profile/domain/entities/device_session.dart';

abstract interface class ProfileRepository {
  /// Every device logged in to the account.
  Future<ApiResult<List<DeviceSession>>> getSessions();

  /// Logs another device out.
  Future<ApiResult<void>> revokeSession(String id);
}
