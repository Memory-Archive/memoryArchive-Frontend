import 'package:smart_memories/core/networking/mock_http_error.dart';
import 'package:smart_memories/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:smart_memories/features/profile/data/models/device_session_dto.dart';

/// In-memory sessions for --dart-define=USE_MOCK=true, matching the design.
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  MockProfileRemoteDataSource() {
    final now = DateTime.now();
    _sessions.addAll(<DeviceSessionDto>[
      DeviceSessionDto(
        id: 'session-phone',
        deviceName: 'This phone',
        location: 'Cairo',
        lastActiveAt: now,
        isCurrent: true,
      ),
      DeviceSessionDto(
        id: 'session-chrome',
        deviceName: 'Chrome on Windows',
        location: 'Cairo',
        lastActiveAt: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  final List<DeviceSessionDto> _sessions = <DeviceSessionDto>[];

  @override
  Future<List<DeviceSessionDto>> getSessions() async {
    await Future<void>.delayed(mockLatency);
    return List<DeviceSessionDto>.of(_sessions);
  }

  @override
  Future<void> revokeSession(String id) async {
    await Future<void>.delayed(mockLatency);
    _sessions.removeWhere((session) => session.id == id);
  }
}
