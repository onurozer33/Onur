# asam01 bağlantısı için Ed25519 entegrasyonu

Bu not, mevcut bağlantı programının `asam01` oturumunda kullanacağı kimliği tanımlar. Özel anahtar bu dosyada durmaz. Program tohumu çalışma anında ortamdan okur, açık anahtarı türetir ve bağlantı meydan okumasını imzalar.

## Anahtar

| Alan | Değer |
|---|---|
| Algoritma | Ed25519 (RFC 8032) |
| Özel anahtar | 32 bayt tohum (64 onaltılık karakter) |
| Açık anahtar (ham hex) | `1f16c1b358c192bbf66af27c2fcb4cbeffcf7d688b08227c22be031105b1402c` |
| Açık anahtar (OpenSSH) | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB8WwbNYwZK79mryfC/LTL7/z31oiwgifCK+AxEFsUAs` |
| Açık anahtar (base58) | `36MmMXE7Rbkt9LLSFWxiUwHrJvp6y4WLEn349iMRsbL7` |

Program, türettiği açık anahtar bu değerle aynıysa doğru tohum yüklüdür.

## Programın okuyacağı ayar

Tohumu ortam değişkenine koy:

```bash
export ED25519_SEED_HEX="<64 onaltılık karakter, boşluksuz>"
```

Dosyadan okunacaksa yol:

```bash
export ED25519_SEED_FILE="/run/secrets/asam01-ed25519.seed"
```

Dosya biçimi tek satır, boşluksuz hex. İzin `600`. `ED25519_SEED_FILE` doluysa program onu kullanır; boşsa `ED25519_SEED_HEX` okunur.

Bu değerler repoya, günlüğe ve sohbet kaydına yazılmaz.

## Bağlantı akışı

1. Tohumu oku ve uzunluğu 32 bayt mı diye bak.
2. Ed25519 özel anahtarını bu tohumdan kur.
3. Açık anahtarı türet ve yukarıdaki hex ile karşılaştır. Farklıysa oturumu açma.
4. `asam01` tarafının gönderdiği meydan okuma baytlarını bu anahtarla imzala.
5. Bağlantı mesajına açık anahtarı ve imzayı koy. Özel anahtarı mesaja koyma.

Uç nokta, port ve çerçeve biçimi bağlantı programının kendi ayarındadır. Bu not yalnızca kimlik anahtarının o programa nasıl gireceğini sabitler.

## Python

```python
import os
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives import serialization

BEKLENEN_ACIK_ANAHTAR = bytes.fromhex(
    "1f16c1b358c192bbf66af27c2fcb4cbeffcf7d688b08227c22be031105b1402c"
)


def tohumu_oku() -> bytes:
    dosya = os.environ.get("ED25519_SEED_FILE", "").strip()
    if dosya:
        with open(dosya, "r", encoding="utf-8") as f:
            hex_metin = f.read().strip()
    else:
        hex_metin = os.environ.get("ED25519_SEED_HEX", "").strip()
    tohum = bytes.fromhex(hex_metin)
    if len(tohum) != 32:
        raise ValueError("Ed25519 tohumu 32 bayt olmali")
    return tohum


def kimlik_yukle() -> Ed25519PrivateKey:
    anahtar = Ed25519PrivateKey.from_private_bytes(tohumu_oku())
    acik = anahtar.public_key().public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw,
    )
    if acik != BEKLENEN_ACIK_ANAHTAR:
        raise ValueError("yuklenen tohum beklenen acik anahtari uretmiyor")
    return anahtar


def meydan_okumayi_imzala(meydan_okuma: bytes) -> tuple[bytes, bytes]:
    anahtar = kimlik_yukle()
    imza = anahtar.sign(meydan_okuma)
    acik = anahtar.public_key().public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw,
    )
    return acik, imza
```

Bağlantı programı, `asam01` oturumunu açmadan önce `meydan_okumayi_imzala` çıktısını kendi el sıkışma mesajına yazar.

## Doğrulama

Tohum yüklüyken açık anahtar şu komutla beklenen değere eşit çıkmalıdır:

```bash
python3 - << 'PY'
import os
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives import serialization

tohum = bytes.fromhex(os.environ["ED25519_SEED_HEX"])
anahtar = Ed25519PrivateKey.from_private_bytes(tohum)
acik = anahtar.public_key().public_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PublicFormat.Raw,
)
print(acik.hex())
PY
```

Beklenen çıktı:

```text
1f16c1b358c192bbf66af27c2fcb4cbeffcf7d688b08227c22be031105b1402c
```
