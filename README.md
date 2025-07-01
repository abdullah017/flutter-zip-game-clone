# Flutter Zip Clone Game

## Proje Tanımı

Bu proje, popüler bir bulmaca oyununun Flutter ile geliştirilmiş bir klonudur. Oyuncuların amacı, bir ızgara üzerindeki numaraları doğru sırayla birleştirerek tüm ızgarayı doldurmaktır. Oyun, responsive ve adaptif bir kullanıcı arayüzüne sahip olup, çeşitli platformlarda sorunsuz bir deneyim sunar.

## Özellikler

*   **Çoklu Platform Desteği:** Web, Android, iOS, macOS, Linux ve Windows platformlarında sorunsuz çalışır.
*   **Responsive ve Adaptif Tasarım:** Farklı ekran boyutlarına ve cihazlara otomatik olarak uyum sağlayan esnek bir kullanıcı arayüzü.
*   **Dinamik Izgara Boyutu ve Zorluk:** Ayarlar ekranı aracılığıyla ızgara boyutunu (4x4'ten 8x8'e kadar) ve zorluk seviyesini (Kolay, Orta, Zor) seçme imkanı.
*   **Geri Alma/Yineleme Fonksiyonu:** Oyuncuların yanlış hamlelerini geri almalarına veya tekrarlamalarına olanak tanır, bu da oyun deneyimini iyileştirir.
*   **Gelişmiş Izgara Giriş Animasyonları:** Seviye başladığında hücrelerin kademeli olarak "patlayarak" ve "büyüyerek" yerlerine oturmasını sağlayan modern animasyonlar.
*   **Gelişmiş Kazanma/Kaybetme Diyalogları:** Seviye tamamlandığında veya başarısız olunduğunda daha bilgilendirici ve görsel olarak çekici özel diyalog kutuları.
*   **Sağlam Seviye Üretimi:** Çözülebilir seviyeler üretmek için optimize edilmiş seviye oluşturma algoritması.
*   **Provider ile Durum Yönetimi:** Uygulama durumunun temiz, modüler ve sürdürülebilir bir şekilde yönetilmesi için `provider` paketi kullanılmıştır.

## Teknolojiler

*   **Flutter:** Çapraz platform mobil, web ve masaüstü uygulamaları geliştirmek için Google'ın UI araç takımı.
*   **Dart:** Flutter uygulamaları için kullanılan programlama dili.
*   **Provider:** Flutter uygulamalarında durum yönetimi için basit ve ölçeklenebilir bir çözüm.

## Kurulum

Projeyi yerel makinenizde kurmak ve çalıştırmak için aşağıdaki adımları izleyin:

### Önkoşullar

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) yüklü olmalıdır.
*   Tercih edilen bir IDE (Visual Studio Code, Android Studio vb.)

### Adımlar

1.  **Depoyu Klonlayın:**
    ```bash
    git clone https://github.com/your-username/flutter_zip_game.git
    cd flutter_zip_game
    ```
2.  **Bağımlılıkları Yükleyin:**
    ```bash
    flutter pub get
    ```
3.  **Uygulamayı Çalıştırın:**

    *   **Android/iOS:** Bağlı bir cihaz veya emülatör olduğundan emin olun ve çalıştırın:
        ```bash
        flutter run
        ```
    *   **Web:**
        ```bash
        flutter run -d chrome
        ```
    *   **Masaüstü (macOS, Linux, Windows):** Masaüstü desteğini etkinleştirmeniz gerekebilir:
        ```bash
        flutter enable-windows-desktop
        flutter enable-macos-desktop
        flutter enable-linux-desktop
        flutter run -d windows # veya macos, linux
        ```

## Kullanım

Oyunu başlatmak için uygulamayı çalıştırın.

*   **Oynanış:** Izgara üzerindeki numaraları 1'den başlayarak sırayla birleştirin ve tüm ızgarayı doldurun. Parmağınızı veya farenizi hücreler üzerinde sürükleyerek yol çizin.
*   **Geri Al/Yinele:** Alt kısımdaki "Undo" ve "Redo" düğmelerini kullanarak hamlelerinizi geri alabilir veya tekrarlayabilirsiniz.
*   **Yeni Oyun:** "New Game" düğmesine basarak yeni bir seviye başlatın.
*   **İpucu:** "Hint" düğmesine basarak bir sonraki doğru hamle için ipucu alın.
*   **Ayarlar:** Uygulama çubuğundaki dişli simgesine tıklayarak ayarlar ekranına gidin. Burada ızgara boyutunu ve zorluk seviyesini değiştirebilirsiniz.

## Proje Yapısı

```
flutter_zip_game/
├── lib/
│   ├── main.dart             # Uygulamanın ana giriş noktası ve tema tanımları
│   ├── models/               # Veri modelleri (GameState, GridCell, PathPoint, GameSettings)
│   │   ├── game_state.dart
│   │   ├── game_settings.dart
│   │   └── game_state_notifier.dart # Oyun durumunu yöneten ChangeNotifier
│   ├── services/             # Oyun mantığı ve yardımcı servisler (LevelGenerator, HintSystem, PathValidator)
│   ├── screens/              # Farklı ekranlar (SettingsScreen)
│   ├── utils/                # Yardımcı fonksiyonlar ve sabitler (constants.dart, extensions.dart)
│   └── widgets/              # Yeniden kullanılabilir UI bileşenleri (GameGrid, GridCellWidget, PathPainter, GameUI)
├── web/                      # Web platformuna özgü dosyalar
├── android/                  # Android platformuna özgü dosyalar
├── ios/                      # iOS platformuna özgü dosyalar
├── macos/                    # macOS platformuna özgü dosyalar
├── linux/                    # Linux platformuna özgü dosyalar
├── windows/                  # Windows platformuna özgü dosyalar
├── pubspec.yaml              # Proje bağımlılıkları ve meta verileri
└── README.md                 # Bu dosya
```

## Ekran Görüntüleri

<img src="https://github.com/user-attachments/assets/0132b53c-359a-4bb9-8fcc-80719e61a30c" width="350" alt="accessibility text">
<img src="https://github.com/user-attachments/assets/c101ca30-1d9d-49af-a58d-03e7d6128040" width="350" alt="accessibility text">
<img src="https://github.com/user-attachments/assets/00b68f15-a5a3-4a86-b226-192d5a0d8cda" width="350" alt="accessibility text">
<img src="https://github.com/user-attachments/assets/26c4d1e4-7c48-4208-8193-e1a51cbc3497" width="350" alt="accessibility text">

## Katkıda Bulunma

Katkılarınızı memnuniyetle karşılarız! Herhangi bir hata bulursanız veya yeni bir özellik önermek isterseniz, lütfen bir "issue" açın veya bir "pull request" gönderin.

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için `LICENSE` dosyasına bakın.

---
