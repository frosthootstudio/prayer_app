# Monetization Roadmap — Waktu Shalat (Q3 2026)

> **Period:** Mei 2026 — Juli 2026 (3 bulan)
> **Status:** Draft v1 — 2026-04-26
> **Author:** Frosthoot Studio (Babah)
> **App version at start:** 1.1.1+11 (Play Store live)

---

## TL;DR (1 paragraf)

Dalam 3 bulan, target: ubah Waktu Shalat dari aplikasi gratis tanpa pendapatan jadi aplikasi yang menghasilkan revenue stabil dari **3 sumber**: **App Open Ad saja** (ditampilkan saat user buka aplikasi — TIDAK ADA ads di dalam app), premium IAP one-time (Rp 49k–79k) untuk hilangkan App Open Ad + bonus features, dan donasi sukarela ("Dukung Pengembang"). Sponsorship outreach jalan paralel sebagai jangka menengah. **Subscription tidak masuk roadmap ini** sesuai keputusan kamu — pasar Indonesia lebih suka one-time, dan subscription bikin overhead (refund, billing dispute) yang nggak cocok untuk solo dev.

**Target Q3 2026:** ARPU minimum Rp 300/user/bulan dari kombinasi 3 sumber (target lebih konservatif karena ads cuma App Open, bukan in-app), tanpa menurunkan rating Play Store di bawah 4.5★.

**Update 2026-04-26:** Ads strategy di-revisi dari "strategic in-app ads" jadi **App Open Ad only**. Alasan: keputusan kamu prioritaskan UX dalam app yang clean, dan sensitivitas religius user untuk app Islami. Trade-off: revenue lebih kecil tapi reputasi & rating jauh lebih aman.

---

## Prinsip Pemandu (Non-Negotiable)

Sebelum membuka tiap kotak monetisasi, ingat 5 prinsip ini. Kalau ada keputusan yang melanggar salah satu, **tunda atau batalkan**:

1. **Fitur ibadah inti TIDAK boleh di-paywall.** Waktu shalat, kiblat, Al-Quran (teks + terjemahan), dzikir basic — selamanya gratis. Ini kewajiban religius user, bukan komoditas.

2. **Tidak ada ads di dalam app.** Hanya App Open Ad (saat user buka aplikasi dari cold start atau resume dari background). Begitu masuk app, ZERO ads di semua screen — Quran, dzikir, kiblat, doa, home, settings, semuanya bersih. Pelanggaran prinsip ini = rating drop massif + reputasi rusak permanen.

3. **Halal-conscious ad filtering.** AdMob category blocklist wajib: alkohol, perjudian, kencan, asuransi konvensional (riba), pinjaman online, konten dewasa. Lebih baik fill rate turun daripada show ad haram.

4. **Solo-maintainable.** Kalau monetisasi method butuh backend kompleks, customer support harian, atau sertifikasi PCI — skip. Stick to AdMob + Google Play Billing one-time products.

5. **Transparency dengan user.** Setiap monetisasi muncul, kasih konteks pendek. Donation button dapat tooltip "100% untuk biaya server & development", premium tier dapat penjelasan jelas apa yang didapat.

---

## Baseline yang Harus Diketahui Dulu (Pre-Roadmap)

Sebelum mulai eksekusi, kamu harus tahu **angka dasar**. Tanpa ini, roadmap-nya buta. Cek di Play Console + Firebase Analytics:

| Metrik | Cara cek | Kenapa penting |
|---|---|---|
| Total install | Play Console → Statistics → Installers | Skala potensial revenue |
| Active install | Play Console → Statistics → Active devices | Lebih akurat dari total install |
| DAU / MAU | Firebase Analytics → Users → Active | Dasar perhitungan ARPU |
| D1 / D7 / D30 retention | Firebase Analytics → Retention | Indikator kualitas produk |
| Avg session duration | Firebase Analytics → Engagement | Slot ads yang realistis |
| Top 5 screens by time spent | Firebase Analytics → Screens | Kandidat slot ads & premium |
| Crash-free user rate | Crashlytics | HARUS ≥99% sebelum monetisasi |
| Current rating + reviews count | Play Console → Ratings | Baseline untuk track regression |

**Kalau Firebase Analytics belum di-setup**, itu **TASK PALING PERTAMA Bulan 1**. Semua keputusan monetisasi nge-blank tanpa data ini.

