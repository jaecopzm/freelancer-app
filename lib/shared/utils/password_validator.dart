/// Password validation utility
/// Provides comprehensive password strength checking
class PasswordValidator {
  /// Minimum password length
  static const int minLength = 8;

  /// Validate password strength
  /// Returns null if valid, error message if invalid
  static String? validate(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    // Check for uppercase letters
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letters
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for digits
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for special characters
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]'))) {
      return 'Password must contain at least one special character (!@#\$%^&*...)';
    }

    return null;
  }

  /// Get password strength level (0-4)
  /// 0 = Very Weak, 1 = Weak, 2 = Fair, 3 = Good, 4 = Strong
  static int getStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety checks
    if (password.contains(RegExp(r'[A-Z]')) && 
        password.contains(RegExp(r'[a-z]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]'))) {
      strength++;
    }

    return strength > 4 ? 4 : strength;
  }

  /// Get password strength label
  static String getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }

  /// Get password requirements list
  static List<PasswordRequirement> getRequirements(String password) {
    return [
      PasswordRequirement(
        label: 'At least $minLength characters',
        isMet: password.length >= minLength,
      ),
      PasswordRequirement(
        label: 'One uppercase letter',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        label: 'One lowercase letter',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        label: 'One number',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      PasswordRequirement(
        label: 'One special character',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]')),
      ),
    ];
  }
}

/// Password requirement model
class PasswordRequirement {
  final String label;
  final bool isMet;

  const PasswordRequirement({
    required this.label,
    required this.isMet,
  });
}
