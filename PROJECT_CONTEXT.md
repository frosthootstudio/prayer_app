# 🕌 Waktu Shalat — Project Context & Evolution Master Doc
> **Dokumen Master Progres Aplikasi & Konteks AI (Obsidian-Ready)**  
> **Terakhir Diperbarui:** 25 September 2026  
> **Versi Terkini:** `v1.7.4 (Build 43)`  
> **Package ID:** `studio.frosthoot.prayer_app`  
> **Repository:** `frosthootstudio/prayer_app`

---

## 📌 Ringkasan Eksekutif & Tujuan Aplikasi
**Waktu Shalat** adalah aplikasi ibadah harian Muslim yang dirancang dengan prinsip:
1. **100% Offline-First Calculation & Storage**: Menggunakan library pure-Dart `adhan` sehingga perhitungan waktu shalat dan arah kiblat tetap akurat tanpa koneksi internet. Aset tulisan Arab dan font sepenuhnya dibundel lokal tanpa dependensi unduhan jaringan. Murottal audio dan Tafsir Kemenag dapat diunduh/disimpan lokal untuk pemakaian offline sepenuhnya.
2. **Bersih & Nyaman (100% Bebas Iklan)**: Tidak ada iklan yang mengganggu kekhusyukan ibadah.
3. **Design System Konsisten**: UI modern, flat (tidak ada nested-cards berlebihan), tema gelap/terang dinamis, serta navigasi 4 tab utama yang intuitif.

---

## 🏗️ Arsitektur & Tech Stack
- **Framework:** Flutter (SDK `^3.11.0`) & Dart Null-Safety
- **State Management:** `Provider` (`MultiProvider`, `ChangeNotifier`, `Selector`)
- **Penyimpanan Lokal (Database):** `Hive` & `hive_flutter` (box tersanitasi)
- **Kalkulasi Waktu & Kiblat:** `adhan: ^2.0.0` & `flutter_compass: ^0.8.1`
- **Audio & Murottal:** `just_audio` / native playback dengan auto-cache & isolasi posisi pemutaran, plus offline storage cache di application documents directory
- **Cadangan & Berbagi:** `file_picker` & `share_plus` (Ekspor/Impor JSON mandiri)
- **Android Target:** AGP 9.2+, Gradle 9.4.1+, Java 17 bytecode, Android 15 ready

---

## 🗺️ Roadmap & Riwayat Progres Lengkap (Changelog Evolusi)

### 🚀 v1.7.4 (Build 43) — *Current Release*
- **Fitur Backup & Restore Data Lokal (Export/Import JSON):**
  - Ekspor seluruh data pribadi pengguna: rekam checklist ibadah harian (`IbadahTracking`), bookmark surah & ayat Al-Qur'an, preferensi bacaan/ayat terakhir, dzikir favorit, serta pengaturan aplikasi ke format file JSON terstruktur.
  - Berbagi file cadangan secara instan via lembar Share bawaan sistem (dapat disimpan ke Google Drive, WhatsApp, File Manager, Email, dsb).
  - Impor dan pemulihan data dari file JSON cadangan menggunakan `FilePicker` bawaan sistem dengan verifikasi validitas file dan dialog konfirmasi sebelum data diterapkan.
  - Sinkronisasi otomatis reaktif: setelah dipulihkan, seluruh provider (`TrackingProvider`, `QuranProvider`, `SettingsProvider`) langsung memuat ulang data tanpa perlu restart aplikasi.
- **Rebranding Halaman Dukungan Developer (Infaq Operasional Sukarela):**
  - Meredefinisi pesan dukungan menjadi *"Infaq Sukarela & Amal Jariyah"* untuk keberlanjutan pemeliharaan server dan pengembangan aplikasi.
  - Menghilangkan kesan paywall komersial lama ("Hilangkan Iklan"), menegaskan bahwa aplikasi Waktu Shalat **100% gratis dan bebas iklan selamanya** untuk seluruh umat Muslim.
  - Memperbarui ikon dan copywriting menjadi lebih hangat, santun, dan bernuansa islami (`volunteer_activism_rounded`).

