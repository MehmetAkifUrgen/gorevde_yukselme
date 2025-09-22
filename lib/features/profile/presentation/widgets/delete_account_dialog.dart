import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firestore_service.dart';

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

  Future<void> _deleteAccount() async {
    _logInfo('Starting account deletion process');
    
    if (!_formKey.currentState!.validate() || !_confirmDelete) {
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

      // Re-authenticate user with password
      _logInfo('Starting re-authentication process');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text,
      );

      await user.reauthenticateWithCredential(credential);
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
      
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Şifre yanlış';
          _logError('Wrong password provided during re-authentication');
          break;
        case 'requires-recent-login':
          errorMessage = 'Bu işlem için yeniden giriş yapmanız gerekiyor';
          _logError('Recent login required for account deletion');
          break;
        case 'user-not-found':
          errorMessage = 'Kullanıcı bulunamadı';
          _logError('User not found during deletion process');
          break;
        case 'network-request-failed':
          errorMessage = 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
          _logError('Network request failed during account deletion');
          break;
        case 'too-many-requests':
          errorMessage = 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
          _logError('Too many requests made to Firebase Auth');
          break;
        default:
          errorMessage = 'Hesap silme hatası: ${e.message}';
          _logError('Unhandled Firebase Auth error: ${e.code}');
      }
      _showErrorSnackBar(errorMessage);
    } catch (e, stackTrace) {
      _logError('Unexpected error during account deletion', e, stackTrace);
      _showErrorSnackBar('Beklenmeyen hata: ${e.toString()}');
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
              const Text(
                'Devam etmek için şifrenizi girin:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
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
                  if (value == null || value.isEmpty) {
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