---

## Bulan 1: FOUNDATION (Mei 2026)

**Tema:** Bangun infrastruktur observability + setup SDK monetisasi. **Belum show ads atau jual apa-apa.**

### Ship 1: Firebase Analytics + Crashlytics (Minggu 1)

- Add `firebase_core`, `firebase_analytics`, `firebase_crashlytics` ke pubspec.yaml
- Setup project di Firebase Console (link ke Play Console untuk auto-import)
- Instrument event penting:
  - `screen_view` (otomatis dari `firebase_analytics`)
  - `prayer_time_viewed` (custom)
  - `quran_surah_opened` (custom, with surah_number)
  - `quran_ayah_bookmarked` (custom)
  - `dzikir_completed` (custom, with category)
  - `qibla_opened` (custom)
  - `settings_opened` (custom)
- Test event di DebugView Firebase
- Update privacy policy: tambahin section data analytics
- **Ship as 1.1.2+12** (small patch release, low risk)

### Ship 2: Privacy Policy & Halal Compliance Pages (Minggu 2)

- Update Privacy Policy untuk mention: Firebase Analytics data, AdMob (akan datang), IAP (akan datang)
- Tambahin "About" page yang menjelaskan Frosthoot Studio + dukungan pengembang
- Halaman "Why ads?" yang akan ditunjukkan SAAT user lihat ads pertama kali — explain ads halal-filtered + tidak di area ibadah
- Hosting privacy policy di GitHub Pages atau Notion public page (gratis, tinggal link dari app)
- **Tidak perlu rilis APK terpisah** — bundle ke ship berikutnya

### Ship 3: AdMob SDK Integration (Minggu 3, scaffolding only)

