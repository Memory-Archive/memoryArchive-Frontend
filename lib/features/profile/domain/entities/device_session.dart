import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_session.freezed.dart';

/// A device that is logged in to the account (one refresh token).
@freezed
abstract class DeviceSession with _$DeviceSession {
  const factory DeviceSession({
    required String id,
    required String deviceName,
    required DateTime lastActiveAt,
    String? location,

    /// True for the device this app is running on.
    @Default(false) bool isCurrent,
  }) = _DeviceSession;
}
