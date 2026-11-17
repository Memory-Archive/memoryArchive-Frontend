import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';

/// What the app can do with accounts. The presentation layer depends on this
/// interface only; the implementation lives in data/.
abstract interface class AuthRepository {
  Future<ApiResult<User>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<User>> register({
    required String username,
    required String email,
    required String password,
  });

  /// Called once at startup. Succeeds when a stored session is still valid
  /// and updates the app-wide session status either way.
  Future<ApiResult<User>> restoreSession();

  /// The current user's profile, for screens that show it.
  Future<ApiResult<User>> getCurrentUser();

  /// Ends the session on the server (best effort) and on the device (always).
  Future<void> logout();
}
