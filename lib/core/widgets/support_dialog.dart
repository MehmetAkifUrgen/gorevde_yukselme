import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user_model.dart';
import '../models/support_request.dart';

class SupportDialog extends ConsumerStatefulWidget {
  final User userProfile;

  const SupportDialog({
    super.key,
    required this.userProfile,
  });

  @override
  ConsumerState<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends ConsumerState<SupportDialog> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _logInfo(String message) {
    debugPrint('[SupportDialog] INFO: $message');
  }

  void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[SupportDialog] ERROR: $message');
    if (error != null) {
      debugPrint('[SupportDialog] Error details: $error');
    }
    if (stackTrace != null) {
      debugPrint('[SupportDialog] Stack trace: $stackTrace');
    }
  }

  void _logWarning(String message) {
    debugPrint('[SupportDialog] WARNING: $message');
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) {
      _logWarning('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _logInfo('Starting support request submission');
      
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _logError('No authenticated user found');
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      _logInfo('Current user: ${currentUser.uid}, email: ${currentUser.email}');

      final supportRequest = SupportRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        userEmail: currentUser.email ?? '',
        userName: widget.userProfile.name,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
        status: 'pending',
      );

      _logInfo('Support request created: ${supportRequest.toMap()}');

      final firestore = FirebaseFirestore.instance;
      _logInfo('Attempting to write to Firestore...');

      await firestore
          .collection('support_requests')
          .doc(supportRequest.id)
          .set(supportRequest.toMap());

      _logInfo('Support request successfully saved to Firestore');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Destek talebiniz başarıyla gönderildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logError('Failed to submit support request', e, stackTrace);
      
      String errorMessage = 'Destek talebi gönderilirken bir hata oluştu.';
      
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'İzin hatası: Destek talebi göndermek için yetkiniz yok. Lütfen tekrar giriş yapmayı deneyin.';
        _logError('Permission denied error detected');
      } else if (e.toString().contains('network')) {
        errorMessage = 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
        _logError('Network error detected');
      } else if (e.toString().contains('unavailable')) {
        errorMessage = 'Sunucu şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
        _logError('Service unavailable error detected');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
    _logInfo('Building SupportDialog widget');
    
    return AlertDialog(
      title: const Text('Destek Talebi'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Konu',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Konu boş olamaz';
                }
                if (value.trim().length < 3) {
                  return 'Konu en az 3 karakter olmalıdır';
                }
                return null;
              },
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Mesaj',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mesaj boş olamaz';
                }
                if (value.trim().length < 10) {
                  return 'Mesaj en az 10 karakter olmalıdır';
                }
                return null;
              },
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            _logInfo('Cancel button pressed');
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSupportRequest,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gönder'),
        ),
      ],
    );
  }
}