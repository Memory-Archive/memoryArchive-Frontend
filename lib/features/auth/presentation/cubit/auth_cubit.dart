import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';
import 'package:smart_memories/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_state.dart';

/// Drives the splash, login, sign-up and logout flows.
///
/// It never navigates. A successful login or logout changes the session
/// (inside the repository) and the router moves the user.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.initial());

  final AuthRepository _repository;

  Future<void> checkSession() => _run(_repository.restoreSession);

  Future<void> login({required String email, required String password}) {
    return _run(
      () => _repository.login(email: email.trim(), password: password),
    );
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.register(
        username: username.trim(),
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> logout() async {
    emit(const AuthState.loading());
    await _repository.logout();
    if (isClosed) return;
    emit(const AuthState.initial());
  }

  Future<void> _run(Future<ApiResult<User>> Function() action) async {
    emit(const AuthState.loading());
    final result = await action();
    // The screen may have been closed while the request was in flight.
    if (isClosed) return;
    emit(
      result.when(success: AuthState.success, failure: AuthState.failure),
    );
  }
}
