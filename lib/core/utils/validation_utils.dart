/// Utility class for form validation
class ValidationUtils {
  // Private constructor to prevent instantiation
  ValidationUtils._();

  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Strong password regex pattern
  static final RegExp _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$',
  );

  /// Name validation regex pattern (letters, spaces, and common name characters)
  static final RegExp _nameRegex = RegExp(
    r"^[a-zA-ZğüşıöçĞÜŞİÖÇ\s\-\.']+$",
  );

  /// Validates email address
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }

    final trimmedValue = value.trim();
    
    if (trimmedValue.isEmpty) {
      return 'E-posta adresi gerekli';
    }

    if (trimmedValue.length > 254) {
      return 'E-posta adresi çok uzun';
    }

    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    // Check for consecutive dots
    if (trimmedValue.contains('..')) {
      return 'Geçerli bir e-posta adresi girin';
    }

    // Check if starts or ends with dot
    if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.')) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  /// Validates password with different strength levels
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value, {bool requireStrong = false}) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }

    if (value.length > 128) {
      return 'Şifre çok uzun (maksimum 128 karakter)';
    }

    // Check for common weak passwords
    final commonPasswords = [
      '123456',
      'password',
      '123456789',
      '12345678',
      '12345',
      '1234567',
      'qwerty',
      'abc123',
      'password123',
      'admin',
      'letmein',
    ];

    if (commonPasswords.contains(value.toLowerCase())) {
      return 'Bu şifre çok yaygın kullanılıyor, daha güvenli bir şifre seçin';
    }

    if (requireStrong) {
      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Şifre en az bir küçük harf içermeli';
      }

      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Şifre en az bir büyük harf içermeli';
      }

      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Şifre en az bir rakam içermeli';
      }

      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Şifre en az bir özel karakter içermeli (!@#\$%^&*(),.?":{}|<>)';
      }

      if (value.length < 8) {
        return 'Güçlü şifre en az 8 karakter olmalı';
      }
    }

    return null;
  }

  /// Validates password confirmation
  /// Returns null if valid, error message if invalid
  static String? validatePasswordConfirmation(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }

    if (value != originalPassword) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != originalPassword) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  /// Validates full name (first name + last name)
  /// Returns null if valid, error message if invalid
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad gerekli';
    }

    final trimmedValue = value.trim();
    
    if (trimmedValue.isEmpty) {
      return 'Ad soyad gerekli';
    }

    if (trimmedValue.length < 2) {
      return 'Ad soyad en az 2 karakter olmalı';
    }

    if (trimmedValue.length > 100) {
      return 'Ad soyad çok uzun (maksimum 100 karakter)';
    }

    if (!_nameRegex.hasMatch(trimmedValue)) {
      return 'Ad soyad sadece harf, boşluk ve yaygın karakterler içerebilir';
    }

    // Check if contains at least first name and last name
    final nameParts = trimmedValue.split(RegExp(r'\s+'));
    if (nameParts.length < 2) {
      return 'Lütfen ad ve soyadınızı girin';
    }

    // Check if each part has at least 1 character
    for (final part in nameParts) {
      if (part.isEmpty) {
        return 'Geçerli bir ad soyad girin';
      }
    }

    return null;
  }

  /// Validates required field
  /// Returns null if valid, error message if invalid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Validates phone number (Turkish format)
  /// Returns null if valid, error message if invalid
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional in most cases
    }

    final trimmedValue = value.trim();
    
    // Remove common formatting characters
    final cleanedValue = trimmedValue.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Turkish phone number patterns
    final turkishMobileRegex = RegExp(r'^(90)?5[0-9]{9}$');
    
    if (!turkishMobileRegex.hasMatch(cleanedValue)) {
      return 'Geçerli bir telefon numarası girin (örn: 5XX XXX XX XX)';
    }

    return null;
  }

  /// Gets password strength score (0-4)
  /// 0: Very weak, 1: Weak, 2: Fair, 3: Good, 4: Strong
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Penalty for common patterns
    if (password.toLowerCase().contains('password') ||
        password.contains('123') ||
        password.contains('abc')) {
      score = (score - 1).clamp(0, 4);
    }

    return score.clamp(0, 4);
  }

  /// Gets password strength description
  static String getPasswordStrengthDescription(int strength) {
    switch (strength) {
      case 0:
        return 'Çok zayıf';
      case 1:
        return 'Zayıf';
      case 2:
        return 'Orta';
      case 3:
        return 'İyi';
      case 4:
        return 'Güçlü';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Gets password strength color
  static int getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 0xFFE53E3E; // Red
      case 2:
        return 0xFFDD6B20; // Orange
      case 3:
        return 0xFF38A169; // Green
      case 4:
        return 0xFF00A86B; // Dark Green
      default:
        return 0xFF718096; // Gray
    }
  }
}