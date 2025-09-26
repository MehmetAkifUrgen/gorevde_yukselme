import 'package:firebase_auth/firebase_auth.dart';

/// Merkezi hata mesajları servisi - Tüm hataları Türkçe'ye çevirir
class ErrorMessageService {
  static const ErrorMessageService _instance = ErrorMessageService._internal();
  factory ErrorMessageService() => _instance;
  const ErrorMessageService._internal();

  /// Firebase Auth hatalarını Türkçe'ye çevirir
  String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      // Giriş hataları
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Şifre yanlış';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu anda devre dışı';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalıdır';
      
      // Kayıt hataları
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda. Giriş yapmayı deneyin veya şifre sıfırlama kullanın';
      case 'invalid-verification-code':
        return 'Geçersiz doğrulama kodu';
      case 'invalid-verification-id':
        return 'Geçersiz doğrulama kimliği';
      case 'code-expired':
        return 'Doğrulama kodu süresi dolmuş';
      
      // Şifre sıfırlama hataları
      case 'expired-action-code':
        return 'Şifre sıfırlama bağlantısının süresi dolmuş';
      case 'invalid-action-code':
        return 'Geçersiz şifre sıfırlama bağlantısı';
      
      // Hesap silme hataları
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor';
      
      // Google Sign-In hataları
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir giriş yöntemi ile kayıtlı';
      case 'credential-already-in-use':
        return 'Bu hesap zaten başka bir kullanıcı tarafından kullanılıyor';
      
      // Genel hatalar
      case 'user-mismatch':
        return 'Kullanıcı uyumsuzluğu';
      case 'user-token-expired':
        return 'Oturum süresi dolmuş. Lütfen tekrar giriş yapın';
      case 'invalid-user-token':
        return 'Geçersiz kullanıcı oturumu';
      
      default:
        return 'Beklenmeyen bir hata oluştu: ${e.message ?? 'Bilinmeyen hata'}';
    }
  }

  /// Genel hata mesajlarını Türkçe'ye çevirir
  String getGeneralErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin';
    } else if (errorString.contains('timeout')) {
      return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin';
    } else if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return 'Bu işlem için yetkiniz yok';
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return 'İstenen kaynak bulunamadı';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin';
    } else if (errorString.contains('unavailable') || errorString.contains('503')) {
      return 'Sunucu şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin';
    } else if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return 'İşlem iptal edildi';
    } else if (errorString.contains('invalid') || errorString.contains('malformed')) {
      return 'Geçersiz veri formatı';
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return 'Günlük kullanım limitiniz doldu. Lütfen yarın tekrar deneyin';
    } else {
      return 'Beklenmeyen bir hata oluştu';
    }
  }

  /// Firestore hatalarını Türkçe'ye çevirir
  String getFirestoreErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission-denied')) {
      return 'Bu işlem için yetkiniz yok. Lütfen tekrar giriş yapmayı deneyin';
    } else if (errorString.contains('unavailable')) {
      return 'Veritabanı şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin';
    } else if (errorString.contains('deadline-exceeded')) {
      return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin';
    } else if (errorString.contains('not-found')) {
      return 'İstenen veri bulunamadı';
    } else if (errorString.contains('already-exists')) {
      return 'Bu veri zaten mevcut';
    } else if (errorString.contains('failed-precondition')) {
      return 'İşlem ön koşulları karşılanmadı';
    } else if (errorString.contains('out-of-range')) {
      return 'Geçersiz veri aralığı';
    } else if (errorString.contains('unimplemented')) {
      return 'Bu özellik henüz desteklenmiyor';
    } else if (errorString.contains('internal')) {
      return 'Sunucu iç hatası. Lütfen daha sonra tekrar deneyin';
    } else if (errorString.contains('resource-exhausted')) {
      return 'Kaynak limiti aşıldı. Lütfen daha sonra tekrar deneyin';
    } else {
      return getGeneralErrorMessage(error);
    }
  }

  /// Subscription/Purchase hatalarını Türkçe'ye çevirir
  String getSubscriptionErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user_cancelled') || errorString.contains('cancelled')) {
      return 'Satın alma işlemi iptal edildi';
    } else if (errorString.contains('item_already_owned')) {
      return 'Bu ürün zaten satın alınmış';
    } else if (errorString.contains('item_unavailable')) {
      return 'Bu ürün şu anda mevcut değil';
    } else if (errorString.contains('billing_unavailable')) {
      return 'Ödeme sistemi şu anda kullanılamıyor';
    } else if (errorString.contains('developer_error')) {
      return 'Geliştirici hatası. Lütfen uygulamayı güncelleyin';
    } else if (errorString.contains('service_unavailable')) {
      return 'Mağaza servisi şu anda kullanılamıyor';
    } else if (errorString.contains('service_disconnected')) {
      return 'Mağaza bağlantısı kesildi';
    } else if (errorString.contains('service_timeout')) {
      return 'Mağaza bağlantısı zaman aşımına uğradı';
    } else if (errorString.contains('feature_not_supported')) {
      return 'Bu özellik bu cihazda desteklenmiyor';
    } else if (errorString.contains('network_error')) {
      return 'İnternet bağlantınızı kontrol edin';
    } else {
      return 'Satın alma işlemi başarısız oldu';
    }
  }

  /// Validation hatalarını Türkçe'ye çevirir
  String getValidationErrorMessage(String field, String error) {
    switch (error.toLowerCase()) {
      case 'required':
        return '$field alanı zorunludur';
      case 'invalid_email':
        return 'Geçerli bir e-posta adresi girin';
      case 'weak_password':
        return 'Şifre en az 6 karakter olmalıdır';
      case 'password_mismatch':
        return 'Şifreler eşleşmiyor';
      case 'too_short':
        return '$field çok kısa';
      case 'too_long':
        return '$field çok uzun';
      case 'invalid_format':
        return '$field geçersiz formatta';
      default:
        return '$field geçersiz';
    }
  }

  /// API hatalarını Türkçe'ye çevirir
  String getApiErrorMessage(int statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek. Lütfen verilerinizi kontrol edin';
      case 401:
        return 'Yetkisiz erişim. Lütfen tekrar giriş yapın';
      case 403:
        return 'Bu işlem için yetkiniz yok';
      case 404:
        return 'İstenen kaynak bulunamadı';
      case 408:
        return 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin';
      case 429:
        return 'Çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin';
      case 500:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin';
      case 502:
        return 'Sunucu geçici olarak kullanılamıyor';
      case 503:
        return 'Sunucu bakımda. Lütfen daha sonra tekrar deneyin';
      case 504:
        return 'Sunucu yanıt vermiyor. Lütfen tekrar deneyin';
      default:
        return message ?? 'Bilinmeyen bir hata oluştu';
    }
  }
}
