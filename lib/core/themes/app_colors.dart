import 'package:flutter/material.dart';

/// Every colour in the design. Screens and widgets use these names and never
/// a raw hex value.
abstract final class AppColors {
  // Grounds
  static const Color paper = Color(0xFFF6EFE3); // page background
  static const Color surface = Color(0xFFFFFAF1); // cards, fields, nav bar

  // Lines
  static const Color line = Color(0xFFE3D6C2); // card borders, dividers
  static const Color fieldBorder = Color(0xFFC9B89F); // inputs, outlined chips
  static const Color dashedBorder = Color(0xFF8E7B63); // "add" tiles

  // Text
  static const Color ink = Color(0xFF2B2118);
  static const Color muted = Color(0xFF6B5B4B);

  // Brand
  static const Color primary = Color(0xFF2F5D50);
  static const Color primaryDark = Color(0xFF1F4238);
  static const Color primaryTint = Color(0xFFDCE6DF);
  static const Color ochre = Color(0xFF8A4F12); // eyebrow labels

  // Feedback
  static const Color danger = Color(0xFFA23B2A);

  /// Flat tints shown where a photo has not loaded or does not exist yet.
  static const List<Color> photoTints = <Color>[
    Color(0xFFC9D3C3), // sage
    Color(0xFFE2B8A0), // peach
    Color(0xFFD9C3A5), // sand
    Color(0xFFBFCBD6), // dusty blue
  ];

  static Color photoTint(int index) => photoTints[index % photoTints.length];
}