### 🚀 v1.7.3 (Build 42)
- **Murottal Offline Storage & Cache:**
  - Kemampuan mengunduh surah audio per qari langsung ke penyimpanan lokal perangkat (`path_provider` + `http`).
  - Pemutaran audio otomatis mendeteksi file lokal sehingga dapat diputar 100% tanpa sambungan internet (`offline playback`).
  - Indikator download real-time dengan progress spinner per surah di daftar surah Murottal.
  - Dialog manajemen/penghapusan audio offline yang diunduh untuk menghemat kapasitas memori HP.
  - Badge visual *"Offline · Tersimpan"* pada card Now Playing saat memutar surah lokal.
- **Tafsir Ringkas Kemenag RI:**
  - Integrasi Tafsir Ringkas resmi Kementerian Agama Republik Indonesia per ayat (diambil dari API Kemenag / equran.id).
  - Caching lokal Hive (`quran_tafsir_cache` dengan TTL 365 hari) sehingga sekali dibuka langsung tersimpan dan dapat dibaca offline kapan saja.
  - Bottom sheet modal Tafsir yang indah, tipografi nyaman dibaca, pratinjau ayat arab & terjemahan, serta tombol salin tafsir sekali sentuh.
  - Tombol akses cepat Tafsir di setiap baris ayat (`_AyahTile`) dan menu aksi sentuh lama.

### 🚀 v1.7.2 (Build 41)
- **Pengingat Puasa Sunnah (Senin - Kamis & Ayyamul Bidh):**
  - Notifikasi otomatis H-1 malam hari (pukul 20:00) untuk puasa Senin, Kamis, dan tanggal 13, 14, 15 Hijriah.
  - Channel notifikasi khusus (`sunnah_fasting_v1`) dan toggle pengaturan di halaman Settings.
  - Banner dinamis di Beranda (Home Screen) yang memberi info hangat saat hari ini atau besok merupakan hari puasa sunnah.
- **Peningkatan Ibadah Tracker:**
  - Perhitungan dan visualisasi **Streak Hari Berturut-turut** (Badge 🔥) pada ringkasan harian.
  - Header statistik 7 hari terakhir dengan persentase kepatuhan mingguan (*weekly completion rate*).
- **Global CalendarProvider:**
  - Pengangkatan `CalendarProvider` ke root `MultiProvider` agar status kalender dan puasa sunnah sinkron di seluruh layar aplikasi.

### 🚀 v1.7.1 (Build 40)
- **Rasionalisasi & Kurasi Font Arab:**
  - Memangkas font redundant (`Amiri` biasa dan `Lateef`).
  - Menyederhanakan pilihan font menjadi 3 opsi kurasi terbaik:
    1. **Scheherazade New** (Standar Kemenag RI / Indonesia — IndoPak)
    2. **Amiri Quran** (Mushaf Madinah — Standar Global Utsmani)
    3. **Noto Naskh** (Modern & Minimalis)
  - Migrasi seluruh rendering teks Arab (termasuk Nama Nabi & Panduan Shalat) ke `ArabicFontHelper` murni offline asset.
  - Penanganan kompatibilitas mundur (fallback otomatis bagi pengguna yang menyimpan opsi font lama).
- **Haptic Feedback Tasbih Digital (Dzikir):**
  - Getaran halus (*light impact*) pada setiap ketukan hitungan dzikir.
  - Getaran konfirmasi (*medium impact*) saat menyelesaikan target dzikir (misal 33x atau 100x).
  - Getaran seleksi (*selection click*) saat mereset hitungan.

### 🚀 v1.7.0 (Build 39)
- **Hapus Iklan Total:** Semua dependensi dan alur penayangan `AdService` dinonaktifkan secara total. Aplikasi bersih 100%.
- **Pilih Lokasi Manual (Offline Tanpa GPS):** Penambahan database koordinat kota/kabupaten se-Indonesia (`lib/data/indonesian_cities_data.dart`) dengan fitur search cepat.
- **Full Page Scroll Home:** Halaman beranda dapat digulir penuh dari atas sampai bawah dengan mempertahankan swipe PageView jadwal shalat harian.
- **Scroll Arabic Font Picker:** Modal dialog pemilihan font di Settings dan Surah Screen kini memiliki batas tinggi dan scroll view responsif.
- **Fix Tombol Rating Play Store:** Penambahan query intent `<queries>` skema `market` & `https` di `AndroidManifest.xml` serta fallback berjenjang di `RatingService`.

