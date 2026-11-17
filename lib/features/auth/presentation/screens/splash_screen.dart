import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/widgets/state_views.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_state.dart';

/// Shown while the stored session is checked. The router leaves this screen
/// by itself once the session status is known. The only state that stays
/// here is a network failure, which offers a retry.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return switch (state) {
              AuthFailure(:final error) when !error.isUnauthorized => ErrorState(
                message: error.message,
                onRetry: context.read<AuthCubit>().checkSession,
              ),
              _ => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(AppStrings.appName, style: AppTextStyles.displayXl),
                    AppGap.v24,
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}
