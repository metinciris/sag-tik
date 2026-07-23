# Windows Sağ Tık Görsel ve PDF Araçları

Windows Gezgini sağ tık menüsüne günlük görsel ve PDF işlemleri ekleyen küçük bir araç setidir.

## Özellikler

- PDF içindeki etiket numaralarını OCR ile okuma
- Gerektiğinde PDF görsellerini 180° döndürme
- JPG, JPEG ve PNG görsellerini AVIF'e dönüştürme
- Bir klasördeki görselleri toplu AVIF'e dönüştürme
- Seçili görsellerden tek PDF oluşturma

> **Uyarı:** AVIF dönüşümü başarıyla tamamlandığında kaynak görsel silinir. Önemli dosyalarda önce yedek alın.

## İndirme

İşletim sisteminize uygun paketi GitHub **Releases** bölümünden indirin:

- `SagTik-Araclari-Windows10-v1.0.zip`
- `SagTik-Araclari-Windows11-v1.0.zip`

Windows 11 paketi, araçların **Daha fazla seçenek göster** altında kalmaması için klasik sağ tık menüsü ayarını da içerir.

## Windows 10

1. ZIP'i çıkarın.
2. `1_Kurulum.cmd` dosyasını çalıştırın.
3. Gerekirse Windows Gezgini'ni yeniden başlatın.

Ayrıntılı açıklama paketin içindeki `README-Windows10.md` dosyasındadır.

## Windows 11

1. `1_Klasik_SagTik_Ac.reg` dosyasını çalıştırın.
2. Windows Gezgini'ni yeniden başlatın.
3. `2_Kurulum.cmd` dosyasını çalıştırın.

Ayrıntılı açıklama paketin içindeki `README-Windows11.md` dosyasındadır.

## Gereksinimler

- Python 3 ve Python Launcher
- Tesseract OCR
- `opencv-python`
- `numpy`
- `pytesseract`
- `PyMuPDF`
- `Pillow`
- `pillow-avif-plugin`

Eksik Python paketlerini yüklemek için:

```bat
py -3 -m pip install opencv-python numpy pytesseract pymupdf pillow pillow-avif-plugin
```

## Kaldırma

Her paketin içinde kaldırma dosyası vardır.

- Windows 10: `2_Kaldir.cmd`
- Windows 11 araçları: `3_Kaldir_SagTik_Araclari.cmd`
- Windows 11 yeni kısa menüsüne dönüş: `4_Windows11_Menusune_Don.reg`

## Gizlilik

Dosyalar yalnızca yerel bilgisayarda işlenir. Herhangi bir sunucuya yükleme yapılmaz.

## Not

Proje kişisel iş akışını kolaylaştırmak amacıyla geliştirilmiş ve yapay zekâ desteğiyle düzenlenmiştir.
