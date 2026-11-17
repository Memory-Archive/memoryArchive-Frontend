import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';

/// A pill label. Tinted for collections, outlined for tags.
class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.onTap, this.tinted = false});

  final String label;
  final VoidCallback? onTap;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tinted ? AppColors.primaryTint : Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.chip),
        side: tinted
            ? BorderSide.none
            : const BorderSide(
                color: AppColors.fieldBorder,
                width: AppSizes.borderWidth,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.chip),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: tinted
                    ? AppTextStyles.label.copyWith(color: AppColors.primaryDark)
                    : AppTextStyles.caption.copyWith(color: AppColors.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
