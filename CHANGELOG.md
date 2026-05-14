# Changelog — Waktu Shalat

## [1.5.0+25] — 2026-05-14

> **Catatan:** rilis ini menggabungkan beberapa perubahan internal yang
> sebelumnya direncanakan terpisah (1.2.3 hardening + 1.3.0 deps +
> 1.4.0 font). Tidak ada rilis publik antara 1.2.2+21 → 1.5.0+25;
> versi tengah dilewati untuk konsistensi nomor build.

### Fitur Baru

- **Font Arab "Amiri Quran"** — opsi baru di Pengaturan → Font Arab,
  gaya mushaf Madinah (Naskh khusus Al-Qur'an). Memenuhi permintaan
  pengguna untuk opsi Uthmani yang lebih dekat dengan cetakan Mushaf
  Madinah. Font Amiri biasa tetap tersedia untuk teks Arab umum.
- **Tombol "Coba Lagi" di Kiblat** — jika sensor kompas pernah gagal
  berulang dan otomatis dinonaktifkan, kini ada cara untuk mengaktifkan
  ulang setelah kalibrasi (gerakan angka 8). Sebelumnya harus hapus
  data aplikasi.

### Perbaikan Stabilitas

- **Crash Kiblat (Azimuth NaN)** ditangkap di layer global sebelum
  menjadi crash fatal — sebelumnya tetap masuk Crashlytics meski sudah
  ada filter di level layar. Tidak lagi menurunkan tingkat
  crash-free secara tidak adil.
- **Pelaporan error non-fatal ke Crashlytics** untuk Kiblat, AdMob,
  IAP, dan inisialisasi notifikasi — sebelumnya error dalam blok
  try/catch hanya muncul di log debug, jadi tidak terlihat di
  dashboard produksi.
- **Restore pembelian Premium** lebih cepat di jaringan lambat (dari
  5 detik tetap menjadi rata-rata <1 detik via Completer pattern,
  dengan timeout 15 detik). Memperbaiki kasus "Premium hilang setelah
  install ulang" di pengguna jaringan lemot.
- **Iklan App Open** tidak lagi muncul pada saat aplikasi masih
  menghitung jadwal shalat (race condition di cold start) — pengaman
  extra untuk memastikan iklan tidak pernah muncul saat azan.

### Pemeliharaan Internal

- Layar diagnostik tersembunyi di Pengaturan → Tentang → ketuk versi
  5 kali. Untuk dukungan teknis: tampilkan status izin, sensor,
  AdMob, IAP, dan info perangkat. Tombol "Salin ke Clipboard".
- Update dependency utama:
  - Firebase (Core 4, Analytics 12, Crashlytics 5)
  - Google Mobile Ads SDK (5 → 8)
  - share_plus (10 → 13)
  - geocoding, package_info_plus, dll
- Migrasi ke "built-in Kotlin" Flutter (menghapus deklarasi Kotlin
  Gradle Plugin yang redundan, persiapan kompatibilitas Flutter
  versi mendatang)
- Penghapusan kode mati: `PrayerForegroundService.kt` (dinonaktifkan
  sejak 1.2.1+20) dan `CLAUDE_CONTEXT.md` lama

---

## [1.1.1] — 2026-04-26

### Perbaikan
- Al-Qur'an: teks ayat sekarang menggunakan encoding Uthmani lengkap (Mushaf Madinah) — sama persis dengan corpus dzikir
  - Ditambahkan: alef wasla (ٱ), small waw (ـۥ), small ya (ـۦ), Uthmani sukun (ۡ), superscript alef (ٰ), tanda madd, bentuk tanwin khusus, tanda waqaf
  - Sumber: `api.quran.com/api/v4/quran/verses/uthmani` per surat, di-cache di Hive (`quran_uthmani_cache`, TTL 1 tahun)
  - Fallback ke teks `quran` package jika fetch pertama gagal saat offline
- Pemilih font Arab di Pengaturan kini benar-benar berfungsi di layar Al-Qur'an (sebelumnya picker terabaikan karena style inheritance dari `Theme.textTheme`)
  - Perbaikan di `ArabicFontHelper.getStyle`: `inherit: false`, eksplisit `package: null`, `fontFamilyFallback: const []`
  - Wrap `Text` ayat dengan `Selector<SettingsProvider>` agar rebuild langsung saat font/size diganti

### Catatan
- Versi 1.0.6 — 1.1.0 belum ter-dokumentasi di changelog ini; akan di-backfill di rilis terpisah jika diperlukan.

---

## [1.0.5] — 2026-03-16

### Perbaikan
- Fix notifikasi otomatis: request izin baterai & alarm eksak saat onboarding (halaman 4 baru)
- Tambah `PermissionService` — cek & request notifikasi, baterai tidak dibatasi, alarm tepat waktu
- Deteksi MIUI/HyperOS (Build.MANUFACTURER) untuk tampilkan panduan kunci recent apps hanya di Xiaomi
- Banner peringatan di beranda jika izin notifikasi belum lengkap; tap untuk perbaiki via bottom sheet
- Tambah tombol "Test Notifikasi Sekarang" di Pengaturan → jadwalkan notifikasi 10 detik ke depan
- Bagian MIUI/HyperOS di Pengaturan kini hanya muncul pada perangkat Xiaomi
- Transliterasi latin Al-Quran kini tersedia untuk semua 114 surah (fetch dari API alquran.cloud, di-cache per surah)

---

## [1.0.4] — 2026-03-09

### Perubahan / Changes

**Navigasi Android (Edge-to-Edge)**
- Perbaikan konten tertutup navigation bar 3-tombol di Android
- Aktifkan mode edge-to-edge: Flutter menggambar hingga tepi layar, navigation bar transparan
- Bottom sheet (Tema, Bahasa, Metode Kalkulasi, dll.) kini tidak lagi terpotong oleh navigation bar
- Gunakan `MediaQuery.viewPaddingOf` (inset fisik jendela) sebagai padding bawah yang andal, menggantikan `SafeArea` yang bisa bernilai nol di konteks route modal
- `WindowCompat.setDecorFitsSystemWindows(window, false)` di Kotlin agar sistem tidak memaksa layout di atas navigation bar

---

## [1.0.3] — 2026-03-07

### Perubahan / Changes

**Tampilan Home**
- Hapus tombol panah kiri/kanan dari header tanggal — tampilan lebih bersih
- Loading spinner hanya muncul saat pertama kali buka (belum ada data); jika data tersimpan, waktu shalat langsung tampil tanpa spinner

**Performa Startup**
- Waktu shalat kini ditampilkan secara instan menggunakan koordinat GPS yang di-cache
- GPS baru di-refresh di background; kalkulasi ulang hanya dilakukan jika posisi berubah >0.01°

**Murottal Player**
- Layout player dipadatkan: padding card dikurangi, jarak antar elemen lebih rapat
- Daftar surah sekarang mendapat 55% tinggi layar (vs player 45%) — lebih banyak surah terlihat

**Koreksi Waktu (Pengaturan)**
- Ganti slider global "Koreksi Waktu" dengan koreksi per-waktu shalat
- Setiap waktu (Subuh, Dzuhur, Ashar, Maghrib, Isya) bisa diatur sendiri: -10 s/d +10 menit (tombol [-] / [+])
- Disimpan per-waktu di Hive; langsung berlaku tanpa restart

---

## [1.0.1] — 2026-02-xx

### Perubahan / Changes

- Perbaikan akurasi waktu shalat metode Kemenag: tambah ihtiyaat 2 menit + pembulatan ke atas (ceil)
- Tambah izin `SCHEDULE_EXACT_ALARM` di runtime untuk Android 12+
- Ganti `USE_EXACT_ALARM` (dibatasi Play Store) dengan `SCHEDULE_EXACT_ALARM`
- Target SDK ditingkatkan ke 36

---

## [1.0.0] — 2026-02-xx

### Rilis Pertama / Initial Release

- Kalkulasi waktu shalat offline (Kemenag, MWL, Egyptian, ISNA, Umm Al-Qura)
- Notifikasi adzan harian (awesome_notifications, repeating exact alarm)
- Pengingat pra-adzan (-5 s/d -30 menit)
- Arah kiblat (kompas live)
- Kalender Hijriah + peristiwa Islam
- Al-Qur'an (114 surah, terjemahan Indonesia, murottal streaming)
- Dzikir & Doa (40 item, favorit)
- Pelacak ibadah harian
- Widget layar beranda (2x2 dan 4x2)
- Dukungan tema terang/gelap/sistem
- Bahasa Indonesia & Inggris
- Foreground service keepalive untuk MIUI/HyperOS
