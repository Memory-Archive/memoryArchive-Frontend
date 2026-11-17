import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/widgets/app_bottom_nav.dart';
import 'package:smart_memories/core/widgets/circle_icon_button.dart';
import 'package:smart_memories/core/widgets/state_views.dart';

/// A stand-in for screens that are in the design but not built yet (Map,
/// Collections, Timeline, Search). It keeps every link in the app working.
/// Replace the route's builder in core/routing/app_router.dart when the real
/// screen exists.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    this.tab = AppNavTab.none,
  });

  final String title;

  /// Set for screens that are bottom-navigation tabs.
  final AppNavTab tab;

  @override
  Widget build(BuildContext context) {
    final isTab = tab != AppNavTab.none;
    return Scaffold(
      bottomNavigationBar: isTab ? AppBottomNav(current: tab) : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!isTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.x12,
                  AppSpacing.page,
                  0,
                ),
                child: CircleIconButton(
                  icon: Icons.chevron_left,
                  semanticLabel: 'Back',
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.home),
                ),
              ),
            Expanded(
              child: EmptyState(
                title: title,
                message: 'This screen is designed but not built yet.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
