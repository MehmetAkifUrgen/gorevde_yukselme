import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/error_message_service.dart';

/// Hata mesajlarını gösteren utility sınıfı
class ErrorUtils {
  static final ErrorMessageService _errorService = ErrorMessageService();

  /// Firebase Auth hatasını gösterir
  static void showFirebaseAuthError(BuildContext context, FirebaseAuthException e) {
    final message = _errorService.getFirebaseAuthErrorMessage(e);
    _showErrorSnackBar(context, message);
  }

  /// Genel hatayı gösterir
  static void showGeneralError(BuildContext context, dynamic error) {
    final message = _errorService.getGeneralErrorMessage(error);
    _showErrorSnackBar(context, message);
  }

  /// Firestore hatasını gösterir
  static void showFirestoreError(BuildContext context, dynamic error) {
    final message = _errorService.getFirestoreErrorMessage(error);
    _showErrorSnackBar(context, message);
  }

  /// Subscription hatasını gösterir
  static void showSubscriptionError(BuildContext context, dynamic error) {
    final message = _errorService.getSubscriptionErrorMessage(error);
    _showErrorSnackBar(context, message);
  }

  /// Validation hatasını gösterir
  static void showValidationError(BuildContext context, String field, String error) {
    final message = _errorService.getValidationErrorMessage(field, error);
    _showErrorSnackBar(context, message);
  }

  /// API hatasını gösterir
  static void showApiError(BuildContext context, int statusCode, String? message) {
    final errorMessage = _errorService.getApiErrorMessage(statusCode, message);
    _showErrorSnackBar(context, errorMessage);
  }

  /// Başarı mesajını gösterir
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Bilgi mesajını gösterir
  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Uyarı mesajını gösterir
  static void showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Hata SnackBar'ını gösterir
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Hata dialog'unu gösterir
  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Onay dialog'unu gösterir
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}
