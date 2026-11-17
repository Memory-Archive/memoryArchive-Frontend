import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';

enum AppButtonVariant {
  /// Filled green: the main action on a screen.
  primary,

  /// Green outline on a transparent background.
  outline,

  /// Filled dark ink (Log out).
  dark,

  /// Red outline (Delete memory).
  dangerOutline,

  /// Red text, no border (Delete account, Log out of a device).
  dangerText,

  /// Green text, no border (links such as "Create an account").
  text,

  /// Surface-coloured with dark text, for buttons placed on top of a photo.
  surface,
}

enum AppButtonSize {
  large(AppSizes.buttonLarge, AppRadii.card, AppTextStyles.button),
  medium(AppSizes.buttonMedium, AppRadii.card, AppTextStyles.buttonSm),
  pill(AppSizes.touchTarget, AppRadii.pill, AppTextStyles.buttonSm);

  const AppButtonSize(this.height, this.radius, this.textStyle);

  final double height;
  final double radius;
  final TextStyle textStyle;
}

/// The only button widget screens should use.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Shows a spinner and ignores taps.
  final bool isLoading;

  /// Fill the available width (true) or hug the label (false).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Color? border) = switch (variant) {
      AppButtonVariant.primary => (AppColors.primary, AppColors.surface, null),
      AppButtonVariant.outline => (
        Colors.transparent,
        AppColors.primary,
        AppColors.primary,
      ),
      AppButtonVariant.dark => (AppColors.ink, AppColors.surface, null),
      AppButtonVariant.dangerOutline => (
        Colors.transparent,
        AppColors.danger,
        AppColors.danger,
      ),
      AppButtonVariant.dangerText => (
        Colors.transparent,
        AppColors.danger,
        null,
      ),
      AppButtonVariant.text => (Colors.transparent, AppColors.primary, null),
      AppButtonVariant.surface => (AppColors.surface, AppColors.ink, null),
    };

    final isTextOnly =
        variant == AppButtonVariant.text ||
        variant == AppButtonVariant.dangerText;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(size.radius),
      side: border == null
          ? BorderSide.none
          : BorderSide(color: border, width: AppSizes.borderWidth),
    );

    final Widget content = isLoading
        ? SizedBox.square(
            dimension: AppSizes.iconMedium,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: size.textStyle.copyWith(color: foreground),
          );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height,
              minWidth: expand ? double.infinity : AppSizes.touchTarget,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTextOnly ? AppSpacing.x4 : AppSpacing.x18,
              ),
              child: Center(widthFactor: 1, heightFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
