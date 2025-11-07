import 'package:flutter/material.dart';
import '../../../shared/utils/password_validator.dart';

/// Password strength indicator widget
/// Shows visual feedback for password strength and requirements
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = PasswordValidator.getStrength(password);
    final requirements = PasswordValidator.getRequirements(password);
    final strengthLabel = PasswordValidator.getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength / 4,
                  backgroundColor: Colors.grey.shade300,
                  color: _getStrengthColor(strength),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strengthLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStrengthColor(strength),
              ),
            ),
          ],
        ),

        if (showRequirements && strength < 4) ...[
          const SizedBox(height: 12),
          // Requirements list
          ...requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      req.isMet ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: req.isMet ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      req.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: req.isMet ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
