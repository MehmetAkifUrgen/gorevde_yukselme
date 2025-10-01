import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/utils/error_utils.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String email;
  
  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Send initial verification email after checking user status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[EmailVerificationPage] initState - Starting email verification process');
      print('[EmailVerificationPage] Email: ${widget.email}');
      _waitForUserAndSendVerification();
    });
  }

  Future<void> _waitForUserAndSendVerification() async {
    print('[EmailVerificationPage] Waiting for user authentication...');
    
    // Wait for user to be authenticated (max 10 seconds)
    int attempts = 0;
    const maxAttempts = 20; // 10 seconds with 500ms intervals
    
    while (attempts < maxAttempts) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );
      
      if (isAuthenticated) {
        print('[EmailVerificationPage] User authenticated, sending verification email');
        await _sendVerificationEmail();
        return;
      }
      
      attempts++;
      print('[EmailVerificationPage] Waiting for authentication... attempt $attempts/$maxAttempts');
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    // If user is still not authenticated after waiting, try to send verification anyway
    print('[EmailVerificationPage] User not authenticated after waiting, trying to send verification anyway');
    try {
      await _sendVerificationEmail();
    } catch (e) {
      print('[EmailVerificationPage] Failed to send verification email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Doğrulama e-postası gönderilemedi. Lütfen tekrar giriş yapın.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.go('/login?email=${Uri.encodeComponent(widget.email)}');
          }
        });
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    print('[EmailVerificationPage] _sendVerificationEmail - Starting');
    setState(() {
      _isResending = true;
    });

    try {
      print('[EmailVerificationPage] Calling authNotifierProvider.sendEmailVerification');
      await ref.read(authNotifierProvider.notifier).sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Doğrulama e-postası gönderildi! E-postanızı kontrol edin (spam klasörü dahil).'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('[EmailVerificationPage] Error in _sendVerificationEmail: $e');
      if (mounted) {
        // Firebase Auth hatası ise özel mesaj göster
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found' || e.code == 'no-user-signed-in') {
            // Navigate back to login after showing error
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                context.go('/login?email=${Uri.encodeComponent(widget.email)}');
              }
            });
          } else if (e.code == 'email-already-verified') {
            // Email already verified, show success message and navigate to home
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ E-posta zaten doğrulanmış! Ana sayfaya yönlendiriliyorsunuz...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.go('/home');
              }
            });
            return; // Don't show error message
          }
          ErrorUtils.showFirebaseAuthError(context, e);
        } else {
          // Genel hata mesajı göster
          ErrorUtils.showGeneralError(context, e);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    print('[EmailVerificationPage] _checkVerificationStatus - Starting');
    
    // Check if widget is still mounted
    if (!mounted) {
      print('[EmailVerificationPage] Widget disposed, skipping verification check');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('[EmailVerificationPage] Reloading user...');
      await ref.read(authNotifierProvider.notifier).reloadUser();
      
      // Check if widget is still mounted after async operation
      if (!mounted) {
        print('[EmailVerificationPage] Widget disposed after reload, skipping');
        return;
      }
      
      // AuthStateProvider'ı manuel olarak invalidate et
      print('[EmailVerificationPage] Invalidating authStateProvider...');
      ref.invalidate(authStateProvider);
      
      // Firebase auth state'inin güncellenmesi için bekleme
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Check if widget is still mounted after delay
      if (!mounted) {
        print('[EmailVerificationPage] Widget disposed after delay, skipping');
        return;
      }
      
      // Check verification status from both sources
      final isVerifiedFromNotifier = ref.read(authNotifierProvider.notifier).isEmailVerified;
      final authState = ref.read(authStateProvider);
      final isVerifiedFromState = authState.when(
        data: (user) => user?.emailVerified ?? false,
        loading: () => false,
        error: (_, __) => false,
      );
      
      print('[EmailVerificationPage] Email verification status - Notifier: $isVerifiedFromNotifier, State: $isVerifiedFromState');
      
      // Email verified if either source confirms it (more lenient approach)
      final isVerified = isVerifiedFromNotifier || isVerifiedFromState;
      
      if (isVerified) {
        print('[EmailVerificationPage] Email verified, showing success message');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ E-posta başarıyla doğrulandı! Ana sayfaya yönlendiriliyorsunuz...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Router'ın güncellenmesi için ekstra bekleme
          await Future.delayed(const Duration(milliseconds: 2000));
          
          if (mounted) {
            print('[EmailVerificationPage] Email verified, router will handle navigation');
            // Router redirect will handle navigation to home since email is now verified
            context.go('/home');
          }
        }
      } else {
        print('[EmailVerificationPage] Email not verified yet');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📧 E-posta henüz doğrulanmamış. Lütfen e-postanızdaki bağlantıya tıklayın.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('[EmailVerificationPage] Error in _checkVerificationStatus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
                
                // Verification Container
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
                      // Email Icon
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: AppTheme.primaryNavyBlue,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'E-posta Doğrulama',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primaryNavyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Hesabınızı doğrulamak için ${widget.email} adresine bir doğrulama e-postası gönderdik.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'E-postanızdaki bağlantıya tıkladıktan sonra "Doğrulamayı Kontrol Et" butonuna basın.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Check Verification Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _checkVerificationStatus,
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
                            : const Text('Doğrulamayı Kontrol Et'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Resend Email Button
                      OutlinedButton(
                        onPressed: _isResending ? null : _sendVerificationEmail,
                        child: _isResending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryNavyBlue,
                                  ),
                                ),
                              )
                            : const Text('E-postayı Tekrar Gönder'),
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
                              '• Spam/Junk/Gereksiz klasörünüzü kontrol edin\n• E-posta adresinizin doğru olduğundan emin olun\n• Birkaç dakika bekleyip tekrar deneyin\n• İnternet bağlantınızı kontrol edin\n• E-posta sağlayıcınızın güvenlik ayarlarını kontrol edin\n• Gmail kullanıyorsanız "Sosyal" veya "Promosyon" sekmelerini kontrol edin',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    );
  }
}