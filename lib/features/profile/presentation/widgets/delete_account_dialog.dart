import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/error_utils.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _confirmDelete = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _logInfo(String message) {
    debugPrint('[DeleteAccountDialog] INFO: $message');
  }

  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[DeleteAccountDialog] ERROR: $message');
    if (error != null) {
      debugPrint('[DeleteAccountDialog] Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('[DeleteAccountDialog] Stack trace: $stackTrace');
    }
  }

  void _logWarning(String message) {
    debugPrint('[DeleteAccountDialog] WARNING: $message');
  }

  Future<void> _reauthenticate(User user) async {
    final providerIds = user.providerData.map((e) => e.providerId).toList();
    _logInfo('User providers: $providerIds');

    if (providerIds.contains('password')) {
      final email = user.email;
      if (email == null) {
        throw Exception('E-posta bulunamadı, şifre ile yeniden doğrulama yapılamıyor');
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _passwordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (providerIds.contains('google.com')) {
      _logInfo('Starting Google re-authentication');
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google hesabı seçilmedi');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (providerIds.contains('apple.com')) {
      _logInfo('Starting Apple re-authentication');
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );
      await user.reauthenticateWithCredential(oauthCredential);
      return;
    }

    throw Exception('Desteklenmeyen sağlayıcı ile giriş yapıldı');
  }

  Future<void> _deleteAccount() async {
    _logInfo('Starting account deletion process');
    
    final currentUser = FirebaseAuth.instance.currentUser;
    final requiresPassword = currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

    if ((!requiresPassword || _formKey.currentState!.validate()) && _confirmDelete == true) {
      // proceed
    } else {
      if (!_confirmDelete) {
        _logWarning('User did not confirm account deletion');
        _showErrorSnackBar('Hesap silme işlemini onaylamanız gerekiyor');
      } else {
        _logWarning('Form validation failed');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logError('No authenticated user found');
        _showErrorSnackBar('Kullanıcı oturumu bulunamadı');
        return;
      }

      _logInfo('Current user: ${user.uid}, email: ${user.email}');

      _logInfo('Starting re-authentication process');
      await _reauthenticate(user);
      _logInfo('Re-authentication successful');

      // Delete user data from Firestore
      _logInfo('Starting Firestore data deletion');
      await _deleteUserData(user.uid);
      _logInfo('Firestore data deletion completed');

      // Delete user account
      _logInfo('Starting Firebase Auth account deletion');
      await user.delete();
      _logInfo('Firebase Auth account deletion completed');

      if (mounted) {
        _logInfo('Account deletion process completed successfully');
        Navigator.of(context).pop();
        _showSuccessSnackBar('Hesabınız başarıyla silindi');
        // Navigate to login screen or app restart
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      _logError('Firebase Auth exception occurred', e, stackTrace);
      _logError('Firebase Auth error code: ${e.code}');
      _logError('Firebase Auth error message: ${e.message}');
      
      ErrorUtils.showFirebaseAuthError(context, e);
    } catch (e, stackTrace) {
      _logError('Unexpected error during account deletion', e, stackTrace);
      ErrorUtils.showGeneralError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUserData(String userId) async {
    _logInfo('Starting Firestore data deletion for user: $userId');
    
    try {
      final firestoreService = FirestoreService();
      await firestoreService.deleteAllUserData(userId: userId);
      _logInfo('Firestore data deletion completed successfully');
    } catch (e, stackTrace) {
      _logError('Error during Firestore data deletion', e, stackTrace);
      throw Exception('Kullanıcı verileri silinirken hata oluştu: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final providerIds = user?.providerData.map((e) => e.providerId).toList() ?? [];
    final requiresPassword = providerIds.contains('password');
    final providerText = providerIds.contains('google.com')
        ? 'Google'
        : providerIds.contains('apple.com')
            ? 'Apple'
            : 'bağlı olduğunuz sağlayıcı';
    return AlertDialog(
      title: const Text(
        'Hesabı Sil',
        style: TextStyle(color: Colors.red),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu işlem geri alınamaz! Hesabınız ve tüm verileriniz kalıcı olarak silinecektir.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              requiresPassword
                  ? const Text(
                      'Devam etmek için şifrenizi girin:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )
                  : Text(
                      'Devam etmek için $providerText ile kimliğiniz doğrulanacaktır.',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
              const SizedBox(height: 8),
              if (requiresPassword)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    final user = FirebaseAuth.instance.currentUser;
                    final requiresPassword = user?.providerData.any((p) => p.providerId == 'password') ?? false;
                    if (requiresPassword && (value == null || value.isEmpty)) {
                      return 'Şifre gerekli';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _confirmDelete,
                onChanged: (value) {
                  setState(() {
                    _confirmDelete = value ?? false;
                  });
                },
                title: const Text(
                  'Hesabımı kalıcı olarak silmek istediğimi onaylıyorum',
                  style: TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Hesabı Sil'),
        ),
      ],
    );
  }
}