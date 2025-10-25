# App Store Connect In-App Purchase Kurulumu

Bu dokümanda, uygulamanızın in-app purchase özelliklerini App Store Connect'te nasıl yapılandıracağınız açıklanmaktadır.

## 📋 Ön Koşullar

- Apple Developer Program üyeliği
- App Store Connect'te uygulamanızın oluşturulmuş olması
- Paid Applications Agreement'ın imzalanmış olması
- Banking and Tax bilgilerinin tamamlanmış olması

## 🛍️ Subscription Products Oluşturma

### 1. App Store Connect'e Giriş
1. [App Store Connect](https://appstoreconnect.apple.com)'e giriş yapın
2. "My Apps" bölümüne gidin
3. Uygulamanızı seçin

### 2. In-App Purchases Bölümü
1. Sol menüden "Features" → "In-App Purchases" seçin
2. "+" butonuna tıklayın
3. "Auto-Renewable Subscriptions" seçin

### 3. Subscription Group Oluşturma
1. "Create Subscription Group" butonuna tıklayın
2. **Reference Name**: `Premium Subscriptions`
3. **App Name**: `Premium Subscriptions` (kullanıcılara görünecek)
4. "Create" butonuna tıklayın

### 4. Monthly Premium Subscription
1. Oluşturulan grup içinde "+" butonuna tıklayın
2. **Product ID**: `com.gyudsoft.apps.monthly`
3. **Reference Name**: `Monthly Premium`
4. **Duration**: `1 Month`

#### Pricing and Availability
- **Price**: 79.99 TL (Türkiye)
- **Availability**: Tüm ülkeler

#### Subscription Information
- **Display Name**: `Aylık Premium`
- **Description**: `Tüm premium özelliklere aylık erişim`

#### Review Information
- **Screenshot**: Subscription özelliklerini gösteren ekran görüntüsü
- **Review Notes**: Subscription'ın ne sağladığını açıklayın

### 5. Quarterly Premium Subscription
1. Aynı grup içinde tekrar "+" butonuna tıklayın
2. **Product ID**: `com.gyudsoft.apps.quarterly`
3. **Reference Name**: `Quarterly Premium`
4. **Duration**: `3 Months`

#### Pricing and Availability
- **Price**: 199.99 TL (Türkiye)
- **Availability**: Tüm ülkeler

#### Subscription Information
- **Display Name**: `3 Aylık Premium`
- **Description**: `Tüm premium özelliklere 3 aylık erişim`

## 🧪 Test Kurulumu

### 1. Sandbox Test Accounts
1. App Store Connect'te "Users and Access" → "Sandbox" → "Testers" gidin
2. "+" butonuna tıklayın
3. Test hesabı bilgilerini girin:
   - **Email**: Test için kullanacağınız email
   - **Password**: Güçlü bir şifre
   - **Country/Region**: Turkey
   - **App Store Territory**: Turkey

### 2. Test Cihazında Kurulum
1. iOS cihazında Settings → App Store → Sandbox Account
2. Test hesabı ile giriş yapın
3. Uygulamanızı test edin

## 📱 StoreKit Configuration Doğrulama

Projenizde `ios/Configuration.storekit` dosyası zaten mevcut ve doğru yapılandırılmış:

```json
{
  "identifier": "test_configuration",
  "nonRenewingSubscriptions": [],
  "products": [],
  "settings": {
    "_applicationInternalID": "6738049403",
    "_developerTeamID": "YOUR_TEAM_ID",
    "_failTransactionsEnabled": false,
    "_lastSynchronizedDate": "2024-12-19T10:30:00.000Z",
    "_locale": "en_US",
    "_storefront": "USA",
    "_storeKitErrors": []
  },
  "subscriptionGroups": [
    {
      "id": "21553869",
      "localizations": [],
      "name": "Premium Subscriptions",
      "subscriptions": [
        {
          "adHocOffers": [],
          "codeOffers": [],
          "displayPrice": "79.99",
          "familyShareable": false,
          "id": "com.gyudsoft.apps.monthly",
          "introductoryOffer": null,
          "localizations": [
            {
              "description": "Monthly premium subscription",
              "displayName": "Monthly Premium",
              "locale": "en_US"
            }
          ],
          "productID": "com.gyudsoft.apps.monthly",
          "recurringSubscriptionPeriod": "P1M",
          "referenceName": "Monthly Premium",
          "subscriptionGroupID": "21553869",
          "type": "RecurringSubscription"
        },
        {
          "adHocOffers": [],
          "codeOffers": [],
          "displayPrice": "199.99",
          "familyShareable": false,
          "id": "com.gyudsoft.apps.quarterly",
          "introductoryOffer": null,
          "localizations": [
            {
              "description": "Quarterly premium subscription",
              "displayName": "Quarterly Premium",
              "locale": "en_US"
            }
          ],
          "productID": "com.gyudsoft.apps.quarterly",
          "recurringSubscriptionPeriod": "P3M",
          "referenceName": "Quarterly Premium",
          "subscriptionGroupID": "21553869",
          "type": "RecurringSubscription"
        }
      ]
    }
  ],
  "version": {
    "major": 3,
    "minor": 0
  }
}
```

## ✅ Kontrol Listesi

### App Store Connect'te Tamamlanması Gerekenler:
- [ ] Subscription Group oluşturuldu
- [ ] Monthly Premium product oluşturuldu (`com.gyudsoft.apps.monthly`)
- [ ] Quarterly Premium product oluşturuldu (`com.gyudsoft.apps.quarterly`)
- [ ] Her product için pricing ayarlandı
- [ ] Her product için metadata (isim, açıklama) eklendi
- [ ] Sandbox test hesabı oluşturuldu
- [ ] Products "Ready to Submit" durumunda

### iOS Projesi:
- [x] `Runner.entitlements` dosyasına `com.apple.developer.in-app-payments` eklendi
- [x] `RunnerRelease.entitlements` dosyasına `com.apple.developer.in-app-payments` eklendi
- [x] `Configuration.storekit` dosyası mevcut ve yapılandırılmış
- [x] `Info.plist` dosyasında StoreKit yapılandırması mevcut

### Flutter Projesi:
- [x] `in_app_purchase` paketi eklendi
- [x] Subscription service implementasyonu tamamlandı
- [x] UI components hazır
- [x] State management (Riverpod) yapılandırıldı

## 🚀 Production'a Geçiş

1. **App Review**: Products'ları app review için submit edin
2. **Receipt Validation**: Server-side receipt validation implementasyonu ekleyin
3. **Analytics**: Subscription events için analytics ekleyin
4. **Error Handling**: Production error handling'i güçlendirin

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Apple Developer Documentation'ı kontrol edin
2. App Store Connect Help Center'ı ziyaret edin
3. Developer Forums'da arama yapın

---

**Not**: Bu kurulum tamamlandıktan sonra, uygulamanızın in-app purchase özellikleri tam olarak çalışır hale gelecektir.