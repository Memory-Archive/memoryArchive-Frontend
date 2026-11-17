import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';
import 'package:smart_memories/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_memories/features/profile/domain/entities/device_session.dart';
import 'package:smart_memories/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_memories/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository profile, required AuthRepository auth})
    : _profile = profile,
      _auth = auth,
      super(const ProfileState.initial());

  final ProfileRepository _profile;
  final AuthRepository _auth;

  Future<void> load() async {
    emit(const ProfileState.loading());

    final userFuture = _auth.getCurrentUser();
    final sessionsFuture = _profile.getSessions();
    final userResult = await userFuture;
    final sessionsResult = await sessionsFuture;
    if (isClosed) return;

    final User user;
    switch (userResult) {
      case ApiSuccess<User>(:final data):
        user = data;
      case ApiFailure<User>(:final error):
        emit(ProfileState.failure(error));
        return;
    }

    // The profile still shows if only the session list failed to load.
    final sessions = switch (sessionsResult) {
      ApiSuccess<List<DeviceSession>>(:final data) => data,
      ApiFailure<List<DeviceSession>>() => const <DeviceSession>[],
    };

    emit(ProfileState.success(user: user, sessions: sessions));
  }

  /// Logs another device out, then reloads the list.
  /// Returns an error message to show, or null on success.
  Future<String?> revokeSession(String id) async {
    final result = await _profile.revokeSession(id);
    switch (result) {
      case ApiSuccess<void>():
        await load();
        return null;
      case ApiFailure<void>(:final error):
        return error.message;
    }
  }
}
