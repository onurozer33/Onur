# Örnek Kullanım Senaryoları

## 📱 Temel Kullanım Örnekleri

### Örnek 1: Basit LED Yakma (Blink)

#### Arduino Kodu:
```cpp
// Blink.ino
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

#### Adımlar:
1. Arduino IDE'de yukarıdaki kodu yazın
2. Tools → Board → Arduino Mega 2560 seçin
3. Sketch → Export Compiled Binary
4. Oluşan `.hex` dosyasını iOS cihazınıza aktarın
5. iOS uygulamasından hex dosyasını yükleyin

---

### Örnek 2: Seri Haberleşme

#### Arduino Kodu:
```cpp
// SerialTest.ino
void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) {
    char command = Serial.read();
    
    if (command == '1') {
      digitalWrite(LED_BUILTIN, HIGH);
      Serial.println("LED ON");
    }
    else if (command == '0') {
      digitalWrite(LED_BUILTIN, LOW);
      Serial.println("LED OFF");
    }
  }
}
```

**NOT**: Bu programı yükledikten sonra Serial Monitor veya başka bir Bluetooth terminal uygulaması ile test edebilirsiniz.

---

### Örnek 3: Sensör Okuma

#### Arduino Kodu:
```cpp
// SensorReader.ino
const int sensorPin = A0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  int sensorValue = analogRead(sensorPin);
  float voltage = sensorValue * (5.0 / 1023.0);
  
  Serial.print("Sensor: ");
  Serial.print(sensorValue);
  Serial.print(" - Voltage: ");
  Serial.println(voltage);
  
  delay(1000);
}
```

---

### Örnek 4: PWM Motor Kontrolü

#### Arduino Kodu:
```cpp
// MotorControl.ino
const int motorPin = 9;
int motorSpeed = 0;

void setup() {
  pinMode(motorPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available() > 0) {
    motorSpeed = Serial.parseInt();
    motorSpeed = constrain(motorSpeed, 0, 255);
    analogWrite(motorPin, motorSpeed);
    
    Serial.print("Motor Speed: ");
    Serial.println(motorSpeed);
  }
}
```

---

## 🎯 İleri Düzey Örnekler

### Örnek 5: Multi-Task LED Pattern

#### Arduino Kodu:
```cpp
// LEDPattern.ino
const int ledPins[] = {2, 3, 4, 5, 6};
const int numLeds = 5;
unsigned long previousMillis = 0;
int currentLed = 0;

void setup() {
  for (int i = 0; i < numLeds; i++) {
    pinMode(ledPins[i], OUTPUT);
  }
  Serial.begin(9600);
}

void loop() {
  unsigned long currentMillis = millis();
  
  if (currentMillis - previousMillis >= 200) {
    previousMillis = currentMillis;
    
    digitalWrite(ledPins[currentLed], LOW);
    currentLed = (currentLed + 1) % numLeds;
    digitalWrite(ledPins[currentLed], HIGH);
  }
  
  if (Serial.available() > 0) {
    char command = Serial.read();
    if (command == 's') {
      for (int i = 0; i < numLeds; i++) {
        digitalWrite(ledPins[i], LOW);
      }
      Serial.println("All LEDs OFF");
    }
  }
}
```

---

### Örnek 6: Servo Motor Kontrolü

#### Arduino Kodu:
```cpp
// ServoControl.ino
#include <Servo.h>

Servo myServo;
const int servoPin = 9;
int angle = 90;

void setup() {
  myServo.attach(servoPin);
  myServo.write(angle);
  Serial.begin(9600);
  Serial.println("Servo Control Ready");
}

void loop() {
  if (Serial.available() > 0) {
    int newAngle = Serial.parseInt();
    
    if (newAngle >= 0 && newAngle <= 180) {
      angle = newAngle;
      myServo.write(angle);
      
      Serial.print("Servo angle: ");
      Serial.println(angle);
    }
  }
}
```

---

### Örnek 7: LCD Display ile Mesaj Gösterme

#### Arduino Kodu:
```cpp
// LCDDisplay.ino
#include <LiquidCrystal.h>

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
String message = "";

