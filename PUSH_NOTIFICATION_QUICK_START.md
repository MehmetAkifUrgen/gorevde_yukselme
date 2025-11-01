# 🚀 Push Notification Hızlı Başlangıç

## ⚡ 5 Dakikada Çalıştır

### 1️⃣ iOS - Xcode Ayarları (ZORUNLU)

1. **Xcode'u Aç**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Push Notifications Capability Ekle**
   - Sol panelden **Runner** projesini seç
   - **Signing & Capabilities** sekmesine tıkla
   - **+ Capability** butonuna tıkla
   - **Push Notifications** seçeneğini bul ve ekle
   
3. **Background Modes Ekle** (Otomatik olmalı, kontrol edin)
   - Yine **+ Capability** > **Background Modes**
   - Şu seçenekleri işaretle:
     - ✅ Remote notifications
     - ✅ Background fetch

### 2️⃣ Firebase Console - APNs Key Yükle

1. **Apple Developer Console**'a Git
   - https://developer.apple.com/account/
   - **Certificates, Identifiers & Profiles** > **Keys**
   - **+** butonuna tıkla

2. **APNs Key Oluştur**
   - Key Name: `FCM Push Notification Key`
   - ✅ Apple Push Notifications service (APNs) seçeneğini işaretle
   - **Continue** > **Register** > **Download**
   - ⚠️ **Key ID** ve **Team ID**'yi not al

3. **Firebase Console'a Yükle**
   - https://console.firebase.google.com/
   - Project Settings > Cloud Messaging > iOS app configuration
   - **APNs Authentication Key** > Upload
   - .p8 dosyasını yükle
   - Key ID ve Team ID'yi gir
   - **Upload**

### 3️⃣ Test Et

#### Terminal'de Çalıştır:
```bash
flutter clean
flutter pub get
flutter run
```

#### Konsola Dikkat Et:
```
[Main] Starting Notification Service initialization...
[NotificationService] Initializing...
[NotificationService] FCM Token: YOUR_TOKEN_HERE
[Main] Notification Service initialized successfully
```

#### FCM Token'ı Kopyala
Konsoldaki token'ı kopyala, test için kullanacaksın.

### 4️⃣ Firebase Console'dan Test Bildirimi Gönder

1. **Firebase Console** > **Engage** > **Messaging**
2. **New campaign** > **Notifications**
3. **Notification text** bölümünü doldur:
   - Title: `Test Bildirimi`
   - Text: `Sistem çalışıyor! 🎉`
4. **Send test message** butonuna tıkla
5. FCM token'ı yapıştır (adım 3'ten)
6. **Test** butonuna tıkla

#### ✅ Başarılı Test:
- **Foreground**: Konsolda log görünür
- **Background**: Bildirim çubuğunda görünür
- **Terminated**: Bildirim gelir, tıklayınca uygulama açılır

---

## 🔥 Örnek Kullanım Kodları

### Basit Kullanım

```dart
import 'package:gorevde_yukselme/core/services/notification_service.dart';

// Token'ı al
final notificationService = NotificationService();
final token = notificationService.fcmToken;
print('Token: $token');

// Topic'e abone ol
await notificationService.subscribeToTopic('exam_updates');

// Topic'ten çık
await notificationService.unsubscribeFromTopic('exam_updates');
```

### Riverpod ile Kullanım

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gorevde_yukselme/core/providers/notification_providers.dart';

class NotificationSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final fcmToken = ref.watch(fcmTokenProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Bildirim Ayarları')),
      body: Column(
        children: [
          notificationsEnabled.when(
            data: (enabled) => SwitchListTile(
              title: Text('Bildirimler'),
              subtitle: Text(enabled ? 'Aktif' : 'Kapalı'),
              value: enabled,
              onChanged: null, // Ayarlar uygulamasına yönlendirin
            ),
            loading: () => CircularProgressIndicator(),
            error: (e, s) => Text('Hata: $e'),
          ),
          ListTile(
            title: Text('FCM Token'),
            subtitle: Text(fcmToken ?? 'Yükleniyor...'),
          ),
        ],
      ),
    );
  }
}
```

---

## 📤 Backend'den Bildirim Gönderme

### cURL ile

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Yeni Sınav Eklendi",
      "body": "KPSS 2024 soruları hazır!"
    },
    "data": {
      "screen": "exam",
      "examId": "123"
    }
  }'
```