- Buat akun AdMob (kalau belum), setup app + 3 ad units: banner, interstitial, native
- Add `google_mobile_ads` ke pubspec.yaml
- Initialize SDK di `main.dart` — TAPI: implement feature flag `adsEnabled = false` di SettingsProvider
- Build helper class `AdService` dengan:
  - Method `loadBanner()`, `loadInterstitial()`, `loadNative()`
  - Category blocklist (lihat prinsip #3): `alcohol`, `gambling`, `dating`, `personal_loans`, `predatory_lending`
  - Method `isPrayerTime()` — return true kalau sekarang dalam window -15min sampai +15min dari waktu shalat aktif
- Test dengan AdMob test ad units (jangan production ad unit, biar ga ke-flag invalid traffic)
- Belum show ads di UI manapun

### Ship 4: Google Play Billing Setup (Minggu 4)

- Add `in_app_purchase` ke pubspec.yaml (official Flutter package)
- Setup di Play Console:
  - 1 non-consumable: `premium_unlock` (placeholder Rp 49.000)
  - 5 consumable untuk donasi: `donate_10k`, `donate_25k`, `donate_50k`, `donate_100k`, `donate_custom` (custom amount nanti pakai purchase flow biasa)
- Build `PurchaseService` provider dengan:
  - Restore purchase pada app start
  - Listen purchase stream
  - Persist `isPremium` state di Hive
- Belum tampilkan UI purchase apa-apa
- Test pakai license testing (set tester di Play Console)

**Bulan 1 Output:**
- Analytics jalan, data mulai terkumpul
- AdMob & IAP SDK siap, tinggal nyalain
- Foundation untuk Bulan 2 & 3 udah aman

---

## Bulan 2: ADS + DONASI (Juni 2026)

**Tema:** Aktifkan revenue stream pertama. Mulai dapat duit, mulai punya data konversi.

### Ship 5: App Open Ad Only (Minggu 5-6)

**Konsep:** Hanya 1 jenis ad — App Open Ad — yang muncul SEBELUM user masuk ke home screen. Setelah masuk app, zero ads di semua screen.

**Trigger kapan ad muncul:**
- **Cold start** — saat user buka app dari kondisi tertutup
- **Warm resume** — saat user kembali dari background (misal habis dari WhatsApp, balik ke prayer app)

**Frequency cap (HARUS):**
- Minimum interval: **4 jam antara dua ad**. Kalau user buka app 5x dalam 1 jam, hanya yang pertama yang dapat ad.
- Maksimum: **3 ads per hari per user**.
- TIDAK pernah saat dalam window prayer time (`isPrayerTime()` true → skip ad bahkan jika cooldown sudah lewat).
- TIDAK pernah saat first install dalam 24 jam (biarkan user kenalan dulu).
- TIDAK untuk premium user.

**Loading & UX:**
- Pre-load ad di background sambil splash screen jalan, biar user tidak nunggu loading ad
- Kalau ad belum loaded saat user mau masuk app, **skip** (don't block UX)
- Max wait time: 4 detik, lalu skip
- Setelah ad ditutup user, langsung masuk home screen (no extra delay)

**Implementation notes:**
- Pakai `google_mobile_ads` package, class `AppOpenAd`
- `AdService.maybeShowAppOpenAd()` cek: `isPremium`, `isPrayerTime`, cooldown check, daily cap check
- Cooldown disimpan di Hive (`last_ad_shown_at`, `ads_shown_today`, `ads_shown_today_date`)
- Track event di Analytics: `app_open_ad_loaded`, `app_open_ad_shown`, `app_open_ad_skipped_prayer_time`, `app_open_ad_skipped_cooldown`, `app_open_ad_failed`
- A/B test: 50% user dapat App Open Ad, 50% control group untuk monitor retention regression

**Yang EKSPLISIT TIDAK ADA (jangan coba ditambahin nanti):**
- ❌ Banner ads di home/settings/screen manapun
- ❌ Native ads di daftar surah / murottal
- ❌ Interstitial ads saat navigasi
- ❌ Rewarded ads
- Semua di atas merusak UX dan menyalahi keputusan strategi 2026-04-26

### Ship 6: Donation Button (Minggu 7)

- Tambah menu "Dukung Pengembang" di Settings (icon hati ❤️ atau tangan terbuka 🤲)
- Halaman donation:
  - Heading: "Bantu kami terus mengembangkan aplikasi ini"
  - Subheading: "100% untuk biaya server, lisensi, dan waktu development"
  - 4 preset amount card: Rp 10k, 25k, 50k, 100k
  - Tombol "Custom amount" (nominal bebas)
  - List "Apa yang sudah kami kerjakan dengan dukungan kalian" — link ke CHANGELOG
- Setelah purchase berhasil:
  - Show modal terima kasih dengan doa untuk donor
  - Track event `donation_completed` dengan amount
  - Optional: badge "Pendukung" di profile (kalau ada profile — kalau belum, skip)
- Promote sekali via in-app message setelah update, jangan spam

### Ship 7: Iterasi Berdasar Data (Minggu 8)

Setelah 1-2 minggu data ads + donasi:
- Review eCPM per placement, drop placement yang underperform (< Rp 50/1000 impression)
- Review retention dengan/tanpa ads — kalau D7 retention drop > 5% dari baseline, kurangi ad density
- Review donation conversion — kalau < 0.5% user donate, evaluasi UX donation page
- Adjust ad cap (interstitial frequency, native position)
- **Don't ship as version bump** — adjust via Firebase Remote Config kalau bisa, atau hot-fix patch

**Bulan 2 Output:**
- Pendapatan pertama masuk (ads + donasi)
- Data konkret tentang user willingness to pay
- Baseline retention dengan ads aktif

---

## Bulan 3: PREMIUM IAP (Juli 2026)

**Tema:** Launch premium tier. Konversi users yang annoyed by ads jadi paying customers.

### Ship 8: Premium Feature Bundle (Minggu 9-10)

**Definisikan apa yang dapat:**

| Feature | Free | Premium |
|---|---|---|
| Waktu shalat + notifikasi | ✅ | ✅ |
| Quran (teks + terjemahan) | ✅ | ✅ |
| Dzikir & doa | ✅ | ✅ |
| Kiblat | ✅ | ✅ |
| Murottal (1 reciter) | ✅ | ✅ |
| App Open Ad | ✅ ada (max 3/hari, ada cooldown) | ❌ tidak ada |
| Murottal reciter tambahan | 1 | 5+ (Al-Sudais, Al-Afasy, Al-Hudhaify, dll) |
| Custom adzan tone | 5 default | 15+ premium tones |
| Tema premium | 2 (light, dark) | 8+ (dengan motif Islamic art) |
| Cloud backup (bookmark, settings, dzikir progress) | ❌ | ✅ via Google Drive |
| Widget tema premium | 2 default | 6+ premium widget styles |

**Kenapa bundle ini cocok:**
- Tidak paywall ibadah inti (prinsip #1)
- Cosmetic + convenience features (theme, reciter variety, backup)
- Cloud backup pakai Google Drive API user-side — TIDAK perlu backend Frosthoot (prinsip #4: solo-maintainable)

### Ship 9: Premium UI + Purchase Flow (Minggu 10-11)

- Halaman "Waktu Shalat Premium" yang reachable dari:
  - Settings (entry permanen)
  - Modal "Disable ads" yang muncul di footer ads (tappable)
  - Banner soft di Quran screen ("Backup bookmark kamu? → Premium")
- Layout halaman premium:
  - Hero: "Dapatkan pengalaman terbaik, satu kali bayar selamanya"
  - List feature dengan icon (no ads, more reciters, premium themes, cloud backup)
  - Big CTA button: "Unlock Premium — Rp 49.000" (atau 79k, tergantung research)
  - Sub-text: "Pembelian sekali. Selamanya milikmu. Bisa restore di device baru dengan akun Google yang sama."
  - FAQ collapsed: bisa refund? bisa multi-device? dll
- Restore purchase button (penting untuk Play Store policy)
- Setelah purchase: confetti animation + ucapan terima kasih + auto-disable ads

### Ship 10: Launch Premium dengan Promo (Minggu 12)

- Soft launch: feature flag premium availability bertahap (10% user → 50% → 100% dalam 1 minggu)
- Intro pricing: 30% off launch (Rp 49k jadi Rp 34k) selama 2 minggu pertama
- Push notif sekali ke semua user: "Premium telah hadir — diskon launch 30%"
- In-app banner di home screen selama promo period
- Track: install → premium_view → premium_purchase funnel
- Target Bulan 3 minggu terakhir: 1-3% konversi free → premium

**Bulan 3 Output:**
- Premium tier live, transaksi pertama masuk
- 3 stream revenue jalan: ads + donasi + premium
- Data konversi untuk planning Q4 (subscription? next tier?)

---

## Sponsorship Outreach (Track Paralel — Sepanjang 3 Bulan)

Bukan ship event, tapi effort konsisten. Bisa kerjain 1-2 jam per minggu.

### Target Sponsor Kategori
1. **Travel umrah/hajj** — punya pasar yang persis match dengan user prayer app. Contoh: Patuna, ESQ Tours, AlSalam Tour.
2. **Halal food/restaurant chain** — Es Teler 77, Bakso Lapangan Tembak, Solaria.
3. **Islamic clothing brand** — Zoya, Elhijab, Wearing Klamby.
4. **Mosque communities** — masjid besar yang mau jangkau jamaah lewat digital (kemungkinan unpaid tapi co-marketing).
5. **Islamic education platform** — Quranreview.com, Bayyinah, Hijra (kalau ada di Indonesia).

### Persiapan One-Pager (Minggu 1 Bulan 1)
Buat dokumen 1 halaman PDF yang berisi:
- App stats (DAU, MAU, demographic breakdown — jenis kelamin, usia, kota)
- Engagement metric (avg session duration, screens per session)
- Sample placement screenshot (banner native dengan logo sponsor)
- Pricing tier (CPM, CPC, atau flat monthly fee)
- Contact info Frosthoot Studio

### Outreach Cadence
- 2 cold email per minggu ke target list
- 1 follow-up per kontak sebulan kemudian kalau no response
- Track di simple Google Sheet: contact, date, status, notes

### Pricing Suggestion (Adjust setelah baseline data)
- Banner native di home: Rp 2-5 juta/bulan flat (asumsi 10k+ DAU)
- Sponsor segment di Hijri calendar: Rp 1-3 juta/bulan
- "Powered by [sponsor]" pada doa harian: Rp 5-10 juta/bulan (premium slot)

---

## Metrics & Success Criteria

**Track mingguan di simple Google Sheet (tidak perlu dashboard kompleks):**

### Revenue Metrics
- Total revenue (Ads + IAP donasi + Premium)
- ARPU = Total revenue / MAU
- ARPPU = Total revenue / paying users
- Premium conversion rate = Premium purchases / Active users

### Health Metrics
- D1, D7, D30 retention (compared to pre-monetization baseline)
- Crash-free user rate
- Play Store rating (weekly snapshot)
- Negative review keyword tracking ("ads", "iklan", "berbayar", "mahal")

### Success Criteria (End of Q3 2026)
- 🎯 ARPU ≥ Rp 500/user/bulan
- 🎯 Premium conversion ≥ 1% (lower bound, 3% would be great)
- 🎯 Play Store rating ≥ 4.5 (no regression)
- 🎯 Crash-free user rate ≥ 99.5%
- 🎯 D7 retention regression < 3% from baseline
- 🎯 Minimum 1 sponsor deal closed (bonus, not required)

---

## Risiko & Mitigasi

| Risiko | Probability | Impact | Mitigasi |
|---|---|---|---|
| Rating Play Store drop karena ads | Medium | High | Strict "no ads in worship screens" rule. A/B test 50/50 sebelum 100% rollout. Premium murah (Rp 49k) sebagai escape valve. |
| Ad network show iklan haram (riba/gambling) walau di-blocklist | Medium | High | Manual sample check tiap minggu di production build. Report + filter agresif. Halal-only ad network sebagai backup (Halal Ads Network kalau availability ada). |
| User komplain "kenapa berbayar, app Islam harusnya gratis" | High | Medium | Clear messaging: core features tetap gratis. Premium = convenience + cosmetic. Donasi sebagai alternatif pay-what-you-want. |
| Solo dev burnout | High | Critical | Strict scope per bulan (3-4 ship events max). Ada minggu maintenance/fix di setiap bulan. Pending dep upgrade tetap di branch terpisah. |
| Sponsor outreach no response | High | Low | Effort kecil per minggu (1-2 jam). Kalau gagal Q3, retry Q4 dengan stats yang lebih meyakinkan. |
| Premium conversion < 1% | Medium | Medium | Iterate pricing & UX di Bulan akhir. Coba Rp 29k vs Rp 49k vs Rp 79k. Coba intro promo lebih agresif. |
| Backend dependency creep (cloud backup butuh server) | Low | High | Strict pakai Google Drive API user-side, bukan Frosthoot server. Kalau scope expand butuh backend → defer ke Q4. |

---

## Beyond Q3 (Hooks for Q4 Planning)

Pas Q3 selesai, evaluasi dan pertimbangkan:

1. **Subscription tier "Pro+"?** — Cuma kalau premium one-time terbukti sukses (>3% conversion). Tambah subscription dengan benefit: monthly Quran study material, audio tafsir, dll.

2. **Lokalisasi & ekspansi geografis** — Malaysia, Brunei, Singapore. Pasar Muslim Asia Tenggara yang share bahasa & budaya.

3. **B2B / Mosque package** — White-label app untuk masjid besar dengan branding mereka. High margin per deal, butuh sales effort.

4. **Frosthoot ekosistem** — Cross-promo Shift Calendar di Waktu Shalat (Pertamina shift workers banyak yang Muslim, target overlap kuat).

5. **Content partnerships** — Kolaborasi dengan ustadz/da'i terkenal untuk eksklusif content (kajian audio, tafsir series).

6. **Community features** — Bookmark sharing, dzikir reminder grup keluarga. Risiko backend complexity tinggi — defer kalau memungkinkan.

---

## Action Item Berikutnya (Minggu Ini)

Sebelum Bulan 1 dimulai:

1. ✅ **Konfirmasi 1.1.1+11 stabil di Play Store** — minimal 2-3 hari monitoring crash report
2. ⬜ **Cek Play Console & tarik baseline metrics** — install count, DAU/MAU, current rating
3. ⬜ **Review roadmap ini bareng Claude** — ada bagian yang mau di-adjust?
4. ⬜ **Setup project Firebase** (kalau belum) — siapkan akun & link ke Play Console
5. ⬜ **Buat akun AdMob** (kalau belum) — siapkan untuk Bulan 1 minggu 3

Setelah konfirmasi roadmap, Claude bisa langsung mulai eksekusi Ship 1 (Firebase Analytics integration) di chat berikutnya.

---

> **Catatan:** Roadmap ini hidup. Update tiap akhir bulan dengan apa yang sudah dieksekusi vs planned, plus learnings dari data. Jangan kaku dengan timeline — kalau ada yang molor, prioritas adalah quality + retention, bukan ship date.
