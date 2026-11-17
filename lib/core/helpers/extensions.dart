import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  /// Shows a short message at the bottom of the screen, replacing any
  /// message that is already showing.
  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

extension StringX on String {
  /// "Sara Hassan" -> "SH", "sara.h" -> "S".
  String get initials {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final letters = parts.take(2).map((p) => p[0].toUpperCase());
    return letters.join();
  }

  /// "Sara Hassan" -> "Sara".
  String get firstWord {
    final trimmed = trim();
    final index = trimmed.indexOf(' ');
    return index == -1 ? trimmed : trimmed.substring(0, index);
  }
}
