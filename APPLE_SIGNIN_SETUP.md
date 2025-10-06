# Sign in with Apple - iOS Setup Guide

Bu rehber, iOS için Sign in with Apple özelliğini nasıl yapılandıracağınızı açıklar.

## ✅ Tamamlanan Adımlar

1. **Package Eklendi**: `sign_in_with_apple: ^6.1.0` pubspec.yaml'a eklendi
2. **Apple Sign-In Service**: `AppleSignInService` sınıfı oluşturuldu
3. **AuthService Güncellendi**: Apple Sign-In metodu eklendi
4. **Login UI Güncellendi**: Apple Sign-In butonu eklendi
5. **Auth Providers Güncellendi**: Apple Sign-In metodu eklendi
6. **iOS Entitlements**: `Runner.entitlements` dosyası oluşturuldu

## 🔧 Xcode'da Yapılması Gerekenler

### 1. Xcode'da Projeyi Açın
```bash
cd ios
open Runner.xcworkspace
```

### 2. Sign in with Apple Capability'sini Ekleyin
1. Xcode'da proje navigator'da **Runner** projesini seçin
2. **Signing & Capabilities** sekmesine gidin
3. **+ Capability** butonuna tıklayın
4. **Sign in with Apple** seçin
5. Capability otomatik olarak eklenecek

### 3. Bundle Identifier Kontrolü
- Bundle identifier'ın doğru olduğundan emin olun
- Apple Developer hesabınızda bu bundle ID için Sign in with Apple aktif olmalı

### 4. Apple Developer Console'da Yapılandırma
1. [Apple Developer Console](https://developer.apple.com) giriş yapın
2. **Certificates, Identifiers & Profiles** bölümüne gidin
3. **Identifiers** sekmesinde uygulamanızı bulun
4. **Sign in with Apple** capability'sini aktif edin
5. **Save** butonuna tıklayın

## 🧪 Test Etme

### 1. Simulator'da Test
```bash
flutter run
```

### 2. Gerçek Cihazda Test
- Apple ID ile giriş yapın
- Sign in with Apple butonuna tıklayın
- Apple'ın giriş ekranı açılmalı

## 📱 UI Değişiklikleri

Login sayfasında şu değişiklikler yapıldı:
- Apple Sign-In butonu eklendi (siyah arka plan, beyaz metin)
- Google Sign-In butonunun altına yerleştirildi
- Sadece iOS'ta görünür (Platform.isIOS kontrolü)

## 🔍 Debug

Eğer Apple Sign-In çalışmıyorsa:

1. **Console Logları**: `[AppleSignInService]` ile başlayan logları kontrol edin
2. **Capability Kontrolü**: Xcode'da Sign in with Apple capability'sinin eklendiğinden emin olun
3. **Bundle ID**: Apple Developer Console'da bundle ID'nin doğru olduğundan emin olun
4. **Apple ID**: Test cihazında Apple ID ile giriş yapılmış olmalı

## ⚠️ Önemli Notlar

- Sign in with Apple sadece iOS 13+ sürümlerinde çalışır
- Test için gerçek cihaz kullanmanız önerilir
- Apple Developer hesabınızda Sign in with Apple aktif olmalı
- Bundle identifier Apple Developer Console'da kayıtlı olmalı

## 🚀 App Store Review İçin

Bu implementasyon Apple'ın Guideline 4.8 gereksinimlerini karşılar:
- ✅ Kullanıcı adı ve email adresi ile sınırlı veri toplama
- ✅ Email adresini gizli tutma seçeneği
- ✅ Reklam amaçlı veri toplama olmadan kullanıcı onayı
