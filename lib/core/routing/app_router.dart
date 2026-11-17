import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/di/injection.dart';
import 'package:smart_memories/core/helpers/session_helper.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/widgets/app_bottom_nav.dart';
import 'package:smart_memories/core/widgets/coming_soon_screen.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_memories/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_memories/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:smart_memories/features/auth/presentation/screens/splash_screen.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_detail_cubit.dart';
import 'package:smart_memories/features/memories/presentation/cubit/memory_editor_cubit.dart';
import 'package:smart_memories/features/memories/presentation/screens/memory_detail_screen.dart';
import 'package:smart_memories/features/memories/presentation/screens/memory_editor_screen.dart';
import 'package:smart_memories/features/places/presentation/cubit/home_cubit.dart';
import 'package:smart_memories/features/places/presentation/screens/home_screen.dart';
import 'package:smart_memories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_memories/features/profile/presentation/screens/profile_screen.dart';

/// Builds the app's router.
///
/// Access control lives in [_redirect] and nowhere else: it reads the session
/// status and decides where the user may be. Screens never check whether
/// someone is logged in, and never navigate after login or logout; they
/// change the session and the router reacts.
///
/// Each route creates the Cubit its screen needs, so a Cubit lives exactly
/// as long as its screen.
GoRouter createRouter(SessionHelper session) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: session,
    redirect: (context, state) => _redirect(session, state.matchedLocation),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkSession(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider<HomeCubit>(
          create: (_) => getIt<HomeCubit>()..load(),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<ProfileCubit>(
              create: (_) => getIt<ProfileCubit>()..load(),
            ),
            BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
          ],
          child: const ProfileScreen(),
        ),
      ),
      // Declared before /memories/:id so "new" is not read as an id.
      GoRoute(
        path: AppRoutes.memoryNew,
        builder: (context, state) => BlocProvider<MemoryEditorCubit>(
          create: (_) => getIt<MemoryEditorCubit>(),
          child: const MemoryEditorScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.memoryDetailPattern,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BlocProvider<MemoryDetailCubit>(
            create: (_) => getIt<MemoryDetailCubit>()..load(id),
            child: MemoryDetailScreen(memoryId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) =>
            const ComingSoonScreen(title: 'Map', tab: AppNavTab.map),
      ),
      GoRoute(
        path: AppRoutes.collections,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Collections',
          tab: AppNavTab.collections,
        ),
      ),
      GoRoute(
        path: AppRoutes.timeline,
        builder: (context, state) => const ComingSoonScreen(title: 'Timeline'),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const ComingSoonScreen(title: 'Search'),
      ),
    ],
  );
}

String? _redirect(SessionHelper session, String location) {
  final onAuthScreen =
      location == AppRoutes.login || location == AppRoutes.signUp;

  switch (session.status) {
    case SessionStatus.unknown:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case SessionStatus.unauthenticated:
      return onAuthScreen ? null : AppRoutes.login;
    case SessionStatus.authenticated:
      return onAuthScreen || location == AppRoutes.splash
          ? AppRoutes.home
          : null;
  }
}
