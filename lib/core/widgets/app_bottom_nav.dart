import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_memories/core/routing/app_routes.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';

enum AppNavTab { home, map, collections, profile, none }

/// The bottom navigation shown on the main screens: four tabs and a centre
/// button that opens the memory editor.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});

  final AppNavTab current;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.line, width: AppSizes.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.navBar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: current == AppNavTab.home,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.place_outlined,
                label: 'Map',
                selected: current == AppNavTab.map,
                onTap: () => context.go(AppRoutes.map),
              ),
              _AddButton(onTap: () => context.push(AppRoutes.memoryNew)),
              _NavItem(
                icon: Icons.photo_library_outlined,
                label: 'Collections',
                selected: current == AppNavTab.collections,
                onTap: () => context.go(AppRoutes.collections),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: current == AppNavTab.profile,
                onTap: () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSizes.thumbnail,
            minHeight: AppSizes.navItem,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: AppSizes.iconMedium, color: color),
              AppGap.v4,
              Text(label, style: AppTextStyles.micro.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a memory',
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox.square(
            dimension: AppSizes.navAddButton,
            child: Icon(
              Icons.add,
              size: AppSizes.iconLarge,
              color: AppColors.surface,
            ),
          ),
        ),
      ),
    );
  }
}
