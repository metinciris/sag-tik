# sag-tik

# Windows Sağ Tık Görsel ve PDF Araçları

Windows Gezgini sağ tık menüsüne, günlük görsel ve PDF işlemlerini hızlandıran küçük araçlar ekler.

Bu proje; PDF içindeki etiketli görselleri ayıklamak, görselleri AVIF biçimine dönüştürmek ve seçili görsellerden tek PDF oluşturmak için hazırlanmıştır. Tüm işlemler bilgisayarda yerel olarak yapılır; dosyalar herhangi bir sunucuya yüklenmez.

> Araçlar günlük iş akışındaki ihtiyaçlardan doğmuş ve yapay zekâ desteğiyle geliştirilmiştir.

## Özellikler

### 1. PDF etiketlerini oku ve görselleri döndür

PDF dosyasına sağ tıklayınca:

```text
Etiketleri oku ve resimleri döndür
```

Araç:

* PDF'nin her sayfasındaki en büyük gömülü görseli çıkarır.
* Sarı etiket üzerindeki kırmızı rakamları OCR ile okumaya çalışır.
* Etiket normal yönde okunamazsa görseli 180 derece döndürerek tekrar dener.
* Okunan etiket numarasını görselin dosya adı olarak kullanır.
* Çıktıları PDF ile aynı konumda, PDF adıyla oluşturulan klasöre kaydeder.
* Hafif ton, kontrast ve renk düzenlemesi uygular.

Varsayılan geçerli etiket aralığı:

```text
1000–45000
```

### 2. Görselleri AVIF'e dönüştür

JPG, JPEG veya PNG dosyasına sağ tıklayınca:

```text
AVIF'e dönüştür (orijinali sil)
```

Klasöre sağ tıklayınca:

```text
Klasördeki görselleri AVIF'e dönüştür (orijinalleri sil)
```

Varsayılan AVIF profili:

```text
Kalite: 40
Hız: 3
Alt örnekleme: 4:2:0
Kodlayıcı: Otomatik
```

Dönüşüm sırasında geçici dosya kullanılır. Kaynak JPG, JPEG veya PNG dosyası **yalnızca AVIF dosyası başarıyla oluşturulduktan sonra silinir**.

Klasör işlemi yalnızca seçilen klasörün doğrudan içindeki görselleri işler; alt klasörlere girmez.

### 3. Seçili görsellerden tek PDF oluştur

Bir veya birden fazla JPG, JPEG ya da PNG dosyasını seçip sağ tıklayın:

```text
Seçili görsellerden tek PDF oluştur
```

Araç:

* Görselleri dosya adına göre doğal sıraya dizer.
* PNG şeffaflığını beyaz zemin üzerine dönüştürür.
* Her görseli ayrı PDF sayfası yapar.
* PDF'yi ilk seçilen görselle aynı klasöre kaydeder.

Örnek çıktı:

```text
Gorseller_23_07_2026__15_30_45.pdf
```

## Windows uyumluluğu

* **Windows 10:** Kullanım için hazırlanmış ve denenmiştir.
* **Windows 11:** Aynı kayıt defteri tabanlı klasik sağ tık mekanizmasıyla uyumlu olması beklenir.

Windows 10'da araçlar klasik sağ tık menüsünde doğrudan görünür.

Windows 11'in yeni kısa sağ tık menüsünde araçlar genellikle:

```text
Daha fazla seçenek göster
```

bölümünün altında yer alır. Klasik menü doğrudan `Shift + F10` ile de açılabilir.

## Gereksinimler

### Yazılımlar

* Python 3
* Tesseract OCR

Tesseract'ın Windows `PATH` değişkeninden erişilebilir olması gerekir.

Kontrol etmek için Komut İstemi'nde:

```bat
tesseract --version
```

komutunu çalıştırabilirsiniz.

### Python paketleri

```text
opencv-python
numpy
pytesseract
PyMuPDF
Pillow
pillow-avif-plugin
```

Paketleri yüklemek için:

```bat
py -m pip install opencv-python numpy pytesseract pymupdf pillow pillow-avif-plugin
```

Kurulum aracı, gerekli paketleri içeren uygun Python kurulumunu otomatik olarak arar. Gerekli Python veya modüller bulunamazsa kayıt defteri menüleri kurulmaz ve açıklayıcı bir hata mesajı gösterilir.

## Kurulum

1. Projenin ZIP paketini indirin.
2. ZIP'in **tamamını** bir klasöre çıkarın.
3. `Kurulum.vbs` dosyasına çift tıklayın.
4. Kurulum sonucu bir mesaj kutusunda gösterilir.
5. Menüler hemen görünmezse Windows Gezgini'ni yeniden başlatın.

Windows Gezgini'ni yeniden başlatmak için:

