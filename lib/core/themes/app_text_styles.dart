import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';

abstract final class AppFonts {
  /// Headings. Falls back to the platform serif-less default until the font
  /// files are added (see pubspec.yaml).
  static const String display = 'Fraunces';
  static const String body = 'DM Sans';
}

/// The type scale from the design. Screens pick a style here and, at most,
/// change its colour with copyWith.
abstract final class AppTextStyles {
  // Headings (Fraunces 600)
  static const TextStyle displayXl = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 34,
    height: 1.1,
    color: AppColors.ink,
  );
  static const TextStyle displayLg = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 1.1,
    color: AppColors.ink,
  );
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 30,
    height: 1.15,
    color: AppColors.ink,
  );
  static const TextStyle headline = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 1.15,
    color: AppColors.ink,
  );
  static const TextStyle headlineSm = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.15,
    color: AppColors.ink,
  );
  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.2,
    color: AppColors.ink,
  );
  static const TextStyle titleSm = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 1.2,
    color: AppColors.ink,
  );

  // Body (DM Sans)
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 17,
    color: AppColors.ink,
  );
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.45,
    color: AppColors.ink,
  );
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.ink,
  );
  static const TextStyle bodyMuted = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.45,
    color: AppColors.muted,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.45,
    color: AppColors.ink,
  );
  static const TextStyle bodySmStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.ink,
  );
  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors.ink,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.45,
    color: AppColors.muted,
  );
  static const TextStyle small = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.45,
    color: AppColors.muted,
  );
  static const TextStyle smallStrong = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: AppColors.ink,
  );
  static const TextStyle micro = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.ink,
  );

  /// Small caps label above a section, e.g. "ON THIS DAY".
  static const TextStyle eyebrow = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    letterSpacing: 0.96,
    color: AppColors.ochre,
  );

  // Buttons and links
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );
  static const TextStyle buttonSm = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 15,
  );
  static const TextStyle link = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.primary,
  );
}
