import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/core/helpers/extensions.dart';
import 'package:smart_memories/core/networking/api_result.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';
import 'package:smart_memories/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';
import 'package:smart_memories/features/memories/domain/repositories/memories_repository.dart';
import 'package:smart_memories/features/places/presentation/cubit/home_state.dart';

/// Loads everything the Home screen shows. It reads from two other
/// features, and does so only through their DOMAIN interfaces: a feature may
/// depend on another feature's domain layer, never on its data layer.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required MemoriesRepository memories, required AuthRepository auth})
    : _memories = memories,
      _auth = auth,
      super(const HomeState.initial());

  final MemoriesRepository _memories;
  final AuthRepository _auth;

  Future<void> load() async {
    emit(const HomeState.loading());

    // The three requests are independent, so they run together.
    final userFuture = _auth.getCurrentUser();
    final recentFuture = _memories.getRecent();
    final onThisDayFuture = _memories.getOnThisDay();

    final userResult = await userFuture;
    final recentResult = await recentFuture;
    final onThisDayResult = await onThisDayFuture;
    if (isClosed) return;

    final List<Memory> recent;
    switch (recentResult) {
      case ApiSuccess<List<Memory>>(:final data):
        recent = data;
      case ApiFailure<List<Memory>>(:final error):
        emit(HomeState.failure(error));
        return;
    }

    // The greeting and the On This Day card are extras: if either request
    // fails, the screen still shows the recent memories.
    final firstName = switch (userResult) {
      ApiSuccess<User>(:final data) => data.name.firstWord,
      ApiFailure<User>() => '',
    };
    final onThisDay = switch (onThisDayResult) {
      ApiSuccess<List<Memory>>(:final data) when data.isNotEmpty => data.first,
      _ => null,
    };

    emit(
      HomeState.success(
        firstName: firstName,
        recent: recent,
        onThisDay: onThisDay,
      ),
    );
  }
}