### 📖 v1.7.0 (Build 36 - 38)
- **Rekomendasi Surah Pendek & Panduan Shalat:**
  - Pemisahan bacaan shalat universal dari masing-masing jenis shalat agar tidak redundan.
  - Penambahan rekomendasi surah pendek yang dianjurkan beserta keutamaannya di setiap shalat fardhu dan sunnah.
  - Perapihan UI: Menghilangkan nested-card (kotak di dalam kotak) menjadi flat divider, dan posisi badge rakaat diletakkan di atas nama surah.

### 🌟 v1.7.0 (Build 35)
- **Kisah 25 Nabi & Rasul:** Fitur edukatif kisah 25 Nabi & Rasul dengan tampilan ringkas dan hikmah pembelajaran.
- **Panduan Shalat Lengkap:** Modul tata cara shalat wajib, sunnah rawatib, dhuha, tahajud, witir, tarawih, istikharah, dan taubat.

### ⚡ v1.6.0 (Build 33 - 34)
- **Modernisasi Engine Android:** Upgrade Gradle 9.4.1 & Android Gradle Plugin 9.2.0.
- **Qibla Decoupling:** Penggantian plugin pihak ketiga menjadi kalkulasi murni `adhan` + `flutter_compass`.
- **Optimalisasi Performa:**
  - Pemisahan pembaruan posisi murottal agar tidak men-trigger `notifyListeners()` global secara berlebihan.
  - Rekalkulasi widget `NextPrayerCard` hanya saat transisi waktu shalat tiba.

---

## 🎨 Design Rules & Prinsip UI (PENTING UNTUK AI SELANJUTNYA)
Jika melanjutkan pengembangan bersama AI lain, pegang teguh aturan ini:
1. **Warna Aplikasi (Theme Preservation):** JANGAN PERNAH mengubah warna primer/aksen aplikasi tanpa izin pengguna. Gunakan token konteks: `context.appCardBg`, `context.appAccent`, `context.appTextPrimary`.
2. **No Nested Cards:** Hindari membungkus `Card` di dalam `Card`. Gunakan `Container` dengan border lembut atau `Divider` datar.
3. **Standar Kemenag:** Teks transliterasi Al-Qur'an dan latin tetap mempertahankan format standar Indonesia (Kemenag).

---

## 📁 Struktur File Kunci
```text
lib/
├── data/
│   ├── indonesian_cities_data.dart   # Database offline kota & koordinat Indonesia
│   ├── prayer_guide_data.dart        # Data panduan shalat & rekomendasi surah
│   └── prophets_data.dart            # Data kisah 25 Nabi & Rasul
├── providers/
│   ├── prayer_provider.dart          # Perhitungan shalat, auto/manual location
│   ├── quran_provider.dart           # Cache ayat Al-Quran, latin Kemenag, bookmark
│   └── settings_provider.dart        # Preferensi font Arab, tema, notifikasi
├── screens/
│   ├── home_screen.dart              # Beranda (Jadwal shalat, widget qibla, shalat berikutnya)
│   ├── prayer_guide_screen.dart      # Panduan shalat & bacaan
│   ├── settings_screen.dart          # Pengaturan notifikasi, lokasi manual, font Arab
│   └── surah_screen.dart             # Baca Al-Qur'an & audio murottal
└── services/
    ├── ad_service.dart               # Service iklan (Dinonaktifkan total)
    ├── notification_service.dart     # Pengingat adzan & notifikasi
    └── rating_service.dart           # In-app review & redirect Play Store
```

---

## 🤖 Panduan Prompt Siap Pakai untuk AI Baru
Salin teks di bawah ini ke AI baru (ChatGPT, Claude, atau Gemini) jika ingin memulai sesi baru:

```markdown
Halo! Aku sedang mengembangkan aplikasi Flutter bernama "Waktu Shalat" (ID: studio.frosthoot.prayer_app) yang saat ini berada di versi 1.7.2+41.
Berikut adalah file PROJECT_CONTEXT.md yang merangkum arsitektur, riwayat fitur, struktur kode, dan aturan desain aplikasi ini:

[Tempelkan isi file PROJECT_CONTEXT.md di sini]

Mohon pelajari konteks ini sebelum kita melanjutkan task berikutnya.
```
