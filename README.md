# FinansHome 💰

FinansHome, kişisel finans yönetiminizi kolaylaştıran, modern ve kullanıcı dostu bir Flutter uygulamasıdır. Gelir, gider ve borçlarınızı takip edin, finansal durumunuzu görselleştirin.

## 📱 Özellikler

- **Gelir Yönetimi**: Tüm gelirlerinizi kategorize ederek ekleyin ve takip edin
- **Gider Takibi**: Harcamalarınızı detaylı bir şekilde kaydedin ve analiz edin
- **Borç Yönetimi**: Borçlarınızı ve ödeme planlarınızı yönetin
- **Görselleştirme**: Gelir, gider ve borç dağılımınızı grafiklerle görüntüleyin
- **Finansal Özet**: Toplam bakiye, kullanılabilir para ve borç durumunuzu anlık görün
- **Çapraz Platform**: Android, iOS, Windows, macOS, Linux ve Web desteği
- **Yerel Veritabanı**: SQLite ile verileriniz cihazınızda güvenle saklanır

## 🏗️ Mimari

Proje, MVC (Model-View-Controller) mimarisine göre organize edilmiştir:

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── controllers/              # İş mantığı ve state yönetimi
│   └── home_controller.dart
├── models/                   # Veri modelleri
│   ├── budget_state.dart
│   ├── finance_model.dart
│   └── transaction_models.dart
├── service/                  # Veritabanı servisleri
│   └── db_service.dart
├── utils/                    # Yardımcı fonksiyonlar
│   ├── constants.dart
│   └── formatters.dart
└── views/                    # UI bileşenleri
    ├── home_view.dart
    ├── components/           # Yeniden kullanılabilir widget'lar
    └── dialogs/              # Dialog bileşenleri
```

## 🛠️ Teknolojiler

- **Flutter**: Cross-platform UI framework
- **Provider**: State management çözümü
- **SQLite**: Yerel veritabanı yönetimi
- **sqflite_common_ffi**: Masaüstü platform desteği
- **UUID**: Benzersiz kimlik oluşturma
- **Material Design 3**: Modern UI tasarımı

## 📦 Kurulum

### Gereksinimler

- Flutter SDK (3.9.2 veya üzeri)
- Dart SDK
- Android Studio / Xcode (mobil geliştirme için)
- Visual Studio (Windows geliştirme için, opsiyonel)

### Adımlar

1. **Projeyi indirin**:

2. **Bağımlılıkları yükleyin**:
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**:
```bash
# Tüm platformlar için
flutter run

# Belirli bir platform için
flutter run -d windows
flutter run -d android
```

## 🚀 Platform Desteği

| Platform | Durum | Notlar |
|----------|-------|--------|
| Android  | ✅    | API 21+ |
| iOS      | ✅    | iOS 12+ |
| Windows  | ✅    | Windows 10+ |


## 📱 Kullanım

### Temel İşlemler

1. **Gelir Ekleme**
   - Ana ekrandaki ➕ butonuna tıklayın
   - "Gelir Ekle" seçeneğini seçin
   - Tutar, kategori ve açıklama girin
   - Kaydedin

2. **Gider Ekleme**
   - ➕ butonu → "Gider Ekle"
   - Harcama detaylarını girin
   - Kategori seçin (Kira, Market, Fatura, vb.)
   - Kaydedin

3. **Borç Yönetimi**
   - ➕ butonu → "Borç Ekle"
   - Borç tutarı ve aylık ödeme miktarını girin
   - Borç ödemesi yapın
   - Ödeme geçmişini görüntüleyin

4. **Görüntüleme ve Analiz**
   - Ana ekranda finansal özetinizi görün
   - Daire grafikte gelir/gider/borç dağılımını inceleyin
   - Detaylı listeleri tab'ler üzerinden görüntüleyin

### Gelir Kategorileri
- 💼 Maaş
- 💻 Freelance
- 📈 Yatırım
- 🎁 Diğer

### Gider Kategorileri
- 🏠 Kira
- 🛒 Market
- 📄 Fatura
- 🎮 Eğlence
- 🚗 Ulaşım
- 🏥 Sağlık
- 📚 Eğitim
- 🍽️ Diğer

## 🎨 Özelleştirme

### Tema Renkleri
Ana renk şeması `lib/main.dart` dosyasından değiştirilebilir:
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
```

### Sabitler
Kategori isimleri ve diğer sabitler `lib/utils/constants.dart` dosyasında tanımlıdır.

## 🗄️ Veritabanı Yapısı

Uygulama SQLite kullanarak şu tabloları yönetir:

- **incomes**: Gelir kayıtları (id, title, amount, category, date, description)
- **expenses**: Gider kayıtları (id, title, amount, category, date, description)
- **debts**: Borç kayıtları (id, debtorName, totalDebt, monthlyPayment, remainingDebt, date)
- **debt_payments**: Borç ödemeleri (id, debtId, amount, date)
- **transaction_logs**: İşlem geçmişi (id, type, description, amount, timestamp)

## 💡 Akıllı Özellikler

### Otomatik Hesaplamalar
- ✅ Aylık gelir/gider dengesi
- ✅ Kullanılabilir para hesaplama
- ✅ Borç ödeme tahmini (kaç ayda bitecek)
- ✅ Tasarruf önerisi (%20 kural)

### Bilgilendirme Mesajları
- "Bu ay gelirden X₺ gider çıktı, Y₺ borç ödeyebilirsin"
- "Bu hızla giderse borcun N ayda bitecek"
- "Kalan paran X₺, istersen Y₺ kenara ayır"


## 🙏 Teşekkürler

Bu projeyi kullandığınız için teşekkürler! Beğendiyseniz ⭐ vermeyi unutmayın.

