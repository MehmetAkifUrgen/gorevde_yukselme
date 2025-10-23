# Mağaza Ayarları Kılavuzu 📱

Bu kılavuz, uygulamanızı Google Play Store ve Apple App Store'a yayınlamak için gerekli ayarları içerir.

## 📋 İçindekiler
1. [Google Play Store Ayarları](#google-play-store-ayarları)
2. [Apple App Store Ayarları](#apple-app-store-ayarları)
3. [Premium Kod Sistemi](#premium-kod-sistemi)
4. [Test Kodları](#test-kodları)
5. [Sorun Giderme](#sorun-giderme)

---

## 🟢 Google Play Store Ayarları

### 1. Uygulama Bilgileri
- **Uygulama Adı**: Görevde Yükselme
- **Paket Adı**: `com.gorevdeyukselme.app`
- **Sürüm**: 1.0.0
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)

### 2. İç Uygulama Satın Alma Ayarları
Google Play Console'da şu adımları takip edin:

1. **Play Console** → **Uygulamanız** → **Monetize** → **Products** → **Subscriptions**
2. **Create subscription** butonuna tıklayın
3. Şu ürünleri oluşturun:

#### Aylık Premium
- **Product ID**: `gorevde_yukselme_monthly`
- **Name**: Aylık Premium Üyelik
- **Description**: Sınırsız soru çözme, reklamsız deneyim ve premium özellikler
- **Price**: Mağaza tarafından belirlenir (Google Play Console'da ayarlayın)
- **Billing period**: 1 month
- **Grace period**: 3 days
- **Free trial**: 7 days (opsiyonel)

#### 3 Aylık Premium
- **Product ID**: `gorevde_yukselme_quarterly`
- **Name**: 3 Aylık Premium Üyelik
- **Description**: En iyi tasarruf ile premium özellikler
- **Price**: Mağaza tarafından belirlenir (Google Play Console'da ayarlayın)
- **Billing period**: 3 months
- **Grace period**: 5 days
- **Free trial**: 7 days (opsiyonel)

### 3. Google Play Console Ayarları
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="com.android.vending.BILLING" />
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXX~XXXXXXXXXX"/>
```

### 4. Test Hesapları
Google Play Console'da test hesapları ekleyin:
- **License testing**: Test hesapları için
- **Internal testing**: Geliştirici testleri için
- **Closed testing**: Beta testleri için

---

## 🍎 Apple App Store Ayarları

### 1. App Store Connect Ayarları
App Store Connect'te şu adımları takip edin:

1. **App Store Connect** → **My Apps** → **Uygulamanız**
2. **Features** → **In-App Purchases** → **Auto-Renewable Subscriptions**
3. **Create** butonuna tıklayın

#### Subscription Group Oluşturma
- **Reference Name**: Premium Subscription
- **App Store Display Name**: Premium Üyelik

#### Aylık Premium
 - **Product ID**: `com.gyudsoft.apps.monthly`
- **Reference Name**: Monthly Premium
- **Subscription Duration**: 1 Month
- **Price**: Mağaza tarafından belirlenir (App Store Connect'te ayarlayın)
- **Free Trial**: 7 days (opsiyonel)


### 2. iOS Info.plist Ayarları
```xml
<!-- ios/Runner/Info.plist -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXX~XXXXXXXXXX</string>
```

### 3. Test Hesapları
App Store Connect'te:
- **Users and Access** → **Sandbox Testers**
- Test hesapları oluşturun
- Test cihazlarında bu hesaplarla giriş yapın

---

## 🎁 Premium Kod Sistemi

### Kod Formatları
Uygulama şu kod formatlarını destekler:

#### Resmi Kodlar
- `GYUD-MONTHLY-XXXX` - Aylık Premium (30 gün)
- `GYUD-QUARTERLY-XXXX` - 3 Aylık Premium (90 gün)

#### Promosyon Kodları
- `PROMO-XXXX` - Promosyon kodları (genellikle aylık)

#### Hediye Kodları
- `GIFT-XXXX` - Hediye kodları (genellikle 3 aylık)

#### Test Kodları (Sadece Debug Modunda)
- `TEST-XXXX` - Test kodları

### Kod Örnekleri
```
GYUD-MONTHLY-ABC123
GYUD-QUARTERLY-XYZ789
PROMO-SUMMER2024
GIFT-NEWYEAR2024
TEST-DEVELOPER
```

### Kod Kullanımı
1. Kullanıcı subscription sayfasında "Premium Kod Kullan" butonuna tıklar
2. Kod giriş dialog'u açılır
3. Kod girilir ve doğrulanır
4. Başarılı olursa premium özellikler aktif olur
5. Kod kullanıldıktan sonra tekrar kullanılamaz

---

## 🧪 Test Kodları

### Geliştirme Testleri
Debug modunda şu test kodları kullanılabilir:

```
TEST-MONTHLY-001
TEST-QUARTERLY-001
TEST-PROMO-001
TEST-GIFT-001
```

### Test Senaryoları
1. **Geçerli Kod**: Başarılı aktivasyon
2. **Geçersiz Kod**: Hata mesajı
3. **Kullanılmış Kod**: "Daha önce kullanılmış" hatası
4. **Süresi Dolmuş Kod**: Otomatik temizleme
5. **Boş Kod**: "Kod boş olamaz" hatası

---

## 🔧 Sorun Giderme

### Yaygın Sorunlar

#### 1. Satın Alma Çalışmıyor
**Çözüm**:
- Test hesabı kullanıldığından emin olun
- İnternet bağlantısını kontrol edin
- Uygulama sürümünü kontrol edin
- Google Play Console'da ürünlerin aktif olduğunu kontrol edin

#### 2. Premium Kodlar Çalışmıyor
**Çözüm**:
- Kod formatını kontrol edin
- Büyük harf kullanıldığından emin olun
- Kodun daha önce kullanılmadığını kontrol edin
- Debug modunda test kodları kullanın

#### 3. Reklamlar Gösterilmiyor
**Çözüm**:
- AdMob App ID'lerini kontrol edin
- Test reklam ID'lerini kullanın
- İnternet bağlantısını kontrol edin
- AdMob hesabınızın aktif olduğunu kontrol edin

### Log Kontrolü
Uygulamada şu logları kontrol edin:
```
[AdMobService] AdMob SDK initialized successfully
[SubscriptionService] SubscriptionService initialized successfully
[PremiumCodeService] Premium code redeemed successfully
```

---

## 📞 Destek

### Teknik Destek
- **Email**: support@gorevdeyukselme.com
- **Telefon**: +90 XXX XXX XX XX
- **Çalışma Saatleri**: Pazartesi-Cuma 09:00-18:00

### Dokümantasyon
- **API Dokümantasyonu**: https://docs.gorevdeyukselme.com
- **Geliştirici Rehberi**: https://dev.gorevdeyukselme.com
- **SSS**: https://faq.gorevdeyukselme.com

---

## 📝 Notlar

### Önemli Hatırlatmalar
1. **Test**: Her değişiklikten sonra test edin
2. **Backup**: Kodları güvenli yerde saklayın
3. **Monitoring**: Satın alma istatistiklerini takip edin
4. **Updates**: Düzenli güncellemeler yapın

### Güvenlik
- Premium kodları güvenli şekilde saklayın
- Test kodlarını production'da kullanmayın
- Kullanıcı verilerini koruyun
- GDPR uyumluluğunu sağlayın

---

**Son Güncelleme**: 2024-01-XX  
**Versiyon**: 1.0.0  
**Hazırlayan**: Geliştirici Ekibi
