import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_colors.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';

/// The three tilted photo prints at the top of the login screen.
/// Decorative only, so it is hidden from screen readers.
class PolaroidStack extends StatelessWidget {
  const PolaroidStack({super.key});

  static const double _height = 190;
  static const double _width = 334;

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Center(
        child: SizedBox(
          width: _width,
          height: _height,
          child: Stack(
            children: <Widget>[
              _Print(left: 14, top: 26, width: 120, height: 140, degrees: -7, tint: 0),
              _Print(left: 106, top: 4, width: 128, height: 150, degrees: 3, tint: 1),
              _Print(left: 208, top: 34, width: 116, height: 136, degrees: 9, tint: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Print extends StatelessWidget {
  const _Print({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.degrees,
    required this.tint,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double degrees;
  final int tint;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x8,
            AppSpacing.x8,
            AppSpacing.x8,
            AppSpacing.x28,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.line,
              width: AppSizes.borderWidth,
            ),
          ),
          child: ColoredBox(
            color: AppColors.photoTint(tint),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
