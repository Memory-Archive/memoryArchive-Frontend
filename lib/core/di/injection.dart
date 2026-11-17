import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_memories/core/constants/env.dart';
import 'package:smart_memories/core/helpers/session_helper.dart';
import 'package:smart_memories/core/networking/dio_factory.dart';
import 'package:smart_memories/core/routing/app_router.dart';
import 'package:smart_memories/core/storage/local_storage.dart';
import 'package:smart_memories/core/storage/prefs_local_storage.dart';
import 'package:smart_memories/core/storage/secure_local_storage.dart';
import 'package:smart_memories/core/storage/token_storage.dart';
import 'package:smart_memories/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:smart_memories/features/auth/data/data_sources/mock_auth_remote_data_source.dart';
import 'package:smart_memories/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_memories/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_memories/features/memories/data/data_sources/memories_remote_data_source.dart';
import 'package:smart_memories/features/memories/data/data_sources/mock_memories_remote_data_source.dart';
import 'package:smart_memories/features/memories/data/repositories/memories_repository_impl.dart';
import 'package:smart_memories/features/memories/domain/repositories/memories_repository.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_detail_cubit.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_editor_cubit.dart';
import 'package:smart_memories/features/places/presentation/cubit/home_cubit.dart';
import 'package:smart_memories/features/profile/data/data_sources/mock_profile_remote_data_source.dart';
import 'package:smart_memories/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:smart_memories/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:smart_memories/features/profile/domain/repositories/profile_repository.dart';
import 'package:smart_memories/features/profile/presentation/cubit/profile_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Names for the two LocalStorage implementations.
abstract final class DiNames {
  static const String secureStorage = 'secureStorage';
  static const String prefsStorage = 'prefsStorage';
}

/// The composition root: the only place that knows which implementation sits
/// behind each interface. Called once from main().
///
/// Adding a feature: write a _registerX() function below and call it here.
/// Rules: data sources and repositories are lazy singletons; Cubits are
/// factories (a new one per screen).
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  _registerCore(prefs);
  _registerAuth();
  _registerMemories();
  _registerPlaces();
  _registerProfile();
}

void _registerCore(SharedPreferences prefs) {
  getIt
    ..registerLazySingleton<LocalStorage>(
      () => const SecureLocalStorage(FlutterSecureStorage()),
      instanceName: DiNames.secureStorage,
    )
    ..registerLazySingleton<LocalStorage>(
      () => PrefsLocalStorage(prefs),
      instanceName: DiNames.prefsStorage,
    )
    ..registerLazySingleton<TokenStorage>(
      () => TokenStorage(
        getIt<LocalStorage>(instanceName: DiNames.secureStorage),
      ),
    )
    ..registerLazySingleton<SessionHelper>(
      () => SessionHelper(getIt<TokenStorage>()),
    )
    ..registerLazySingleton<Dio>(
      () => DioFactory.create(
        tokenStorage: getIt<TokenStorage>(),
        onSessionExpired: getIt<SessionHelper>().end,
      ),
    )
    ..registerLazySingleton<GoRouter>(
      () => createRouter(getIt<SessionHelper>()),
    );
}

void _registerAuth() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => Env.useMock
          ? MockAuthRemoteDataSource()
          : AuthRemoteDataSourceImpl(getIt<Dio>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt<AuthRemoteDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
        session: getIt<SessionHelper>(),
      ),
    )
    ..registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
}

void _registerMemories() {
  getIt
    ..registerLazySingleton<MemoriesRemoteDataSource>(
      () => Env.useMock
          ? MockMemoriesRemoteDataSource()
          : MemoriesRemoteDataSourceImpl(getIt<Dio>()),
    )
    ..registerLazySingleton<MemoriesRepository>(
      () => MemoriesRepositoryImpl(getIt<MemoriesRemoteDataSource>()),
    )
    ..registerFactory<MemoryDetailCubit>(
      () => MemoryDetailCubit(getIt<MemoriesRepository>()),
    )
    ..registerFactory<MemoryEditorCubit>(
      () => MemoryEditorCubit(getIt<MemoriesRepository>()),
    );
}

void _registerPlaces() {
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      memories: getIt<MemoriesRepository>(),
      auth: getIt<AuthRepository>(),
    ),
  );
}

void _registerProfile() {
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => Env.useMock
          ? MockProfileRemoteDataSource()
          : ProfileRemoteDataSourceImpl(getIt<Dio>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(
        profile: getIt<ProfileRepository>(),
        auth: getIt<AuthRepository>(),
      ),
    );
}
