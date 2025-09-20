import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _sessionKey = 'user_session';
  static const String _sessionExpiryKey = 'session_expiry';
  static const int _sessionDurationHours = 24 * 30; // 30 gün

  final SharedPreferences _prefs;

  SessionService(this._prefs);

  // Oturum bilgilerini kaydet
  Future<void> saveSession(String userId, String email) async {
    final sessionData = {
      'userId': userId,
      'email': email,
      'loginTime': DateTime.now().toIso8601String(),
    };
    
    await _prefs.setString(_sessionKey, _encodeSessionData(sessionData));
    
    // Oturum son kullanma tarihini ayarla (30 gün)
    final expiryDate = DateTime.now().add(const Duration(hours: _sessionDurationHours));
    await _prefs.setString(_sessionExpiryKey, expiryDate.toIso8601String());
  }

  // Kayıtlı oturumu getir
  Map<String, dynamic>? getSession() {
    final sessionString = _prefs.getString(_sessionKey);
    final expiryString = _prefs.getString(_sessionExpiryKey);
    
    if (sessionString == null || expiryString == null) {
      return null;
    }
    
    // Oturum süresi dolmuş mu kontrol et
    final expiryDate = DateTime.parse(expiryString);
    if (DateTime.now().isAfter(expiryDate)) {
      clearSession();
      return null;
    }
    
    return _decodeSessionData(sessionString);
  }

  // Oturumu temizle
  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_sessionExpiryKey);
  }

  // Oturumun geçerli olup olmadığını kontrol et
  bool hasValidSession() {
    return getSession() != null;
  }

  // Oturum verilerini encode et
  String _encodeSessionData(Map<String, dynamic> data) {
    return '${data['userId']}|${data['email']}|${data['loginTime']}';
  }

  // Oturum verilerini decode et
  Map<String, dynamic> _decodeSessionData(String data) {
    final parts = data.split('|');
    if (parts.length != 3) {
      return {};
    }
    
    return {
      'userId': parts[0],
      'email': parts[1],
      'loginTime': parts[2],
    };
  }
}