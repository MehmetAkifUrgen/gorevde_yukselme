# Google Play Console Setup for In-App Purchases

Bu dosya, Google Play Console'da in-app purchase (uygulama içi satın alma) özelliğini yapılandırmak için gerekli adımları içerir.

## 1. Google Play Console'a Giriş

1. [Google Play Console](https://play.google.com/console) adresine gidin
2. Geliştirici hesabınızla giriş yapın
3. Uygulamanızı seçin (henüz yoksa yeni uygulama oluşturun)

## 2. Uygulama Bilgilerini Tamamlayın

### Gerekli Bilgiler:
- Uygulama adı: "Görevde Yükselme"
- Paket adı: `com.gyudsoft.apps` (build.gradle.kts'de tanımlı)
- Kategori: Eğitim
- İçerik derecelendirmesi
- Gizlilik politikası URL'si

## 3. In-App Products (Uygulama İçi Ürünler) Oluşturma

### Ürün Kimlikları (Product IDs):
Aşağıdaki ürün kimliklerini Google Play Console'da oluşturun:

#### Abonelik Ürünleri:
1. **Aylık Premium Abonelik**
   - Product ID: `premium_monthly`
   - Ürün Türü: Subscription (Abonelik)
   - Fiyat: ₺29.99/ay
   - Yenileme Süresi: 1 ay
   - Açıklama: "Aylık premium üyelik - Sınırsız soru çözme ve reklamsız deneyim"

2. **Yıllık Premium Abonelik**
   - Product ID: `premium_yearly`
   - Ürün Türü: Subscription (Abonelik)
   - Fiyat: ₺149.99/yıl
   - Yenileme Süresi: 1 yıl
   - Açıklama: "Yıllık premium üyelik - %60 indirimli, sınırsız soru çözme ve reklamsız deneyim"

## 4. Abonelik Grupları (Subscription Groups)

1. Yeni bir abonelik grubu oluşturun: "Premium Membership"
2. Her iki ürünü de bu gruba ekleyin
3. Upgrade/downgrade politikalarını ayarlayın

## 5. Test Hesapları

### License Testing:
1. Play Console > Setup > License testing
2. Test hesaplarını ekleyin (geliştirici email adresleri)
3. Test response: "LICENSED" olarak ayarlayın

### Internal Testing:
1. Play Console > Testing > Internal testing
2. Test grubu oluşturun
3. Test kullanıcılarını ekleyin
4. APK/AAB yükleyin

## 6. Uygulama İmzalama

### Upload Key Oluşturma:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### key.properties Dosyası:
`android/key.properties` dosyası oluşturun:
```
storePassword=<keystore_password>
keyPassword=<key_password>
keyAlias=upload
storeFile=upload-keystore.jks
```

## 7. Build Configuration

`android/app/build.gradle.kts` dosyasında imzalama yapılandırması:

```kotlin
android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## 8. Test Etme

### Test Kartları:
Google Play Console test kartlarını kullanın:
- Test kartı numarası: 4111 1111 1111 1111
- CVV: Herhangi bir 3 haneli sayı
- Son kullanma tarihi: Gelecekteki herhangi bir tarih

### Test Senaryoları:
1. Ürün listesini getirme
2. Satın alma işlemi
3. Abonelik yenileme
4. Abonelik iptali
5. Satın alımları geri yükleme

## 9. Yayınlama Öncesi Kontrol Listesi

- [ ] Tüm ürünler aktif durumda
- [ ] Fiyatlandırma doğru
- [ ] Test hesapları çalışıyor
- [ ] Uygulama imzalanmış
- [ ] Gizlilik politikası yüklü
- [ ] İçerik derecelendirmesi tamamlanmış
- [ ] Uygulama açıklaması ve ekran görüntüleri yüklü

## 10. Önemli Notlar

- **Test Modu**: Geliştirme sırasında test hesapları kullanın
- **Gerçek Ödemeler**: Sadece yayınlanan uygulamalarda gerçek ödemeler alınır
- **Komisyon**: Google Play %15-30 komisyon alır
- **Vergi**: Türkiye'de KDV ve diğer vergiler uygulanır
- **Para Birimi**: Türk Lirası (TRY) kullanın

## Sorun Giderme

### Yaygın Hatalar:
1. **"Item not found"**: Ürün ID'leri kontrol edin
2. **"User cancelled"**: Normal kullanıcı davranışı
3. **"Billing unavailable"**: Google Play Services kontrol edin
4. **"Developer error"**: Ürün yapılandırması kontrol edin

### Destek:
- [Google Play Console Yardım](https://support.google.com/googleplay/android-developer)
- [In-App Billing Dokümantasyonu](https://developer.android.com/google/play/billing)