1. `Ctrl + Shift + Esc` ile Görev Yöneticisi'ni açın.
2. **Windows Gezgini** satırını bulun.
3. Sağ tıklayıp **Yeniden başlat** seçeneğini kullanın.

Kurulum:

* Yönetici yetkisi istemez.
* Yalnızca mevcut Windows kullanıcısı için yapılır.
* Araç dosyalarını şu klasöre kopyalar:

```text
%LOCALAPPDATA%\MetinBasitSagTik
```

* Sağ tık menülerini `HKEY_CURRENT_USER` altında oluşturur.
* Kullanım sırasında PowerShell veya CMD penceresi göstermez.

## Kaldırma

`Kaldir.vbs` dosyasına çift tıklayın.

Kaldırma işlemi:

* Eklenen sağ tık menülerini siler.
* `%LOCALAPPDATA%\MetinBasitSagTik` klasöründeki kurulu araç dosyalarını kaldırır.
* Python, Tesseract veya kullanıcı dosyalarına dokunmaz.

## Proje dosyaları

| Dosya                   | Görevi                                                             |
| ----------------------- | ------------------------------------------------------------------ |
| `Kurulum.vbs`           | Kurulumu görünür konsol penceresi olmadan başlatır                 |
| `Kurulum.ps1`           | Python ortamını kontrol eder, dosyaları kopyalar ve menüleri ekler |
| `Kaldir.vbs`            | Kaldırma işlemini görünür konsol penceresi olmadan başlatır        |
| `Kaldir.ps1`            | Sağ tık kayıtlarını ve kurulu dosyaları kaldırır                   |
| `Pdf_Etiket_SagTik.pyw` | Sağ tıklanan PDF'yi etiket işleme motoruna gönderir                |
| `pdf_core.py`           | PDF görsellerini çıkarır, OCR yapar, döndürür ve kaydeder          |
| `AVIF_SagTik.pyw`       | Seçili görsel veya klasördeki görseller için dönüşümü yönetir      |
| `avif_core.py`          | AVIF kodlama ve dosya işlemlerini gerçekleştirir                   |
| `Gorsellerden_PDF.pyw`  | Seçili görsellerden çok sayfalı PDF oluşturur                      |

## Önemli uyarılar

### AVIF dönüşümü kaynak dosyaları siler

AVIF menüsünün adı özellikle bunu belirtir:

```text
AVIF'e dönüştür (orijinali sil)
```

Önemli veya tek kopya olan görsellerde kullanmadan önce yedek alın.

### OCR her etiketi okuyamayabilir

Başarı; etiket rengi, rakamların görünürlüğü, görüntü kalitesi, eğim ve PDF'nin yapısına bağlıdır. Okunamayan görseller sayfa adıyla kaydedilebilir.

### PDF işleme gömülü görsele göre çalışır

Araç, her sayfadaki en büyük gömülü görseli seçer. Karmaşık yerleşimli veya bir sayfada birden fazla eşit büyüklükte görsel bulunan PDF'lerde beklenen görsel seçilemeyebilir.

## Sorun giderme

### Menü görünmüyor

* Windows Gezgini'ni yeniden başlatın.
* Windows 11'de **Daha fazla seçenek göster** bölümüne bakın.
* ZIP'in tamamının aynı klasöre çıkarıldığını kontrol edin.
* `Kurulum.vbs` dosyasını yeniden çalıştırın.

### Python bulunamadı

Komut İstemi'nde:

```bat
py -0p
```

komutuyla kurulu Python sürümlerini kontrol edin.

### Tesseract bulunamadı

Komut İstemi'nde:

```bat
tesseract --version
```

çalışmıyorsa Tesseract kurulumunu ve `PATH` ayarını kontrol edin.

### AVIF dönüştürme başlamıyor

Aşağıdaki komut hata vermeden çalışmalıdır:

```bat
py -c "from PIL import Image; import pillow_avif; print('AVIF hazır')"
```

### PDF etiket işlemi başlamıyor

Aşağıdaki komut hata vermeden çalışmalıdır:

```bat
py -c "import cv2, numpy, pytesseract, fitz; print('PDF aracı hazır')"
```

## Gizlilik

* Dosyalar yalnızca yerel bilgisayarda işlenir.
* İnternete dosya gönderilmez.
* Herhangi bir kullanıcı hesabı veya API anahtarı gerekmez.

## Sorumluluk reddi

Bu proje kişisel iş akışını kolaylaştırmak amacıyla hazırlanmıştır. Özellikle kaynak görselleri silen AVIF dönüşümünü kullanmadan önce önemli dosyaların yedeğini alın. Kullanıcı, oluşturulan çıktıların doğruluğunu ve bütünlüğünü kontrol etmelidir.
