import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gorevde_yukselme/features/auth/presentation/pages/login_page.dart';
import 'package:gorevde_yukselme/features/auth/presentation/pages/registration_page.dart';
import 'package:gorevde_yukselme/core/utils/validation_utils.dart';

void main() {
  group('Authentication Flow Tests', () {
    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginPage(),
          ),
        ),
      );

      // Verify login page elements
      expect(find.text('ExamPrep'), findsOneWidget);
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsAtLeastNWidgets(1));
    });

    testWidgets('Registration page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegistrationPage(),
          ),
        ),
      );

      // Verify registration page elements
      expect(find.text('Ad Soyad'), findsOneWidget);
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Şifre'), findsAtLeastNWidgets(1));
      expect(find.text('Şifre Tekrar'), findsOneWidget);
      expect(find.text('Meslek'), findsOneWidget);
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginPage(),
          ),
        ),
      );

      // Find the login button and tap it without filling the form
      final loginButton = find.text('Giriş Yap').last;
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation errors appear
      expect(find.text('E-posta adresi gerekli'), findsOneWidget);
      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('Registration form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegistrationPage(),
          ),
        ),
      );

      // Find the registration button and tap it without filling the form
      final registerButton = find.text('Kayıt Ol').last;
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Verify validation errors appear
      expect(find.text('Ad soyad gerekli'), findsOneWidget);
      expect(find.text('E-posta adresi gerekli'), findsOneWidget);
      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('Password strength indicator appears on registration', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegistrationPage(),
          ),
        ),
      );

      // Find password field and enter a password
      final passwordField = find.byType(TextFormField).at(2);
      await tester.enterText(passwordField, 'TestPassword123!');
      await tester.pumpAndSettle();

      // Verify password strength indicator appears
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Güçlü'), findsOneWidget);
    });

    testWidgets('Email validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const LoginPage(),
          ),
        ),
      );

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      // Trigger validation by tapping login button
      final loginButton = find.text('Giriş Yap').last;
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify email validation error
      expect(find.text('Geçerli bir e-posta adresi girin'), findsOneWidget);
    });

    testWidgets('Password confirmation validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegistrationPage(),
          ),
        ),
      );

      // Fill form with mismatched passwords
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'TestPassword123!');
      await tester.enterText(find.byType(TextFormField).at(3), 'DifferentPassword123!');

      // Trigger validation
      final registerButton = find.text('Kayıt Ol').last;
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Verify password mismatch error
      expect(find.text('Şifreler eşleşmiyor'), findsOneWidget);
    });
  });

  group('ValidationUtils Tests', () {
    test('validateEmail returns correct results', () {
      expect(ValidationUtils.validateEmail(''), 'E-posta adresi gerekli');
      expect(ValidationUtils.validateEmail('invalid'), 'Geçerli bir e-posta adresi girin');
      expect(ValidationUtils.validateEmail('test@example.com'), null);
    });

    test('validatePassword returns correct results', () {
      expect(ValidationUtils.validatePassword(''), 'Şifre gerekli');
      expect(ValidationUtils.validatePassword('123'), contains('en az'));
      expect(ValidationUtils.validatePassword('TestPassword123!'), null);
    });

    test('validateFullName returns correct results', () {
      expect(ValidationUtils.validateFullName(''), 'Ad soyad gerekli');
      expect(ValidationUtils.validateFullName('Test'), 'Lütfen ad ve soyadınızı girin');
      expect(ValidationUtils.validateFullName('Test User'), null);
    });

    test('validateConfirmPassword returns correct results', () {
      expect(ValidationUtils.validateConfirmPassword('', 'password'), 'Şifre tekrarı gerekli');
      expect(ValidationUtils.validateConfirmPassword('different', 'password'), 'Şifreler eşleşmiyor');
      expect(ValidationUtils.validateConfirmPassword('password', 'password'), null);
    });

    test('getPasswordStrength returns correct strength levels', () {
      expect(ValidationUtils.getPasswordStrength('123'), 1); // Weak
      expect(ValidationUtils.getPasswordStrength('TestPassword'), 3); // Good
      expect(ValidationUtils.getPasswordStrength('TestPassword123!'), 4); // Strong
    });
  });
}