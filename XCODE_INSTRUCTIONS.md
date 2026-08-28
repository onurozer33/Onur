# Xcode'da Uygulamayı Çalıştırma Talimatları

## 🚀 Hızlı Başlangıç

Bu proje hem Swift Package hem de Xcode projesi formatında hazırlanmıştır.

### Yöntem 1: Xcode Projesi ile (Önerilen - Daha Kolay)

1. **Projeyi İndirin/Klonlayın**
   ```bash
   git clone https://github.com/onurozer33/Onur.git
   cd Onur
   git checkout cursor/arduino-ios-programmer-0a3f
   ```

2. **Xcode'da Açın**
   - `ArduinoProgrammer.xcodeproj` dosyasına çift tıklayın
   - Veya Xcode'dan: `File > Open` > `ArduinoProgrammer.xcodeproj` seçin

3. **Simulator Seçin**
   - Xcode üst menüsünden bir simulator seçin (örn: iPhone 15 Pro)
   - `Product > Destination > iPhone 15 Pro` (veya başka bir iPhone)

4. **Çalıştırın**
   - ⌘R tuşlarına basın veya
   - Play (▶) butonuna tıklayın

### Yöntem 2: Swift Package ile

1. **Xcode'da Yeni Proje Oluşturun**
   - Xcode'u açın
   - `File > New > Project`
   - iOS > App seçin
   - SwiftUI seçin

2. **Package'ı Ekleyin**
   - `File > Add Packages...`
   - Local package olarak bu klasörü ekleyin
   - Veya GitHub URL'sini kullanın

3. **Import Edin**
   ```swift
   import ArduinoProgrammer
   ```

## 📱 Simulator'de Test

### NOT: Bluetooth Simulator'de Çalışmaz!

Simulator'de Bluetooth donanımı olmadığı için gerçek bağlantı yapamayacaksınız. Ancak:

1. **UI Test Edebilirsiniz**: Arayüzün görünümünü ve akışını test edebilirsiniz
2. **Mock Data**: Test için sahte veri kullanabilirsiniz
3. **Gerçek Test**: Fiziksel iOS cihazda test etmeniz gerekir

### Fiziksel Cihazda Çalıştırma

1. **iPhone/iPad'inizi Mac'e bağlayın**
2. **Xcode'da cihazınızı seçin**
   - Üst menüden cihazınızı seçin
3. **Geliştirici Hesabı Ekleyin**
   - `Signing & Capabilities` bölümünden Apple ID ekleyin
4. **Çalıştırın**
   - ⌘R ile uygulamayı cihazınıza yükleyin

### Geliştirici Ayarları (iPhone)

İlk kez çalıştırırken:
1. iPhone'da `Ayarlar > Genel > Cihaz Yönetimi`
2. Geliştirici uygulamanıza güvenin
3. Uygulamayı tekrar açın

## 🔧 Build Hataları ve Çözümleri

### Hata: "No such module 'ArduinoProgrammer'"
**Çözüm**: Projeyi temizleyip yeniden build edin
```
⇧⌘K (Clean Build Folder)
⌘B (Build)
```

### Hata: "Code signing is required"
**Çözüm**: 
- Xcode > Preferences > Accounts
- Apple ID ekleyin
- Project Settings > Signing & Capabilities
- Team seçin

### Hata: "Deployment target is too low"
**Çözüm**: 
- Project Settings > General
- Deployment Target: iOS 16.0 veya üzeri

## 🎨 Preview'lar

SwiftUI Preview'ları görmek için:

1. `ContentView.swift` dosyasını açın
2. Sağ tarafta Canvas açılmazsa: `Editor > Canvas` (⌥⌘↵)
3. "Resume" butonuna basın

## 🐛 Debug

### Console Logları

Uygulamayı çalıştırdıktan sonra:
- `View > Debug Area > Show Debug Area` (⇧⌘Y)
- Console'da tüm print() çıktılarını görebilirsiniz

### Breakpoint'ler

- Kod satırının sol tarafına tıklayarak breakpoint ekleyin
- Uygulamayı Debug modunda çalıştırın (⌘R)
- Breakpoint'te durunca değişkenleri inceleyin

## 📦 Projeyi Export Etme

### App Store'a Yüklemek İçin

1. `Product > Archive`
2. `Distribute App` seçin
3. App Store Connect seçin
4. Adımları takip edin

### TestFlight için

1. Archive oluşturun
2. App Store Connect'e yükleyin
3. TestFlight'ta test kullanıcıları ekleyin

### Ad Hoc Dağıtım

1. `Product > Archive`
2. `Distribute App > Ad Hoc`
3. IPA dosyasını export edin

## 🔐 Bluetooth İzinleri

Uygulama ilk çalıştırıldığında:
- iOS otomatik olarak Bluetooth izni isteyecek
- "İzin Ver" seçin
- Info.plist'te gerekli anahtarlar zaten ekli:
  - `NSBluetoothAlwaysUsageDescription`
  - `NSBluetoothPeripheralUsageDescription`

## 📚 Ek Kaynaklar

- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [iOS App Distribution](https://developer.apple.com/distribute/)

## 💡 İpuçları

1. **Hızlı Build**: Simulator'ler build süresini kısaltır
2. **Hot Reload**: SwiftUI Preview'ları gerçek zamanlı güncellenir
3. **Instruments**: Performance analizi için kullanın
4. **View Hierarchy**: UI problemlerini debug etmek için

---

Sorularınız için GitHub Issues kullanın veya dokümantasyonu inceleyin!
