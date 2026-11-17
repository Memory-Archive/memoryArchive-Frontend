import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/helpers/date_formatter.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';
import 'package:smart_memories/core/widgets/app_bottom_nav.dart';
import 'package:smart_memories/core/widgets/app_button.dart';
import 'package:smart_memories/core/widgets/app_cached_image.dart';
import 'package:smart_memories/core/widgets/app_card.dart';
import 'package:smart_memories/core/widgets/circle_icon_button.dart';
import 'package:smart_memories/core/widgets/eyebrow_text.dart';
import 'package:smart_memories/core/widgets/media_list_tile.dart';
import 'package:smart_memories/core/widgets/state_views.dart';
import 'package:smart_memories/features/memories/domain/entities/memory.dart';
import 'package:smart_memories/features/places/presentation/cubit/home_cubit.dart';
import 'package:smart_memories/features/places/presentation/cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppNavTab.home),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() => const AppLoader(),
              HomeFailure(:final error) => ErrorState(
                message: error.message,
                onRetry: cubit.load,
              ),
              HomeSuccess(:final firstName, :final recent, :final onThisDay) =>
                RefreshIndicator(
                  onRefresh: cubit.load,
                  child: _HomeContent(
                    firstName: firstName,
                    recent: recent,
                    onThisDay: onThisDay,
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.firstName,
    required this.recent,
    required this.onThisDay,
  });

  final String firstName;
  final List<Memory> recent;
  final Memory? onThisDay;

  String _subtitle(Memory memory) {
    final date = AppDateFormat.dayMonthYear(memory.memoryDate);
    final place = memory.placeName;
    return place == null ? date : '$date · $place';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = AppDateFormat.greeting(now);
    final featured = onThisDay;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.x16,
        AppSpacing.page,
        AppSpacing.x24,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppDateFormat.weekdayDayMonth(now),
                    style: AppTextStyles.caption,
                  ),
                  AppGap.v2,
                  Text(
                    firstName.isEmpty ? greeting : '$greeting, $firstName',
                    style: AppTextStyles.display,
                  ),
                ],
              ),
            ),
            AppGap.h12,
            CircleIconButton(
              icon: Icons.search,
              semanticLabel: 'Search memories',
              onPressed: () => context.push(AppRoutes.search),
            ),
          ],
        ),
        if (featured != null) ...<Widget>[
          AppGap.v22,
          AppCard.album(
            onTap: () => context.push(AppRoutes.memory(featured.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: AppSizes.homeCover,
                  width: double.infinity,
                  child: AppCachedImage(
                    url: featured.coverUrl,
                    placeholderLabel: 'Cover photo',
                  ),
                ),
                AppGap.v12,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      EyebrowText(
                        'On this day · '
                        '${AppDateFormat.yearsAgo(featured.memoryDate, now)}',
                      ),
                      AppGap.v4,
                      Text(featured.title, style: AppTextStyles.title),
                      AppGap.v4,
                      Text(_subtitle(featured), style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        AppGap.v22,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Recent memories', style: AppTextStyles.sectionTitle),
            AppButton(
              label: 'See timeline',
              variant: AppButtonVariant.text,
              size: AppButtonSize.pill,
              expand: false,
              onPressed: () => context.push(AppRoutes.timeline),
            ),
          ],
        ),
        AppGap.v4,
        if (recent.isEmpty)
          EmptyState(
            title: 'No memories yet',
            message: 'Save your first one and it will show up here.',
            actionLabel: 'Add a memory',
            onAction: () => context.push(AppRoutes.memoryNew),
          )
        else
          for (var i = 0; i < recent.length; i++) ...<Widget>[
            if (i > 0) AppGap.v12,
            MediaListTile(
              title: recent[i].title,
              subtitle: _subtitle(recent[i]),
              imageUrl: recent[i].coverUrl,
              tintIndex: i + 1,
              onTap: () => context.push(AppRoutes.memory(recent[i].id)),
            ),
          ],
      ],
    );
  }
}
