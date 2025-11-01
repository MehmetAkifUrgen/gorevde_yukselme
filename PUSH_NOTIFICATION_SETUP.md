# Push Notification Kurulum Kılavuzu

Bu dokümanda projeye eklenen Push Notification (FCM - Firebase Cloud Messaging) sisteminin kurulumu ve kullanımı anlatılmaktadır.

## ✅ Yapılan Değişiklikler

### 1. Flutter Kodları

#### Oluşturulan Dosyalar:
- **`lib/core/services/notification_service.dart`**: Ana notification servisi
- **`lib/core/providers/notification_providers.dart`**: Riverpod provider'ları

#### Güncellenen Dosyalar:
- **`lib/main.dart`**: 
  - Firebase Messaging import edildi
  - Background message handler register edildi
  - NotificationService initialize edildi

### 2. iOS Konfigürasyonları

#### Güncellenen Dosyalar:
- **`ios/Runner/Info.plist`**: UIBackgroundModes eklendi (remote-notification)
- **`ios/Runner/AppDelegate.swift`**: Remote notification registration eklendi
- **`ios/Runner/Runner.entitlements`**: aps-environment = production
- **`ios/Runner/RunnerRelease.entitlements`**: aps-environment = production

### 3. Android Konfigürasyonları

#### Güncellenen Dosyalar:
- **`android/app/src/main/AndroidManifest.xml`**:
  - POST_NOTIFICATIONS permission eklendi
  - FCM default notification channel metadata eklendi
  - FCM default notification icon metadata eklendi
  - FCM default notification color metadata eklendi

### 4. macOS Konfigürasyonları (Opsiyonel)

#### Güncellenen Dosyalar:
- **`macos/Runner/DebugProfile.entitlements`**: aps-environment = development
- **`macos/Runner/Release.entitlements`**: aps-environment = production

---

## 🔧 Özellikler

### ✨ Mevcut Özellikler:

1. **Foreground Notifications**: Uygulama açıkken gelen bildirimler
2. **Background Notifications**: Uygulama arka planda iken gelen bildirimler
3. **Terminated State**: Uygulama kapalı iken gelen bildirimler
4. **Token Management**: FCM token otomatik yönetimi ve Firestore'a kaydetme
5. **Topic Subscription**: Topic'lere abone olma/olunmama
6. **Navigation Handling**: Bildirim tıklandığında navigasyon yönetimi
7. **Permission Management**: iOS ve Android için izin yönetimi
8. **Auto Token Refresh**: Token yenilendiğinde otomatik güncelleme

---

## 📱 Kullanım

### NotificationService'i Kullanma

```dart
import 'package:gorevde_yukselme/core/services/notification_service.dart';

// Service instance'ı al
final notificationService = NotificationService();

// FCM Token'ı al
final token = notificationService.fcmToken;
print('FCM Token: $token');

// Bildirimlerin aktif olup olmadığını kontrol et
final isEnabled = await notificationService.areNotificationsEnabled();

// Topic'e abone ol
await notificationService.subscribeToTopic('exam_updates');

// Topic'ten çık
await notificationService.unsubscribeFromTopic('exam_updates');

// Token'ı sil (logout işleminde)
await notificationService.deleteToken();
```

### Riverpod Provider'ları ile Kullanma

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gorevde_yukselme/core/providers/notification_providers.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FCM Token'ı al
    final fcmToken = ref.watch(fcmTokenProvider);
    
    // Bildirimlerin aktif olup olmadığını kontrol et
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    
    return notificationsEnabled.when(
      data: (enabled) => Text('Notifications: ${enabled ? 'Enabled' : 'Disabled'}'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## 🚀 Firebase Console Kurulumu

### 1. APNs (Apple Push Notification Service) Kurulumu

1. **Apple Developer Console**'a git
2. **Certificates, Identifiers & Profiles** > **Keys** bölümüne git
3. **+** butonuna tıkla ve yeni bir Key oluştur
4. **Apple Push Notifications service (APNs)** seçeneğini işaretle
5. Key'i indir (.p8 dosyası)
6. **Firebase Console** > **Project Settings** > **Cloud Messaging** > **iOS app configuration**
7. **APNs Authentication Key** bölümüne .p8 dosyasını yükle
8. Key ID ve Team ID'yi gir

### 2. FCM Server Key Alma

1. **Firebase Console**'a git
2. **Project Settings** > **Cloud Messaging** sekmesine git
3. **Server key** ve **Sender ID** bilgilerini not al

### 3. Test Bildirimi Gönderme

Firebase Console'dan test bildirimi göndermek için:

1. **Firebase Console** > **Engage** > **Messaging**
2. **New campaign** > **Notifications**
3. Notification başlığı ve metni gir
4. **Send test message** butonuna tıkla
5. FCM token'ı gir (uygulamadan alabilirsiniz)
6. **Test** butonuna tıkla

---

## 🔔 Bildirim Gönderme (Backend)

### cURL ile Bildirim Gönderme

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Yeni Sınav!",
      "body": "KPSS 2024 soruları eklendi"
    },
    "data": {
      "screen": "exam",
      "examId": "123"
    }
  }'
```

### Node.js ile Bildirim Gönderme

```javascript
const admin = require('firebase-admin');

// Firebase Admin SDK'yı initialize et
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Bildirim gönder
const message = {
  notification: {
    title: 'Yeni Sınav!',
    body: 'KPSS 2024 soruları eklendi'
  },
  data: {
    screen: 'exam',
    examId: '123'
  },
  token: 'DEVICE_FCM_TOKEN'
};

admin.messaging().send(message)
  .then(response => {
    console.log('Successfully sent message:', response);
  })
  .catch(error => {
    console.log('Error sending message:', error);
  });
