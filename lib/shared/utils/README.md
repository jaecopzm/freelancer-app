# Shared Utilities

## Password Validator

The `PasswordValidator` class provides comprehensive password strength validation for the authentication system.

### Password Requirements

All passwords must meet the following criteria:
- **Minimum length**: 8 characters
- **Uppercase letter**: At least one (A-Z)
- **Lowercase letter**: At least one (a-z)
- **Number**: At least one (0-9)
- **Special character**: At least one (!@#$%^&*(),.?":{}|<>_-+=[]\/;`~)

### Usage

```dart
import 'package:freelance_companion/shared/utils/password_validator.dart';

// Validate password
String? error = PasswordValidator.validate('MyPassword123!');
if (error != null) {
  print('Password invalid: $error');
}

// Get password strength (0-4)
int strength = PasswordValidator.getStrength('MyPassword123!');
String label = PasswordValidator.getStrengthLabel(strength);

// Get requirements status
List<PasswordRequirement> requirements = PasswordValidator.getRequirements('test');
for (var req in requirements) {
  print('${req.label}: ${req.isMet ? "✓" : "✗"}');
}
```

### Strength Levels

- **0-1**: Very Weak (red)
- **2**: Weak (orange)
- **3**: Fair (amber)
- **4+**: Good/Strong (green)

### UI Integration

Use the `PasswordStrengthIndicator` widget to show real-time feedback:

```dart
PasswordStrengthIndicator(
  password: passwordController.text,
  showRequirements: true,
)
```
