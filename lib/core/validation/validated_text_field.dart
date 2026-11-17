import 'package:flutter/material.dart';
import 'package:smart_memories/core/validation/validators.dart';
import 'package:smart_memories/core/widgets/app_text_field.dart';

/// An [AppTextField] wired to a list of [Validators]. Must sit inside a Form.
///
///   ValidatedTextField(
///     label: 'Email',
///     controller: _email,
///     validators: [Validators.required('Email'), Validators.email()],
///     serverError: error?.messageFor('email'),
///   )
///
/// [serverError] shows a message that came back from the backend for this
/// field (the "errors" array), below the field like a local validation error.
class ValidatedTextField extends StatelessWidget {
  const ValidatedTextField({
    super.key,
    required this.label,
    required this.validators,
    this.controller,
    this.hint,
    this.helper,
    this.serverError,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
    this.onFieldSubmitted,
  });

  final String label;
  final List<Validator> validators;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? serverError;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint,
      helper: helper,
      errorText: serverError,
      validator: Validators.compose(validators),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      maxLines: maxLines,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