void setup() {
  lcd.begin(16, 2);
  lcd.print("Arduino Ready!");
  Serial.begin(9600);
}

void loop() {
  if (Serial.available() > 0) {
    char c = Serial.read();
    
    if (c == '\n') {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(message);
      Serial.println("Message displayed: " + message);
      message = "";
    } else {
      message += c;
    }
  }
}
```

---

## 🔄 Pratik Kullanım Senaryoları

### Senaryo 1: IoT Sıcaklık İzleme

```cpp
// TempMonitor.ino
#include <DHT.h>

#define DHTPIN 2
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  dht.begin();
}

void loop() {
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  
  if (!isnan(humidity) && !isnan(temperature)) {
    Serial.print("Temp: ");
    Serial.print(temperature);
    Serial.print("C, Humidity: ");
    Serial.print(humidity);
    Serial.println("%");
  }
  
  delay(2000);
}
```

**Kullanım:**
1. DHT22 sensörü Arduino'ya bağlayın
2. DHT kütüphanesini Arduino IDE'ye ekleyin
3. Kodu derleyip hex dosyası oluşturun
4. iOS uygulaması ile yükleyin
5. Bluetooth seri monitör uygulaması ile verileri okuyun

---

### Senaryo 2: RGB LED Renk Kontrolü

```cpp
// RGBControl.ino
const int redPin = 9;
const int greenPin = 10;
const int bluePin = 11;

void setup() {
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  Serial.begin(9600);
}

void setColor(int red, int green, int blue) {
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);
}

void loop() {
  if (Serial.available() >= 3) {
    int r = Serial.parseInt();
    int g = Serial.parseInt();
    int b = Serial.parseInt();
    
    r = constrain(r, 0, 255);
    g = constrain(g, 0, 255);
    b = constrain(b, 0, 255);
    
    setColor(r, g, b);
    
    Serial.print("RGB: ");
    Serial.print(r); Serial.print(",");
    Serial.print(g); Serial.print(",");
    Serial.println(b);
  }
}
```

**Komutlar:**
- `255,0,0` - Kırmızı
- `0,255,0` - Yeşil
- `0,0,255` - Mavi
- `255,255,255` - Beyaz

---

### Senaryo 3: Ultrasonik Mesafe Sensörü

```cpp
// UltrasonicDistance.ino
const int trigPin = 9;
const int echoPin = 10;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
}

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  long duration = pulseIn(echoPin, HIGH);
  float distance = (duration * 0.034) / 2;
  
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");
  
  delay(500);
}
```

---

## 🛠 Test ve Debug İpuçları

### Debug için Seri Port Kullanımı

```cpp
// DebugExample.ino
void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.println("Program started!");
}

void loop() {
  Serial.println("Loop iteration");
  
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.println("LED ON");
  delay(1000);
  
  digitalWrite(LED_BUILTIN, LOW);
  Serial.println("LED OFF");
  delay(1000);
}
```

### Hata Ayıklama İpuçları:

1. **Seri monitör kullanın**: Programın ne yaptığını görmek için Serial.println() ekleyin
2. **LED göstergeleri**: Programın hangi aşamada olduğunu LED'lerle gösterin
3. **Adım adım test**: Küçük parçalar halinde test edin
4. **Basit başlayın**: Karmaşık projelerde önce basit versiyonu test edin

---

## 📚 Ek Kaynaklar

### Yararlı Kütüphaneler:
- **Servo**: Servo motor kontrolü
- **LiquidCrystal**: LCD ekran kontrolü
- **DHT**: Sıcaklık ve nem sensörü
- **Wire**: I2C haberleşme
- **SPI**: SPI haberleşme

### Test Araçları:
- **Serial Bluetooth Terminal** (iOS)
- **BlueTerm** (iOS)
- **Arduino Bluetooth Control** (iOS)

---

Bu örnekleri kullanarak kendi projelerinizi geliştirebilirsiniz. Her örneği test edin ve ihtiyaçlarınıza göre özelleştirin!
