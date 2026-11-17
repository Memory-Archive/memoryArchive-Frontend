import 'package:flutter_test/flutter_test.dart';
import 'package:smart_memories/core/validation/validators.dart';

void main() {
  group('Validators.required', () {
    final validate = Validators.required('Email');

    test('rejects null, empty and whitespace', () {
      expect(validate(null), 'Email is required.');
      expect(validate(''), 'Email is required.');
      expect(validate('   '), 'Email is required.');
    });

    test('accepts any text', () {
      expect(validate('a'), isNull);
    });

    test('uses a generic name when none is given', () {
      expect(Validators.required()(''), 'This field is required.');
    });
  });

  group('Validators.email', () {
    final validate = Validators.email();

    test('accepts valid addresses', () {
      expect(validate('sara@example.com'), isNull);
      expect(validate('  sara.h+tag@mail.example.org  '), isNull);
    });

    test('rejects invalid addresses', () {
      for (final value in <String>[
        'sara',
        'sara@',
        '@example.com',
        'sara@example',
        'sara @example.com',
        'sara@example.c',
      ]) {
        expect(validate(value), isNotNull, reason: value);
      }
    });

    test('accepts empty so it can be used on optional fields', () {
      expect(validate(''), isNull);
      expect(validate(null), isNull);
    });
  });

  group('Validators.password', () {
    final validate = Validators.password();

    test('accepts a long phrase', () {
      expect(validate('correct horse battery'), isNull);
      expect(validate('abcdefghi1'), isNull);
    });

    test('rejects fewer than 10 characters', () {
      expect(validate('short1'), 'Use at least 10 characters.');
      expect(validate('123456789'), 'Use at least 10 characters.');
    });

    test('rejects more than 128 characters', () {
      expect(validate('ab' * 65), 'Use 128 characters or fewer.');
    });

    test('rejects only numbers', () {
      expect(validate('1234567890'), contains('only numbers'));
    });

    test('rejects one repeated character', () {
      expect(validate('aaaaaaaaaaaa'), contains('repeated'));
    });

    test('rejects only spaces', () {
      expect(validate(' ' * 12), contains('only spaces'));
    });
  });

  group('passwordStrength', () {
    test('is weak when the password is not valid', () {
      expect(passwordStrength(''), PasswordStrength.weak);
      expect(passwordStrength('short'), PasswordStrength.weak);
    });

    test('is fair for a valid but plain password', () {
      expect(passwordStrength('abcdefghijk'), PasswordStrength.fair);
    });

    test('is strong for long or varied passwords', () {
      expect(passwordStrength('correct horse battery'), PasswordStrength.strong);
      expect(passwordStrength('Abcdefgh12'), PasswordStrength.strong);
    });
  });

  group('Validators.minLength and maxLength', () {
    test('minLength', () {
      final validate = Validators.minLength(3, 'Title');
      expect(validate('ab'), 'Title must be at least 3 characters.');
      expect(validate('abc'), isNull);
      expect(validate(''), isNull);
    });

    test('maxLength', () {
      final validate = Validators.maxLength(5, 'Title');
      expect(validate('abcdef'), 'Title must be 5 characters or fewer.');
      expect(validate('abcde'), isNull);
      expect(validate(null), isNull);
    });
  });

  group('Validators.name', () {
    final validate = Validators.name();

    test('accepts names in any alphabet, with hyphens and apostrophes', () {
      expect(validate('Sara Hassan'), isNull);
      expect(validate("Mary-Jane O'Neil"), isNull);
      expect(validate('سارة حسن'), isNull);
    });

    test('rejects digits, symbols and single letters', () {
      expect(validate('Sara2'), isNotNull);
      expect(validate('Sara!'), isNotNull);
      expect(validate('S'), 'Name must be at least 2 characters.');
    });

    test('rejects names over 50 characters', () {
      expect(validate('a' * 51), 'Name must be 50 characters or fewer.');
    });
  });

  group('Validators.username', () {
    final validate = Validators.username();

    test('accepts letters, numbers, dots and underscores', () {
      expect(validate('sara.h'), isNull);
      expect(validate('sara_h_99'), isNull);
    });

    test('rejects spaces, symbols and wrong lengths', () {
      expect(validate('sara h'), isNotNull);
      expect(validate('sara@h'), isNotNull);
      expect(validate('ab'), isNotNull);
      expect(validate('a' * 31), isNotNull);
    });
  });

  group('Validators.matches', () {
    test('compares with the other value at validation time', () {
      var password = 'first password';
      final validate = Validators.matches(() => password, 'No match.');

      expect(validate('first password'), isNull);
      password = 'second password';
      expect(validate('first password'), 'No match.');
    });
  });

  group('Validators.compose', () {
    final validate = Validators.compose(<Validator>[
      Validators.required('Email'),
      Validators.email(),
    ]);

    test('returns the first error', () {
      expect(validate(''), 'Email is required.');
      expect(validate('nope'), contains('valid email'));
    });

    test('returns null when every validator passes', () {
      expect(validate('sara@example.com'), isNull);
    });
  });
}
