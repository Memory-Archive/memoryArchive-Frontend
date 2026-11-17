/// A validator returns an error message, or null when the value is fine.
/// The signature matches TextFormField.validator.
typedef Validator = String? Function(String? value);

/// Reusable validators. Every validator except [required] accepts an empty
/// value, so "optional but must be valid if filled in" needs no extra code.
/// Combine them with [compose]:
///
///   Validators.compose([Validators.required('Email'), Validators.email()])
abstract final class Validators {
  static const int passwordMinLength = 10;
  static const int passwordMaxLength = 128;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9._]+$');
  static final RegExp _namePattern = RegExp(
    r"^\p{L}[\p{L}\p{M} '\-]*$",
    unicode: true,
  );
  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _oneRepeatedCharacter = RegExp(r'^(.)\1+$');

  static Validator required([String fieldName = 'This field']) {
    return (value) =>
        value == null || value.trim().isEmpty ? '$fieldName is required.' : null;
  }

  static Validator email() {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      final valid = text.length <= 254 && _emailPattern.hasMatch(text);
      return valid ? null : 'Enter a valid email address, like you@example.com.';
    };
  }

  /// Length first (a long phrase is the best password), then the two most
  /// common weak patterns. Matches the helper text on the sign-up screen.
  static Validator password() {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (text.length < passwordMinLength) {
        return 'Use at least $passwordMinLength characters.';
      }
      if (text.length > passwordMaxLength) {
        return 'Use $passwordMaxLength characters or fewer.';
      }
      if (text.trim().isEmpty) return 'A password cannot be only spaces.';
      if (_digitsOnly.hasMatch(text)) {
        return 'Add some letters. A password cannot be only numbers.';
      }
      if (_oneRepeatedCharacter.hasMatch(text)) {
        return 'Use more than one repeated character.';
      }
      return null;
    };
  }

  static Validator minLength(int min, [String fieldName = 'This field']) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      return text.length < min
          ? '$fieldName must be at least $min characters.'
          : null;
    };
  }

  static Validator maxLength(int max, [String fieldName = 'This field']) {
    return (value) {
      final text = value?.trim() ?? '';
      return text.length > max
          ? '$fieldName must be $max characters or fewer.'
          : null;
    };
  }

  /// A person's name: letters from any alphabet, spaces, hyphens, apostrophes.
  static Validator name([String fieldName = 'Name']) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (text.length < 2) return '$fieldName must be at least 2 characters.';
      if (text.length > 50) return '$fieldName must be 50 characters or fewer.';
      return _namePattern.hasMatch(text)
          ? null
          : '$fieldName can only contain letters, spaces, hyphens and apostrophes.';
    };
  }

  static Validator username() {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      final valid =
          text.length >= 3 &&
          text.length <= 30 &&
          _usernamePattern.hasMatch(text);
      return valid
          ? null
          : 'Use 3 to 30 letters, numbers, dots or underscores.';
    };
  }

  /// Passes when the value equals [other] (read at validation time).
  static Validator matches(String Function() other, String message) {
    return (value) => (value ?? '') == other() ? null : message;
  }

  /// Runs validators in order and returns the first error.
  static Validator compose(List<Validator> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

enum PasswordStrength { weak, fair, strong }

/// A rough strength score for a future strength meter. Not a validator.
PasswordStrength passwordStrength(String value) {
  if (Validators.password()(value) != null || value.isEmpty) {
    return PasswordStrength.weak;
  }
  var variety = 0;
  if (RegExp('[a-z]').hasMatch(value)) variety++;
  if (RegExp('[A-Z]').hasMatch(value)) variety++;
  if (RegExp(r'\d').hasMatch(value)) variety++;
  if (RegExp(r'[^a-zA-Z\d]').hasMatch(value)) variety++;
  if (value.length >= 16 || variety >= 3) return PasswordStrength.strong;
  return PasswordStrength.fair;
}
