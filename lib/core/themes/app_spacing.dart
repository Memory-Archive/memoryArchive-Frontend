import 'package:flutter/widgets.dart';

/// The spacing scale from the design, named by its pixel value.
abstract final class AppSpacing {
  static const double x2 = 2;
  static const double x4 = 4;
  static const double x6 = 6;
  static const double x8 = 8;
  static const double x10 = 10;
  static const double x12 = 12;
  static const double x14 = 14;
  static const double x16 = 16;
  static const double x18 = 18;
  static const double x22 = 22;
  static const double x24 = 24;
  static const double x28 = 28;

  /// Horizontal page padding on app screens.
  static const double page = x24;

  /// Horizontal page padding on the auth screens.
  static const double authPage = x28;
}

/// Ready-made gaps for Column (v) and Row (h) children.
abstract final class AppGap {
  static const SizedBox v2 = SizedBox(height: AppSpacing.x2);
  static const SizedBox v4 = SizedBox(height: AppSpacing.x4);
  static const SizedBox v6 = SizedBox(height: AppSpacing.x6);
  static const SizedBox v8 = SizedBox(height: AppSpacing.x8);
  static const SizedBox v10 = SizedBox(height: AppSpacing.x10);
  static const SizedBox v12 = SizedBox(height: AppSpacing.x12);
  static const SizedBox v16 = SizedBox(height: AppSpacing.x16);
  static const SizedBox v18 = SizedBox(height: AppSpacing.x18);
  static const SizedBox v22 = SizedBox(height: AppSpacing.x22);
  static const SizedBox v24 = SizedBox(height: AppSpacing.x24);
  static const SizedBox v28 = SizedBox(height: AppSpacing.x28);

  static const SizedBox h4 = SizedBox(width: AppSpacing.x4);
  static const SizedBox h8 = SizedBox(width: AppSpacing.x8);
  static const SizedBox h10 = SizedBox(width: AppSpacing.x10);
  static const SizedBox h12 = SizedBox(width: AppSpacing.x12);
  static const SizedBox h14 = SizedBox(width: AppSpacing.x14);
  static const SizedBox h16 = SizedBox(width: AppSpacing.x16);
}

/// Corner radii from the design.
abstract final class AppRadii {
  static const double album = 6; // the "photo album" cards
  static const double thumb = 8;
  static const double tile = 10;
  static const double field = 12;
  static const double card = 14;
  static const double chip = 18;
  static const double pill = 999;
}

/// Fixed component sizes from the design.
abstract final class AppSizes {
  static const double touchTarget = 44;
  static const double field = 50;
  static const double buttonLarge = 52;
  static const double buttonMedium = 48;
  static const double chip = 36;
  static const double listRow = 54;

  static const double navBar = 76;
  static const double navItem = 56;
  static const double navAddButton = 54;

  static const double iconSmall = 18;
  static const double iconMedium = 22;
  static const double iconLarge = 24;

  static const double avatarLarge = 72;
  static const double thumbnail = 64;
  static const double photoTile = 76;
  static const double detailThumb = 72;
  static const double homeCover = 128;
  static const double detailCover = 320;

  static const double borderWidth = 1;
  static const double progressBarWidth = 48;
  static const double progressBarHeight = 5;
}
