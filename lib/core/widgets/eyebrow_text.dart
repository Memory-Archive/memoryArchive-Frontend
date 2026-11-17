import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';

/// The small upper-case ochre label above a section ("ON THIS DAY").
class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text.toUpperCase(), style: AppTextStyles.eyebrow),
    );
  }
}
