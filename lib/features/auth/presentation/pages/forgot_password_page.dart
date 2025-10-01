import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/utils/error_utils.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        // Firebase Auth hatası ise özel mesaj göster
        if (e is FirebaseAuthException) {
          ErrorUtils.showFirebaseAuthError(context, e);
        } else {
          // Genel hata mesajı göster
          ErrorUtils.showGeneralError(context, e);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryNavyBlue,
              AppTheme.secondaryWhite,
            ],
          ),
        ),
        child: SafeArea(
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
                    'Kamu Sınavlarına Hazırlık',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.secondaryWhite,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Forgot Password Container
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
                    child: _emailSent ? _buildSuccessView() : _buildFormView(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Giriş sayfasına dönmek ister misiniz? ',
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
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lock Icon
        const Icon(
          Icons.lock_reset_outlined,
          size: 80,
          color: AppTheme.primaryNavyBlue,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Şifremi Unuttum',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryNavyBlue,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.darkGrey,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
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
        
        const SizedBox(height: 24),
        
        // Send Reset Email Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handlePasswordReset,
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
              : const Text('Şifre Sıfırlama Bağlantısı Gönder'),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: Colors.green,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'E-posta Gönderildi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryNavyBlue,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Şifre sıfırlama bağlantısı ${_emailController.text} adresine gönderildi.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.darkGrey,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'E-postanızdaki bağlantıya tıklayarak yeni şifrenizi oluşturabilirsiniz.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Resend Button
        OutlinedButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('Tekrar Gönder'),
        ),
        
        const SizedBox(height: 24),
        
        // Help Text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryNavyBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'E-posta gelmedi mi?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavyBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Spam/Junk klasörünüzü kontrol edin\n• E-posta adresinizin doğru olduğundan emin olun\n• Birkaç dakika bekleyip tekrar deneyin',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}