import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../../core/models/user_model.dart';
import '../../../../core/models/support_request.dart';
import '../../../../core/utils/error_utils.dart';

class ProfileReportDialog extends ConsumerStatefulWidget {
  final User userProfile;
  final FirebaseFirestore? firestore;
  final auth.FirebaseAuth? authInstance;

  const ProfileReportDialog({
    super.key,
    required this.userProfile,
    this.firestore,
    this.authInstance,
  });

  @override
  ConsumerState<ProfileReportDialog> createState() => _ProfileReportDialogState();
}

class _ProfileReportDialogState extends ConsumerState<ProfileReportDialog> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authInst = widget.authInstance ?? auth.FirebaseAuth.instance;
      final currentUser = authInst.currentUser;
      if (currentUser == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final userEmail = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : (currentUser.email ?? '');

      final supportRequest = SupportRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        userEmail: userEmail,
        userName: widget.userProfile.name,
        subject: 'Kullanıcı Bildirimi',
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
        status: 'pending',
      );

      final firestore = widget.firestore ?? FirebaseFirestore.instance;
      await firestore
          .collection('support_requests')
          .doc(supportRequest.id)
          .set(supportRequest.toMap());

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildiriminiz gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorUtils.showFirestoreError(context, e);
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
    return AlertDialog(
      title: const Text('Bildir'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                if (value.trim().length < 5) {
                  return 'Mesaj en az 5 karakter olmalıdır';
                }
                return null;
              },
              maxLength: 500,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta (opsiyonel)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Gönder'),
        ),
      ],
    );
  }
}
