import 'package:flutter/material.dart';
import 'package:gorevde_yukselme/core/utils/validation_utils.dart';

/// Widget that displays password strength with visual indicators
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showText;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = ValidationUtils.getPasswordStrength(password);
    final description = ValidationUtils.getPasswordStrengthDescription(strength);
    final color = Color(ValidationUtils.getPasswordStrengthColor(strength));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: index < strength ? color : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        
        if (showText && password.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Şifre gücü: $description',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget that displays password requirements checklist
class PasswordRequirementsWidget extends StatelessWidget {
  final String password;
  final bool requireStrong;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
    this.requireStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!requireStrong) return const SizedBox.shrink();

    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Şifre gereksinimleri:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('En az 8 karakter', hasMinLength),
          _buildRequirement('Küçük harf (a-z)', hasLowercase),
          _buildRequirement('Büyük harf (A-Z)', hasUppercase),
          _buildRequirement('Rakam (0-9)', hasDigit),
          _buildRequirement('Özel karakter (!@#\$%^&*)', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}