# Arduino Programmer - iOS

iOS üzerinden Arduino kartlarına yazılım yüklemek için Swift ile yazılmış, kullanıcı dostu bir uygulama.

## 📱 Özellikler

- ✅ **Bluetooth Desteği**: HC-05, HC-06 gibi Bluetooth modülleri üzerinden Arduino'ya bağlanma
- ✅ **Çoklu Kart Desteği**: Arduino Mega 2560, Mega 1280, Uno ve Nano
- ✅ **STK500v2 Protokolü**: Arduino bootloader ile tam uyumlu protokol implementasyonu
- ✅ **Hex Dosya Desteği**: Intel HEX formatındaki firmware dosyalarını parse etme ve yükleme
- ✅ **Gerçek Zamanlı İlerleme**: Yükleme sürecini adım adım takip etme
- ✅ **Doğrulama**: Yazılan verinin doğruluğunu kontrol etme
- ✅ **Modern UI**: SwiftUI ile tasarlanmış, kullanıcı dostu arayüz

## 🛠 Gereksinimler

- iOS 16.0 veya üzeri
- Xcode 14.0 veya üzeri
- Swift 5.9 veya üzeri
- Bluetooth özellikli iOS cihaz (iPhone/iPad)

## 📦 Kurulum

### Swift Package Manager ile

1. Xcode'da projenizi açın
2. File > Add Packages...
3. Bu repository'nin URL'sini girin
4. "Add Package" butonuna tıklayın

### Manuel Kurulum

1. Repository'yi klonlayın:
```bash
git clone https://github.com/yourusername/arduino-programmer-ios.git
cd arduino-programmer-ios
```

2. Xcode ile `Package.swift` dosyasını açın

3. Uygulamayı build edin ve çalıştırın

## 🔌 Donanım Bağlantısı

### Bluetooth Modülü Bağlantısı (HC-05/HC-06)

Arduino Mega 2560 için örnek bağlantı:

```
HC-05/HC-06    Arduino Mega
-----------    ------------
VCC       -->  5V
GND       -->  GND
TXD       -->  RX0 (Pin 0)
RXD       -->  TX0 (Pin 1)
```

**Önemli Notlar:**
- Bluetooth modülünün baud rate'i Arduino bootloader ile uyumlu olmalıdır (Mega için 115200, Uno için 57600)
- HC-05 modülünü AT komutları ile yapılandırabilirsiniz
- Yazılım yüklerken Arduino'daki mevcut programı kaldırmanız gerekmez

### HC-05 Yapılandırması (Opsiyonel)

HC-05 modülünü yapılandırmak için:

```cpp
// AT komut moduna girmek için KEY pinini HIGH yapın
AT+NAME=ArduinoBT    // Cihaz adını değiştir
AT+BAUD8             // Baud rate'i 115200'e ayarla (Mega için)
AT+BAUD6             // Baud rate'i 57600'e ayarla (Uno için)
AT+PSWD=1234         // PIN kodunu ayarla
```

## 📱 Kullanım

### 1. Arduino Kartını Hazırlama

Arduino'nuzun bootloader'ı yüklü olmalıdır. Arduino IDE ile satın alınan Arduino kartlarda bu varsayılan olarak yüklüdür.

### 2. Uygulamayı Kullanma

1. **Kart Seçimi**: Kullandığınız Arduino kartını seçin (Mega 2560, Uno, vb.)
2. **Hex Dosyası Seçimi**: Yüklemek istediğiniz `.hex` dosyasını seçin
3. **Bağlantı**: "Bluetooth" butonuna tıklayarak Arduino'ya bağlanın
4. **Yükleme**: "Yazılımı Yükle" butonuna basın ve işlemin tamamlanmasını bekleyin

### 3. Hex Dosyası Oluşturma

Arduino IDE'den hex dosyası oluşturmak için:

1. Arduino IDE'de sketch'inizi açın
2. `Sketch > Export Compiled Binary` seçeneğini seçin
3. Sketch klasöründe `.hex` uzantılı dosyayı bulun
4. Bu dosyayı iOS cihazınıza aktarın (AirDrop, iCloud, vb.)

## 🏗 Proje Yapısı

```
Sources/
├── ArduinoProgrammer/      # Ana uygulama giriş noktası
├── Models/                 # Veri modelleri
│   ├── ArduinoBoard.swift
│   ├── HexFile.swift
│   └── ProgrammingStatus.swift
├── Protocols/              # Protokol tanımlamaları
│   └── CommunicationProtocol.swift
├── Services/               # İş mantığı servisleri
│   ├── ArduinoProgrammer.swift
│   ├── BluetoothCommunication.swift
│   ├── HexFileParser.swift
│   └── STK500v2Protocol.swift
└── Views/                  # SwiftUI görünümleri
    ├── ContentView.swift
    └── ProgrammerViewModel.swift
```

## 🔧 Teknik Detaylar

### STK500v2 Protokolü

Uygulama, Arduino bootloader ile iletişim kurmak için STK500v2 protokolünü kullanır:

- Komut yapısı: `MESSAGE_START | SEQUENCE | SIZE_HI | SIZE_LO | TOKEN | COMMAND | DATA | CHECKSUM`
- Checksum: XOR tabanlı doğrulama
- Timeout: 5 saniye
- Sayfa boyutu: Mega için 256 byte, Uno için 128 byte

### Hex Dosya Formatı

Intel HEX formatı desteklenir:
- `:` ile başlayan satırlar
- Kayıt tipleri: Data (00), End of File (01), Extended Linear Address (04)
- Checksum doğrulaması

### Bluetooth İletişimi

- Core Bluetooth framework kullanılır
- Service UUID: FFE0
- Characteristic UUID: FFE1
- Veri transferi: 20 byte'lık paketler halinde

## 🐛 Sorun Giderme

### "Bluetooth kullanılamıyor" hatası
- iOS cihazınızın Bluetooth'u açık olduğundan emin olun
- Ayarlar > Bluetooth bölümünden kontrol edin

### "Cihaz bulunamadı" hatası
- Bluetooth modülünün düzgün bağlandığından emin olun
- Arduino'nun açık olduğunu kontrol edin
- HC-05/HC-06 LED'inin yanıp söndüğünü kontrol edin

### "Programlama başarısız" hatası
- Baud rate'in doğru ayarlandığından emin olun
- Arduino'nun bootloader'ı yüklü olmalıdır
- Bluetooth bağlantısının stabil olduğunu kontrol edin

### "Doğrulama başarısız" hatası
- Hex dosyasının doğru Arduino modeli için derlendiğinden emin olun
- İletişim hatları temiz olmalıdır
- Tekrar deneyin

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Pull request göndermekten çekinmeyin.

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📧 İletişim

Sorularınız veya önerileriniz için issue açabilirsiniz.

## 🙏 Teşekkürler

- Atmel/Microchip - STK500 protokolü dokümantasyonu için
- Arduino Team - Harika platform için
- Swift ve iOS toplulukları

## 📚 Kaynaklar

- [STK500 Protocol Documentation](http://www.atmel.com/Images/doc2591.pdf)
- [Arduino Bootloader](https://github.com/arduino/ArduinoCore-avr/tree/master/bootloaders)
- [Intel HEX Format](https://en.wikipedia.org/wiki/Intel_HEX)
- [Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)

---

Made with ❤️ for Arduino and iOS developers
