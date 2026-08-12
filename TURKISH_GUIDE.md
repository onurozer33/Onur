# Arduino Programmer iOS - Türkçe Kullanım Kılavuzu

## 🎯 Hızlı Başlangıç

Bu uygulama ile iPhone veya iPad'inizden Arduino kartlarınıza yazılım yükleyebilirsiniz!

## 📋 İhtiyacınız Olanlar

1. **iOS Cihaz**: iPhone veya iPad (iOS 16+)
2. **Arduino Kartı**: Mega 2560, Mega 1280, Uno veya Nano
3. **Bluetooth Modülü**: HC-05 veya HC-06
4. **Hex Dosyası**: Arduino IDE'den export edilmiş firmware

## 🔧 Adım Adım Kurulum

### 1. Donanım Bağlantısı

#### HC-05 veya HC-06 Modülünü Arduino'ya Bağlama

**Arduino Mega 2560 için:**
```
HC-05    →    Arduino Mega
VCC      →    5V
GND      →    GND
TXD      →    RX0 (0 nolu pin)
RXD      →    TX0 (1 nolu pin)
```

**Arduino Uno için:**
```
HC-05    →    Arduino Uno
VCC      →    5V
GND      →    GND
TXD      →    Pin 0 (RX)
RXD      →    Pin 1 (TX)
```

### 2. Bluetooth Modülünü Ayarlama

HC-05 modülü için baud rate ayarı:

1. HC-05'in KEY pinini HIGH yapın (genellikle bir butona basılı tutarak)
2. Seri monitörde şu komutları gönderin:

```
AT+NAME=ArduinoBT        # İsim değişikliği
AT+BAUD8                 # Mega için 115200 baud
AT+BAUD6                 # Uno için 57600 baud
AT+PSWD=1234             # Şifre ayarla
```

**NOT**: HC-06 modülünde AT komutları biraz farklıdır, manuel kontrolü yapın.

### 3. Hex Dosyası Oluşturma

Arduino IDE'den:

1. Sketch'inizi yazın/açın
2. Menüden: **Sketch → Export Compiled Binary**
3. Sketch klasöründe `.hex` uzantılı dosya oluşur
4. Bu dosyayı iOS cihazınıza aktarın:
   - AirDrop ile
   - iCloud Drive üzerinden
   - E-posta eki olarak
   - Files uygulaması ile

### 4. iOS Uygulamasını Kullanma

#### Adım 1: Kart Seçimi
- Uygulamayı açın
- "Kart Seçimi" bölümünden Arduino modelinizi seçin
- Otomatik olarak doğru ayarlar yüklenecektir

#### Adım 2: Hex Dosyası Seçimi
- "Hex Dosyası" bölümünden "Hex Dosyası Seç" butonuna basın
- Daha önce aktardığınız `.hex` dosyasını seçin
- Dosya başarıyla yüklendiğinde yeşil onay işareti görünecek

#### Adım 3: Bağlantı Kurma
- Arduino'yu ve Bluetooth modülünü açın
- "Bağlantı" bölümünden "Bluetooth" butonuna basın
- Bluetooth modülü bulunduğunda otomatik bağlanacaktır
- Bağlantı kurulunca yeşil onay işareti görünecek

#### Adım 4: Yazılım Yükleme
- "Yazılımı Yükle" butonuna basın
- İşlem adımlarını izleyin:
  - Bağlanıyor...
  - Doğrulanıyor...
  - Yazılım yükleniyor... (%)
  - Doğrulanıyor... (%)
  - Tamamlandı!

## ❗ Sık Karşılaşılan Sorunlar ve Çözümleri

### Bluetooth Bulunamıyor

**Çözüm:**
- iPhone/iPad Bluetooth'unun açık olduğundan emin olun
- Bluetooth modülünün düzgün beslendiğinden emin olun
- HC-05/HC-06 LED'inin hızlı yanıp söndüğünden emin olun

### Bağlantı Kurulamıyor

**Çözüm:**
- Bağlantı kabloslarını kontrol edin
- Arduino'nun açık olduğunu doğrulayın
- Bluetooth modülü baud rate'ini kontrol edin
- Başka cihazların modüle bağlı olmadığından emin olun

### Yazılım Yüklenemiyor

**Muhtemel Nedenler:**
1. **Yanlış baud rate**: HC-05 ayarlarını kontrol edin
2. **Bootloader yok**: Arduino'da bootloader yüklü değilse ISP ile yüklemeniz gerekir
3. **Yanlış hex dosyası**: Hex dosyası seçtiğiniz kart modeli için derlenmiş olmalıdır

**Çözüm:**
- Arduino IDE'de doğru kartı seçtiğinizden emin olun
- Hex dosyasını tekrar export edin
- Baud rate ayarını kontrol edin

### Doğrulama Hatası

**Çözüm:**
- İletişimde gürültü olabilir, tekrar deneyin
- Bluetooth modülü ve Arduino arasındaki bağlantıları kontrol edin
- Güç kaynağının yeterli olduğundan emin olun

## 🔍 İpuçları ve Püf Noktaları

### 1. İlk Deneme
İlk kez kullanıyorsanız basit bir "Blink" programı ile test edin:
```cpp
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(1000);
  digitalWrite(LED_BUILTIN, LOW);
  delay(1000);
}
```

### 2. Güç Yönetimi
- USB üzerinden güç verin
- Bluetooth modülü çok akım çeker, harici güç kullanabilirsiniz
- Mega için minimum 500mA, Uno için 300mA güç kaynağı

### 3. Bağlantı Mesafesi
- Bluetooth modülü yaklaşık 10 metre menzile sahiptir
- Yazılım yükleme sırasında yakın kalın (1-2 metre)

### 4. Yedekleme
- Önemli programlarınızın hex dosyalarını saklayın
- Bir program yükledikten sonra eski programa dönmek isterseniz lazım olur

## 🎓 Gelişmiş Kullanım

### Özel Bootloader
Özel bootloader kullanıyorsanız, baud rate ve protokol ayarlarının STK500v2 ile uyumlu olduğundan emin olun.

### Çoklu Cihaz
Birden fazla Arduino ile çalışıyorsanız, her HC-05 modülüne farklı isim vererek kolayca ayırt edebilirsiniz.

### Automation
iOS Shortcuts ile otomatik yazılım yükleme senaryoları oluşturabilirsiniz.

## 📞 Yardım ve Destek

Sorunlarınız için:
1. Bu dokümanı dikkatlice okuyun
2. Bağlantıları kontrol edin
3. GitHub'da issue açın
4. Arduino forumlarına danışın

## 🌟 En İyi Pratikler

1. **Her zaman yedek alın**: Mevcut programınızı kaydedin
2. **Test edin**: Yeni bir program yükledikten sonra test edin
3. **Güç kontrolü**: Yükleme sırasında güç kesintisi olmamasına dikkat edin
4. **Temiz bağlantılar**: Jumper kablolarınızın sağlam olduğundan emin olun

## 🚀 Sonraki Adımlar

Bu uygulamayı kullanarak:
- IoT projeleri geliştirin
- Kablosuz güncellemeler yapın
- Saha güncellemeleri gerçekleştirin
- Prototipleme sürecinizi hızlandırın

İyi kodlamalar! 🎉
