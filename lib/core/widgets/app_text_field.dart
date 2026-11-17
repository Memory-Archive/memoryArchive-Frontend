import 'package:flutter/material.dart';
import 'package:smart_memories/core/themes/app_spacing.dart';
import 'package:smart_memories/core/themes/app_text_styles.dart';

/// A text field with its label above it, as in the design. Borders, fill and
/// height come from the theme (core/themes/app_theme.dart).
///
/// For a field with validation rules use ValidatedTextField, which wraps this.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// A muted line under the field, e.g. password advice.
  final String? helper;

  /// An error that did not come from [validator], e.g. from the server.
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int maxLines;

  /// Read-only fields open a picker through [onTap] (date, time).
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: AppTextStyles.label),
        AppGap.v6,
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            maxLines: obscureText ? 1 : maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onFieldSubmitted: onFieldSubmitted,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppTextStyles.body,
            decoration: InputDecoration(hintText: hint, errorText: errorText),
          ),
        ),
        if (helper != null) ...<Widget>[
          AppGap.v6,
          Text(helper!, style: AppTextStyles.small),
        ],
      ],
    );
  }
}
