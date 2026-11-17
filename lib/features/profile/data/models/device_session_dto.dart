import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_memories/features/profile/domain/entities/device_session.dart';

part 'device_session_dto.freezed.dart';
part 'device_session_dto.g.dart';

@freezed
abstract class DeviceSessionDto with _$DeviceSessionDto {
  const DeviceSessionDto._();

  const factory DeviceSessionDto({
    required String id,
    required String deviceName,
    required DateTime lastActiveAt,
    String? location,
    @Default(false) bool isCurrent,
  }) = _DeviceSessionDto;

  factory DeviceSessionDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceSessionDtoFromJson(json);

  DeviceSession toEntity() {
    return DeviceSession(
      id: id,
      deviceName: deviceName,
      lastActiveAt: lastActiveAt,
      location: location,
      isCurrent: isCurrent,
    );
  }
}
