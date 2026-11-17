import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';

/// A round surface-coloured icon button (back, search).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.bordered = true,
  });

  final IconData icon;

  /// Read by screen readers; the button has no visible text.
  final String semanticLabel;
  final VoidCallback? onPressed;

  /// The border is dropped when the button sits on top of a photo.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(
          side: bordered
              ? const BorderSide(
                  color: AppColors.line,
                  width: AppSizes.borderWidth,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSizes.touchTarget,
            child: Icon(icon, size: AppSizes.iconMedium, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}
