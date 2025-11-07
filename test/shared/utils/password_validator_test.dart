import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_companion/shared/utils/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('rejects empty password', () {
      expect(PasswordValidator.validate(''), isNotNull);
    });

    test('rejects password shorter than 8 characters', () {
      expect(PasswordValidator.validate('Abc123!'), isNotNull);
    });

    test('rejects password without uppercase letter', () {
      expect(PasswordValidator.validate('abcd1234!'), isNotNull);
    });

    test('rejects password without lowercase letter', () {
      expect(PasswordValidator.validate('ABCD1234!'), isNotNull);
    });

    test('rejects password without number', () {
      expect(PasswordValidator.validate('Abcdefgh!'), isNotNull);
    });

    test('rejects password without special character', () {
      expect(PasswordValidator.validate('Abcd1234'), isNotNull);
    });

    test('accepts strong password', () {
      expect(PasswordValidator.validate('MyPass123!'), isNull);
      expect(PasswordValidator.validate('Secure@2024'), isNull);
      expect(PasswordValidator.validate('Test#Password1'), isNull);
    });

    test('calculates password strength correctly', () {
      expect(PasswordValidator.getStrength(''), equals(0));
      expect(PasswordValidator.getStrength('weak'), lessThan(3));
      expect(PasswordValidator.getStrength('MyPass123!'), greaterThanOrEqualTo(4));
    });

    test('returns correct strength labels', () {
      expect(PasswordValidator.getStrengthLabel(0), equals('Very Weak'));
      expect(PasswordValidator.getStrengthLabel(1), equals('Very Weak'));
      expect(PasswordValidator.getStrengthLabel(2), equals('Weak'));
      expect(PasswordValidator.getStrengthLabel(3), equals('Fair'));
      expect(PasswordValidator.getStrengthLabel(4), equals('Good'));
      expect(PasswordValidator.getStrengthLabel(5), equals('Strong'));
    });

    test('tracks requirements correctly', () {
      final requirements = PasswordValidator.getRequirements('MyPass123!');
      expect(requirements.length, equals(5));
      expect(requirements.every((r) => r.isMet), isTrue);

      final weakRequirements = PasswordValidator.getRequirements('weak');
      expect(weakRequirements.any((r) => !r.isMet), isTrue);
    });
  });
}
