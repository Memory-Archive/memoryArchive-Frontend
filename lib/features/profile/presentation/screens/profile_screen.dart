import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_memories/core/constants/app_strings.dart';
import 'package:smart_memories/core/helpers/date_formatter.dart';
import 'package:smart_memories/core/helpers/extensions.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/widgets/app_bottom_nav.dart';
import 'package:smart_memories/core/widgets/app_button.dart';
import 'package:smart_memories/core/widgets/app_card.dart';
import 'package:smart_memories/core/widgets/eyebrow_text.dart';
import 'package:smart_memories/core/widgets/state_views.dart';
import 'package:smart_memories/features/auth/domain/entities/user.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smart_memories/features/auth/presentation/cubit/auth_state.dart';
import 'package:smart_memories/features/profile/domain/entities/device_session.dart';
import 'package:smart_memories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:smart_memories/features/profile/presentation/cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppNavTab.profile),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const AppLoader(),
              ProfileFailure(:final error) => ErrorState(
                message: error.message,
                onRetry: cubit.load,
              ),
              ProfileSuccess(:final user, :final sessions) => _ProfileContent(
                user: user,
                sessions: sessions,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user, required this.sessions});

  final User user;
  final List<DeviceSession> sessions;

  void _notAvailable(BuildContext context) =>
      context.showSnack(AppStrings.notAvailableYet);

  Future<void> _revoke(BuildContext context, DeviceSession session) async {
    final errorMessage = await context.read<ProfileCubit>().revokeSession(
      session.id,
    );
    if (errorMessage != null && context.mounted) {
      context.showSnack(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bio = user.bio;
    final passwordChangedAt = user.passwordChangedAt;
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.x16,
        AppSpacing.page,
        AppSpacing.x16,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            _Avatar(initials: user.name.initials),
            AppGap.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(user.name, style: AppTextStyles.headlineSm),
                  AppGap.v2,
                  Text(
                    '@${user.username} · ${user.email}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (bio != null && bio.isNotEmpty) ...<Widget>[
          AppGap.v18,
          Text(bio, style: AppTextStyles.bodySm),
        ],
        AppGap.v18,
        AppButton(
          label: 'Edit profile',
          variant: AppButtonVariant.outline,
          size: AppButtonSize.medium,
          onPressed: () => _notAvailable(context),
        ),
        AppGap.v18,
        const EyebrowText('Security'),
        AppGap.v10,
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              _SettingsRow(
                label: 'Change password',
                trailing: passwordChangedAt == null
                    ? null
                    : 'Last changed in '
                          '${AppDateFormat.monthName(passwordChangedAt)}',
                onTap: () => _notAvailable(context),
              ),
              for (final session in sessions) ...<Widget>[
                const Divider(),
                _SessionRow(
                  session: session,
                  now: now,
                  onLogOut: () => _revoke(context, session),
                ),
              ],
            ],
          ),
        ),
        AppGap.v18,
        const EyebrowText('Privacy'),
        AppGap.v10,
        const AppCard(
          padding: EdgeInsets.all(AppSpacing.x14),
          child: Text(
            'Every memory and collection is private when you create it. '
            'Only people you invite to a collection can see what is inside.',
            style: AppTextStyles.caption,
          ),
        ),
        AppGap.v24,
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return AppButton(
              label: 'Log out',
              variant: AppButtonVariant.dark,
              size: AppButtonSize.medium,
              isLoading: authState is AuthLoading,
              // No navigation here: logging out ends the session and the
              // router returns to the login screen.
              onPressed: context.read<AuthCubit>().logout,
            );
          },
        ),
        AppGap.v4,
        AppButton(
          label: 'Delete my account and all memories',
          variant: AppButtonVariant.dangerText,
          size: AppButtonSize.pill,
          onPressed: () => _notAvailable(context),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: AppSizes.avatarLarge,
        height: AppSizes.avatarLarge,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: Text(
          initials,
          style: AppTextStyles.headlineSm.copyWith(color: AppColors.primaryDark),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.onTap, this.trailing});

  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.listRow),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(label, style: AppTextStyles.body)),
                if (trailing != null)
                  Text(trailing!, style: AppTextStyles.small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.now,
    required this.onLogOut,
  });

  final DeviceSession session;
  final DateTime now;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    final activity = AppDateFormat.relative(session.lastActiveAt, now);
    final location = session.location;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x14,
        vertical: AppSpacing.x10,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(session.deviceName, style: AppTextStyles.bodySmStrong),
                Text(
                  location == null ? activity : '$location · $activity',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          AppGap.h12,
          if (session.isCurrent)
            Text(
              'Current',
              style: AppTextStyles.smallStrong.copyWith(
                color: AppColors.primaryDark,
              ),
            )
          else
            AppButton(
              label: 'Log out',
              variant: AppButtonVariant.dangerText,
              size: AppButtonSize.pill,
              expand: false,
              onPressed: onLogOut,
            ),
        ],
      ),
    );
  }
}