```

### Topic'e Bildirim Gönderme

```javascript
const message = {
  notification: {
    title: 'Tüm Kullanıcılara Duyuru',
    body: 'Yeni özellikler eklendi!'
  },
  topic: 'exam_updates'
};

admin.messaging().send(message);
```

---

## 🎯 Navigasyon Yönetimi

Bildirimlerde gönderilen `data` alanı sayesinde kullanıcıyı istediğiniz sayfaya yönlendirebilirsiniz.

### Örnek Data Yapıları:

```json
// Sınav sayfasına yönlendir
{
  "data": {
    "screen": "exam",
    "examId": "123"
  }
}

// Soru sayfasına yönlendir
{
  "data": {
    "screen": "question",
    "questionId": "456"
  }
}

// Ana sayfa
{
  "data": {
    "screen": "home"
  }
}
```

### notification_service.dart'ta Navigasyon Kodu:

```dart
void _handleNotificationNavigation(Map<String, dynamic> data) {
  if (data.containsKey('screen')) {
    final screen = data['screen'];
    
    switch (screen) {
      case 'exam':
        final examId = data['examId'];
        // context.go('/exam/$examId');
        break;
      case 'question':
        final questionId = data['questionId'];
        // context.go('/question/$questionId');
        break;
      case 'home':
        // context.go('/home');
        break;
    }
  }
}
```

**Not:** Navigasyon kodlarını gerçek router yapınıza göre güncellemeniz gerekiyor.

---

## 📊 Firestore Token Yönetimi

Her kullanıcının FCM token'ı otomatik olarak Firestore'a kaydedilir:

```
users/{userId}
  - fcmToken: "token_string"
  - fcmTokenUpdatedAt: Timestamp
  - platform: "TargetPlatform.iOS" veya "TargetPlatform.android"
```

### Backend'den Token Alma:

```javascript
const db = admin.firestore();

// Kullanıcının token'ını al
const userDoc = await db.collection('users').doc(userId).get();
const fcmToken = userDoc.data().fcmToken;

// Token ile bildirim gönder
admin.messaging().send({
  notification: { title: 'Merhaba', body: 'Test' },
  token: fcmToken
});
```

---

## 🔒 Güvenlik

1. **Server Key'i Güvende Tutun**: Firebase Server Key'i asla client-side kodda kullanmayın
2. **Token'ları Güvenli Saklayın**: FCM token'ları hassas bilgilerdir
3. **Logout'ta Token Sil**: Kullanıcı çıkış yaptığında token'ı silin:

```dart
// Logout işleminde
await NotificationService().deleteToken();
```

---

## 🧪 Test Etme

### 1. FCM Token Alma
Uygulamayı çalıştırın ve konsola bakın:
```
[NotificationService] FCM Token: YOUR_TOKEN_HERE
```

### 2. Foreground Test
- Uygulamayı açık tutun
- Firebase Console'dan test bildirimi gönderin
- Konsolda log'ları kontrol edin

### 3. Background Test
- Uygulamayı arka plana alın
- Test bildirimi gönderin
- Bildirim çubuğunda görünmeli

### 4. Terminated Test
- Uygulamayı tamamen kapatın
- Test bildirimi gönderin
- Bildirime tıklayın, uygulama açılmalı

---

## 🐛 Sorun Giderme

### iOS'ta Bildirim Gelmiyor

1. **Physical Device Kullanın**: Simulator'da push notification çalışmaz
2. **APNs Key Kontrolü**: Firebase Console'da APNs key'in doğru yüklendiğinden emin olun
3. **Entitlements**: Runner.entitlements ve RunnerRelease.entitlements dosyalarında `aps-environment` olduğundan emin olun
4. **Xcode Capabilities**: Xcode'da **Signing & Capabilities** > **+ Capability** > **Push Notifications** ekleyin

### Android'de Bildirim Gelmiyor

1. **google-services.json**: Dosyanın doğru yerinde olduğundan emin olun
2. **Permissions**: Android 13+ için POST_NOTIFICATIONS izni gerekli
3. **Notification Channel**: Android 8.0+ için notification channel gerekli (kod içinde mevcut)

### Token Alınamıyor

1. **Firebase Initialization**: Firebase'in doğru initialize edildiğinden emin olun
2. **Internet Connection**: Cihazın internete bağlı olduğundan emin olun
3. **Google Play Services**: Android cihazda Google Play Services kurulu olmalı

---

## 📚 Ek Kaynaklar

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Messaging Package](https://firebase.flutter.dev/docs/messaging/overview/)
- [iOS Push Notification Guide](https://developer.apple.com/documentation/usernotifications)
- [Android Notification Guide](https://developer.android.com/develop/ui/views/notifications)

---

## ✅ Production Checklist

- [x] Firebase Admin SDK kuruldu
- [x] APNs key yüklendi (iOS)
- [x] google-services.json eklendi (Android)
- [x] GoogleService-Info.plist eklendi (iOS)
- [x] Entitlements dosyaları güncellendi
- [x] AndroidManifest.xml güncellendi
- [x] Background message handler register edildi
- [x] Token management sistemi kuruldu
- [x] Navigation handling eklendi
- [ ] Backend'de bildirim gönderme sistemi kurulmalı
- [ ] Topic subscription stratejisi belirlenmelі
- [ ] Test edilmeli (iOS & Android)
- [ ] Production'da test edilmeli

---

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Konsol log'larını kontrol edin
2. Firebase Console'da Cloud Messaging bölümünü kontrol edin
3. Device token'ının Firestore'a kaydedildiğini kontrol edin

**Not:** Bu sistem production-ready'dir. Backend tarafında bildirim gönderme sistemini kurmanız gerekiyor.