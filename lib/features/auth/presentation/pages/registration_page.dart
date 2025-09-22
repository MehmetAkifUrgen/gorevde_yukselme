import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../widgets/password_strength_indicator.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    print('[RegistrationPage] _handleRegistration - Starting');
    if (!_formKey.currentState!.validate()) {
      print('[RegistrationPage] Form validation failed');
      return;
    }
    
    if (!_acceptTerms) {
      print('[RegistrationPage] Terms not accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanım koşullarını kabul etmelisiniz'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    print('[RegistrationPage] Starting registration process');
    setState(() {
      _isLoading = true;
    });

    try {
      print('[RegistrationPage] Creating user with email and password');
      
      // Store email for navigation before async call
      final email = _emailController.text.trim();
      
      // Check if widget is still mounted before async operation
      if (!mounted) {
        print('[RegistrationPage] Widget disposed before user creation');
        return;
      }
      
      // Directly create user without email check to avoid auth state conflicts
      await ref.read(authNotifierProvider.notifier).createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      print('[RegistrationPage] User created successfully');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Wait a moment for auth state to stabilize
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          // Navigate to email verification page
          final emailVerificationUrl = '${AppRouter.emailVerification}?email=${Uri.encodeComponent(email)}';
          print('[RegistrationPage] Navigating to email verification: $emailVerificationUrl');
          
          // Use pushReplacement instead of go to avoid back navigation issues
          context.pushReplacement(emailVerificationUrl);
        }
      } else {
        print('[RegistrationPage] Widget disposed after user creation, cannot navigate');
      }
    } catch (e) {
      print('[RegistrationPage] Error in registration: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Kayıt sırasında bir hata oluştu';
        
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'Bu e-posta adresi zaten kullanımda. Giriş yapmayı deneyin veya şifre sıfırlama kullanın.';
          
          // Show dialog for existing email
          _showEmailAlreadyInUseDialog();
          return;
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Şifre çok zayıf';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Geçersiz e-posta adresi';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go(AppRouter.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Google ile giriş sırasında bir hata oluştu';
        
        if (e.toString().contains('network-request-failed')) {
          errorMessage = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin';
        } else if (e.toString().contains('sign_in_canceled')) {
          errorMessage = 'Google giriş işlemi iptal edildi';
        } else if (e.toString().contains('sign_in_failed')) {
          errorMessage = 'Google girişi başarısız oldu';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primaryNavyBlue,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // App Logo/Title
                  Text(
                    'ExamPrep',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.secondaryWhite,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Registration Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Hesap Oluştur',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Ad Soyad',
                            hintText: 'Adınızı ve soyadınızı girin',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                          validator: ValidationUtils.validateFullName,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            hintText: 'ornek@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: ValidationUtils.validateEmail,
                        ),
                        
                      
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            hintText: 'Güçlü bir şifre oluşturun',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: ValidationUtils.validatePassword,
                        ),
                        
                        // Password Strength Indicator
                        if (_passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          PasswordStrengthIndicator(password: _passwordController.text),
                          const SizedBox(height: 8),
                          PasswordRequirementsWidget(password: _passwordController.text),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Şifre Tekrar',
                            hintText: 'Şifrenizi tekrar girin',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) => ValidationUtils.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryNavyBlue,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptTerms = !_acceptTerms;
                                  });
                                },
                                child: Text(
                                  'Kullanım koşullarını ve gizlilik politikasını kabul ediyorum',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegistration,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.secondaryWhite,
                                    ),
                                  ),
                                )
                              : const Text('Hesap Oluştur'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'veya',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.darkGrey,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Google Sign Up Button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignUp,
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Google ile Kayıt Ol'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryWhite,
                            foregroundColor: AppTheme.primaryNavyBlue,
                            side: const BorderSide(color: AppTheme.mediumGrey),
                          ),
                        ),
                        

                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten hesabınız var mı? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryNavyBlue,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRouter.login);
                        },
                        child: Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showEmailAlreadyInUseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.accentGold,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('E-posta Zaten Kayıtlı'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bu e-posta adresi (${_emailController.text.trim()}) zaten sistemde kayıtlı.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Yeni kayıt oluşturmak yerine mevcut hesabınızla giriş yapabilirsiniz.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear the email field to prevent confusion
                _emailController.clear();
              },
              child: const Text('Farklı E-posta Kullan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login with the email pre-filled
                context.go('${AppRouter.login}?email=${Uri.encodeComponent(_emailController.text.trim())}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavyBlue,
              ),
              child: const Text('Giriş Yap'),
            ),
          ],
        );
      },
    );
  }
}