### Node.js ile

```javascript
const admin = require('firebase-admin');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Tekil bildirim
const message = {
  notification: {
    title: 'Yeni Sınav Eklendi',
    body: 'KPSS 2024 soruları hazır!'
  },
  data: {
    screen: 'exam',
    examId: '123'
  },
  token: 'DEVICE_FCM_TOKEN'
};

admin.messaging().send(message);

// Topic'e bildirim
admin.messaging().send({
  notification: { title: 'Duyuru', body: 'Yeni özellikler!' },
  topic: 'exam_updates'
});
```

### Python ile

```python
from firebase_admin import messaging, credentials, initialize_app

# Initialize
cred = credentials.Certificate('serviceAccountKey.json')
initialize_app(cred)

# Bildirim gönder
message = messaging.Message(
    notification=messaging.Notification(
        title='Yeni Sınav Eklendi',
        body='KPSS 2024 soruları hazır!'
    ),
    data={
        'screen': 'exam',
        'examId': '123'
    },
    token='DEVICE_FCM_TOKEN'
)

response = messaging.send(message)
print('Successfully sent message:', response)
```

---

## 🎯 Topic Strategy (Önerilen)

### Kullanıcı Login Olduğunda:

```dart
// User role'üne göre topic'lere abone ol
final user = FirebaseAuth.instance.currentUser;
final notificationService = NotificationService();

if (user != null) {
  // Tüm kullanıcılar için
  await notificationService.subscribeToTopic('all_users');
  
  // Premium kullanıcılar için
  if (isPremium) {
    await notificationService.subscribeToTopic('premium_users');
  }
  
  // Sınav türüne göre
  await notificationService.subscribeToTopic('kpss_exams');
  await notificationService.subscribeToTopic('ales_exams');
}
```

### Kullanıcı Logout Olduğunda:

```dart
// Auth service içinde zaten otomatik yapılıyor
await authService.signOut(); // Token otomatik silinir
```

---

## ⚠️ Önemli Notlar

### iOS için:
- ✅ **Physical Device** kullanın (Simulator'da push notification çalışmaz)
- ✅ **APNs Key** mutlaka yüklenmiş olmalı
- ✅ **Bundle ID** Firebase'de kayıtlı olmalı
- ✅ **Xcode'da Push Notifications capability** eklenmiş olmalı

### Android için:
- ✅ **google-services.json** doğru yerde olmalı (`android/app/`)
- ✅ **Google Play Services** cihazda kurulu olmalı
- ✅ **Android 13+** için POST_NOTIFICATIONS izni gerekli

### Production için:
- ⚠️ **Server Key'i** asla client-side kodda tutmayın
- ⚠️ **Token'ları** güvenli saklayın (Firestore'da şifrelenmeli)
- ⚠️ **Rate limiting** uygulayın (spam'i önlemek için)
- ⚠️ **Analytics** ekleyin (bildirim açılma oranlarını takip edin)

---

## 🐛 Sorun mu var?

### iOS'ta bildirim gelmiyor:
```bash
# Temiz build yapın
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Android'de bildirim gelmiyor:
```bash
# Gradle cache temizle
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### Token alınamıyor:
```dart
// Manuel olarak kontrol edin
final token = await FirebaseMessaging.instance.getToken();
print('Manual token: $token');
```

---

## 📞 Yardım

Detaylı bilgi için: [PUSH_NOTIFICATION_SETUP.md](./PUSH_NOTIFICATION_SETUP.md)

**Sistem production-ready durumda!** 🎉