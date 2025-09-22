import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gorevde_yukselme/core/providers/auth_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validation_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String email;
  
  const LoginPage({
    super.key,
    this.email = '',
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided from route
    if (widget.email.isNotEmpty) {
      _emailController.text = widget.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    print('[LoginPage] Attempting login with email: ${_emailController.text.trim()}');
    
    await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // AuthNotifier state'ini kontrol et
    final authState = ref.read(authNotifierProvider);
    
    print('[LoginPage] Auth state after login attempt: ${authState.toString()}');
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      authState.when(
        data: (user) {
          print('[LoginPage] Login successful, user: ${user?.email}');
          if (user != null) {
            context.go(AppRouter.home);
          } else {
            print('[LoginPage] User is null despite successful login');
          }
        },
        loading: () {
          print('[LoginPage] Auth state is still loading');
        },
        error: (error, stackTrace) {
          print('[LoginPage] Login error: $error');
          String errorMessage = 'Giriş sırasında bir hata oluştu';
          
          if (error.toString().contains('user-not-found')) {
            errorMessage = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
          } else if (error.toString().contains('wrong-password')) {
            errorMessage = 'Şifre yanlış';
          } else if (error.toString().contains('invalid-email')) {
            errorMessage = 'Geçersiz e-posta adresi';
          } else if (error.toString().contains('user-disabled')) {
            errorMessage = 'Bu hesap devre dışı bırakılmış';
          } else if (error.toString().contains('too-many-requests')) {
            errorMessage = 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin';
          } else if (error.toString().contains('network-request-failed')) {
            errorMessage = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin';
          } else if (error.toString().contains('invalid-credential')) {
            errorMessage = 'E-posta veya şifre hatalı';
          }
          
          print('[LoginPage] Showing error message: $errorMessage');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        },
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
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
                  const SizedBox(height: 60),
                  
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
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Görevde Yükselme Sınavı Hazırlık',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryWhite.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Form Container
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
                          'Giriş Yap',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
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
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            hintText: 'Şifrenizi girin',
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
                        
                        const SizedBox(height: 24),
                        
                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                              : const Text('Giriş Yap'),
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
                        
                        // Google Sign In Button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Google ile Giriş Yap'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryWhite,
                            foregroundColor: AppTheme.primaryNavyBlue,
                            side: const BorderSide(color: AppTheme.mediumGrey),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Forgot Password Link
                        TextButton(
                          onPressed: () {
                            context.push(AppRouter.forgotPassword);
                          },
                          child: Text(
                            'Şifremi Unuttum?',
                            style: TextStyle(
                              color: AppTheme.accentGold.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryNavyBlue,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRouter.registration);
                        },
                        child: Text(
                          'Hesap Oluştur',
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
}