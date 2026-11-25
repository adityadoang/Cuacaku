# CuacaKu — Aplikasi Prakiraan Cuaca Flutter (Responsi Flutter)

Aplikasi prakiraan cuaca berbasis **Flutter & Dart** dengan desain UI/UX ilustratif (latar pemandangan perbukitan dinamis siang/malam/hujan + panel gelombang *Weather Today*), arsitektur **MVVM**, penyimpanan lokal **Hive**, serta integrasi penuh **Open-Meteo REST API**.

---

## Fitur Utama

1. **Home / Weather Screen**
   - Menampilkan nama kota aktif, tanggal & waktu lokal, suhu saat ini (`current.temperature_2m`), dan kondisi cuaca terkini (`current.weather_code`).
   - Latar pemandangan perbukitan ilustratif berubah secara otomatis mengikuti kondisi cuaca dan waktu siang/malam (`current.is_day`).
   - Panel bawah putih bergelombang **Weather Today** menampilkan prakiraan per jam, dan dapat ditarik ke atas (*draggable sheet*) untuk melihat:
     - **Detail Kondisi Saat Ini**: Kelembapan (`current.relative_humidity_2m`), Kecepatan Angin (`current.wind_speed_10m`), Suhu Dirasakan (`current.apparent_temperature`), Curah Hujan (`current.precipitation`), Peluang Hujan Maksimum (`daily.precipitation_probability_max`), dan Suhu Min/Maks Hari Ini.
     - **Prakiraan 7 Hari Ke Depan**: Kondisi harian, peluang hujan maksimum, serta suhu minimum & maksimum harian (`daily.temperature_2m_min` & `daily.temperature_2m_max`).
   - Mendukung tombol favorit langsung, muat ulang data, serta penanganan status *loading*, data kosong, dan *error* jaringan dengan tombol **Coba Lagi**.

2. **Search / Location Screen**
   - Pencarian kota secara langsung ke **Open-Meteo Geocoding API** dengan *debounce* 450 ms.
   - Daftar hasil pencarian menampilkan nama kota dan wilayah/negara.
   - Ketuk lokasi untuk menampilkan data cuacanya di layar utama dan menyimpannya ke riwayat pencarian.
   - Fitur **Lokasi Favorit** dan **Riwayat Pencarian** tersimpan secara persisten menggunakan **Hive** sehingga tetap muncul saat aplikasi dibuka kembali.

---

## Arsitektur Aplikasi (MVVM)

Proyek ini menerapkan pola arsitektur **Model-View-ViewModel (MVVM)** dengan `provider` (`ChangeNotifier`):

```text
lib/
├── main.dart                                # Entry point, inisialisasi Hive & MultiProvider
├── models/                                  # [Model] Representasi data JSON & objek Hive
│   ├── location_model.dart                  # Model lokasi + manual Hive TypeAdapter
│   └── weather_model.dart                   # Model WeatherData, Current, Hourly, Daily
├── services/                                # [Service] Layer akses API & Local Storage
│   ├── weather_api_service.dart             # HTTP GET ke Open-Meteo Forecast & Geocoding
│   └── hive_storage_service.dart            # CRUD Hive (favorit, riwayat, lokasi aktif)
├── viewmodels/                              # [ViewModel] State management & logika bisnis
│   ├── weather_viewmodel.dart               # State cuaca layar utama & daftar favorit
│   └── search_viewmodel.dart                # State pencarian kota & riwayat pencarian
├── views/                                   # [View] Halaman utama aplikasi
│   ├── home_screen.dart                     # Screen 1: Home / Weather Screen
│   └── search_screen.dart                   # Screen 2: Search / Location Screen
├── widgets/                                 # Komponen UI modular & CustomPainter
│   ├── scenic_landscape_background.dart     # Ilustrasi perbukitan dinamis siang/malam
│   ├── wave_bottom_sheet.dart               # Clipper gelombang panel Weather Today
│   ├── weather_icon_widget.dart             # Ikon cuaca minimalis
│   ├── hourly_forecast_strip.dart           # Strip prakiraan per jam
│   └── weather_details_section.dart         # Grid metrik cuaca & prakiraan 7 hari
├── theme/
│   └── app_theme.dart                       # Konfigurasi Material 3 Theme & Typography
└── utils/
    ├── weather_code_helper.dart             # Pemetaan kode cuaca WMO Open-Meteo
    └── date_formatter.dart                  # Formatter tanggal & jam
```

Alur data MVVM:
- **View** (`HomeScreen`, `SearchScreen`) hanya merender UI dan mendengarkan perubahan state dari **ViewModel** melalui `Consumer` / `context.watch`.
- **ViewModel** (`WeatherViewModel`, `SearchViewModel`) memproses aksi pengguna, memanggil **Service**, mengubah data menjadi **Model**, dan memanggil `notifyListeners()`.
- **Service** (`WeatherApiService`, `HiveStorageService`) terpisah dari UI sehingga kode bersih, modular, dan mudah diuji.

---

## Implementasi API (Open-Meteo)

Aplikasi menggunakan metode **HTTP GET** melalui package `http` tanpa memerlukan API key:

1. **Weather Forecast API** — [Dokumentasi Open-Meteo Weather Forecast](https://open-meteo.com/en/docs)
   - Endpoint: `https://api.open-meteo.com/v1/forecast`
   - Parameter utama: `latitude`, `longitude`, `current`, `hourly`, `daily`, `timezone=auto`, `forecast_days=7`
   - Field yang dipetakan ke model Dart:
     - `current.temperature_2m` (Suhu saat ini)
     - `current.relative_humidity_2m` (Kelembapan)
     - `current.apparent_temperature` (Suhu yang dirasakan)
     - `current.precipitation` (Curah hujan)
     - `current.weather_code` (Kode kondisi cuaca)
     - `current.wind_speed_10m` (Kecepatan angin)
     - `current.is_day` (Penentu tema siang/malam)
     - `daily.temperature_2m_max` (Suhu maksimum harian)
     - `daily.temperature_2m_min` (Suhu minimum harian)
     - `daily.precipitation_probability_max` (Peluang hujan maksimum)

2. **Geocoding API** — [Dokumentasi Open-Meteo Geocoding](https://open-meteo.com/en/docs/geocoding-api)
   - Endpoint: `https://geocoding-api.open-meteo.com/v1/search`
   - Parameter utama: `name`, `count=12`, `language=id`, `format=json`

---

## Implementasi Local Storage (Hive)

Penyimpanan lokal menggunakan **`hive`** dan **`hive_flutter`** dengan manual `LocationModelAdapter` (`typeId: 0`) sehingga langsung berjalan tanpa perlu menjalankan `build_runner`:

- `favorites_box`: Menyimpan daftar lokasi favorit pengguna.
- `search_history_box`: Menyimpan maksimal 10 riwayat pencarian terbaru (tanpa duplikasi).
- `selected_location_box`: Menyimpan lokasi terakhir yang dipilih agar otomatis ditampilkan kembali saat aplikasi dibuka ulang.

---

## Cara Menjalankan Proyek

1. Ekstrak file ZIP dan masuk ke folder proyek:
   ```bash
   cd weather_responsi_app
   ```
2. Jika ingin memastikan file wrapper platform Android/iOS/Web sesuai dengan versi Flutter SDK lokal Anda, jalankan (opsional):
   ```bash
   flutter create . --project-name weather_responsi_app
   ```
3. Unduh dependensi:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```
5. Jalankan unit test:
   ```bash
   flutter test
   ```

---

## Screenshot Aplikasi

