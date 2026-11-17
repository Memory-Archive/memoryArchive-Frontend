import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';

/// A bordered surface. Use [AppCard.album] for the photo-album style cards
/// with a small corner radius (On This Day).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.x10),
    this.radius = AppRadii.card,
  });

  const AppCard.album({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.x12,
      AppSpacing.x12,
      AppSpacing.x12,
      AppSpacing.x16,
    ),
  }) : radius = AppRadii.album;

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(
          color: AppColors.line,
          width: AppSizes.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
