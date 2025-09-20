# App Store Connect Setup for In-App Purchases

Bu dosya, App Store Connect'te in-app purchase (uygulama içi satın alma) özelliğini yapılandırmak için gerekli adımları içerir.

## 1. App Store Connect'e Giriş

1. [App Store Connect](https://appstoreconnect.apple.com) adresine gidin
2. Apple Developer hesabınızla giriş yapın
3. "My Apps" bölümünden uygulamanızı seçin (henüz yoksa yeni uygulama oluşturun)

## 2. Uygulama Bilgilerini Tamamlayın

### Gerekli Bilgiler:
- Uygulama adı: "Görevde Yükselme"
- Bundle ID: `com.gyudsoft.apps` (Info.plist'te tanımlı)
- Kategori: Education (Eğitim)
- Yaş sınırı: 4+
- Gizlilik politikası URL'si

## 3. In-App Purchases Oluşturma

### Ürün Kimlikları (Product IDs):
Aşağıdaki ürün kimliklerini App Store Connect'te oluşturun:

#### Auto-Renewable Subscriptions:
1. **Aylık Premium Abonelik**
   - Product ID: `premium_monthly`
   - Reference Name: "Premium Monthly Subscription"
   - Subscription Group: "Premium Membership"
   - Subscription Duration: 1 Month
   - Price: ₺29.99 (Tier 7)
   - Localization (Turkish):
     - Display Name: "Aylık Premium Üyelik"
     - Description: "Sınırsız soru çözme, reklamsız deneyim ve premium özellikler"

2. **Yıllık Premium Abonelik**
   - Product ID: `premium_yearly`
   - Reference Name: "Premium Yearly Subscription"
   - Subscription Group: "Premium Membership"
   - Subscription Duration: 1 Year
   - Price: ₺149.99 (Tier 25)
   - Localization (Turkish):
     - Display Name: "Yıllık Premium Üyelik"
     - Description: "%60 indirimli yıllık premium üyelik - Sınırsız soru çözme ve reklamsız deneyim"

## 4. Subscription Groups

1. Subscription Group Name: "Premium Membership"
2. Her iki ürünü de bu gruba ekleyin
3. Subscription levels:
   - Level 1: Monthly (premium_monthly)
   - Level 2: Yearly (premium_yearly)

## 5. Agreements, Tax, and Banking

### Gerekli Belgeler:
1. **Paid Apps Agreement**: İmzalanmalı
2. **Tax Forms**: Türkiye vergi bilgileri
3. **Banking Information**: Türk bankası hesap bilgileri

### Vergi Bilgileri:
- Tax ID: Vergi kimlik numaranız
- Tax Classification: Individual/Business
- Country: Turkey

## 6. Test Hesapları

### Sandbox Testing:
1. App Store Connect > Users and Access > Sandbox Testers
2. Test hesapları oluşturun (farklı email adresleri)
3. Test hesaplarını farklı ülkelerde oluşturun

### Test Hesabı Bilgileri:
```
Email: test1@example.com
Password: TestPass123!
Country: Turkey
```

## 7. Xcode Configuration

### Capabilities:
`ios/Runner.xcodeproj` dosyasında In-App Purchase capability'sini etkinleştirin:

1. Xcode'da projeyi açın
2. Runner target'ını seçin
3. Signing & Capabilities tab'ına gidin
4. "+ Capability" butonuna tıklayın
5. "In-App Purchase" seçin

### Info.plist:
Gerekli izinler zaten `in_app_purchase` paketi tarafından otomatik eklenir.

## 8. StoreKit Configuration File (iOS 14+)

### StoreKit Configuration:
1. Xcode'da File > New > File
2. iOS > Resource > StoreKit Configuration File
3. Dosya adı: `Products.storekit`
4. Ürünleri manuel olarak ekleyin (test için)

### Ürün Yapılandırması:
```json
{
  "identifier": "premium_monthly",
  "type": "auto-renewable-subscription",
  "displayName": "Aylık Premium Üyelik",
  "description": "Sınırsız soru çözme ve reklamsız deneyim",
  "price": "29.99",
  "locale": "tr_TR",
  "subscriptionGroupIdentifier": "premium_membership",
  "subscriptionPeriod": "P1M"
}
```

## 9. Test Etme

### Simulator Testing:
1. Xcode'da StoreKit Configuration file'ı seçin
2. Simulator'da test edin
3. Gerçek para harcanmaz

### Device Testing:
1. Test hesabıyla App Store'dan çıkış yapın
2. Uygulamayı test cihazına yükleyin
3. Satın alma işlemini test edin
4. Sandbox hesabıyla giriş yapın

### Test Senaryoları:
1. Ürün listesini getirme
2. Satın alma işlemi
3. Abonelik yenileme
4. Abonelik iptali
5. Satın alımları geri yükleme
6. Family Sharing (varsa)

## 10. App Review Bilgileri

### Review Notes:
```
Bu uygulama premium abonelik sistemi içerir:
- Aylık abonelik: ₺29.99
- Yıllık abonelik: ₺149.99

Premium özellikler:
- Sınırsız soru çözme
- Reklamsız deneyim
- Detaylı istatistikler
- Çevrimdışı erişim

Test hesabı:
Email: reviewer@example.com
Password: ReviewPass123!
```

## 11. Yayınlama Öncesi Kontrol Listesi

- [ ] Tüm in-app purchase ürünleri "Ready to Submit" durumunda
- [ ] Subscription group yapılandırılmış
- [ ] Test hesapları çalışıyor
- [ ] Agreements imzalanmış
- [ ] Banking ve tax bilgileri tamamlanmış
- [ ] App review bilgileri hazırlanmış
- [ ] Gizlilik politikası yüklü
- [ ] Uygulama açıklaması ve ekran görüntüleri yüklü

## 12. Önemli Notlar

- **Test Modu**: Sandbox hesapları kullanın
- **Gerçek Ödemeler**: Sadece App Store'da yayınlanan uygulamalarda
- **Komisyon**: Apple %15-30 komisyon alır (Small Business Program için %15)
- **Vergi**: Türkiye'de KDV otomatik hesaplanır
- **Para Birimi**: Türk Lirası (TRY) kullanın
- **Family Sharing**: Abonelikler için otomatik aktif

## 13. Sorun Giderme

### Yaygın Hatalar:
1. **"Cannot connect to iTunes Store"**: Sandbox hesabı kontrol edin
2. **"Product not found"**: Ürün ID'leri ve durumu kontrol edin
3. **"User cancelled"**: Normal kullanıcı davranışı
4. **"Payment not allowed"**: Cihaz kısıtlamaları kontrol edin

### Destek:
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [In-App Purchase Programming Guide](https://developer.apple.com/in-app-purchase/)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)