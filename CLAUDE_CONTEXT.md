# Claude Context — Prayer App (Waktu Shalat)

> Resume file for new chat sessions. Update before closing a session.
> Last updated: 2026-04-26 (session 3)

---

## Project Overview

| Field | Value |
|---|---|
| App name | Waktu Shalat |
| Package | `com.frosthoot.prayerapp` |
| Version | `1.1.1+11` |
| Platform | Android (primary), Windows/macOS builds exist |
| Developer | Babah — Frosthoot Studio |
| Email | frosthoot.studio@gmail.com |
| Location | Balai Pungut, Riau, Indonesia |
| Play Store | **Live** — current published version `1.0.8+8` |
| Other apps | Shift Calendar (Pertamina shift workers) |

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter stable (SDK `^3.11.0`) |
| Language | Dart |
| State management | `provider ^6.1.3` (ChangeNotifier + context.watch) |
| Local storage | `hive ^2.2.3` + `hive_flutter` |
| Prayer calc | `adhan ^2.0.0` (offline, Kemenag/Shafi'i method) |
| Notifications | `awesome_notifications ^0.11.0` |
| Fonts | Local TTF assets + `google_fonts` (non-Arabic UI only) |
| Audio | `just_audio` + `audioplayers` (adzan) |
| Quran data | `quran ^1.4.1` package (local) |
| Transliteration | `equran.id/api/v2` (Kemenag) + `api.quran.com` fallback |
| Share | `screenshot` + `share_plus` + `gal` |
| Home widget | `home_widget` + `workmanager` |

---

## Current File Structure

```
lib/
├── data/
│   ├── dzikir_data.dart
│   └── transliteration_data.dart
├── main.dart
├── models/
│   ├── dzikir_model.dart
│   ├── prayer_model.dart
│   └── prayer_tracking_model.dart
├── providers/
│   ├── calendar_provider.dart
│   ├── dzikir_provider.dart
│   ├── murottal_provider.dart
│   ├── prayer_provider.dart
│   ├── quran_provider.dart
│   ├── settings_provider.dart
│   └── tracking_provider.dart
├── screens/
│   ├── calendar_screen.dart
│   ├── dzikir_screen.dart
│   ├── home_screen.dart
│   ├── main_screen.dart
│   ├── murottal_screen.dart
│   ├── onboarding_screen.dart
│   ├── qibla_screen.dart
│   ├── quran_screen.dart
│   ├── settings_screen.dart
│   ├── surah_screen.dart
│   └── tracking_screen.dart
├── services/
│   ├── location_service.dart
│   ├── notification_service.dart
│   ├── permission_service.dart
│   ├── prayer_calculation_service.dart
│   ├── ramadan_service.dart
│   ├── rating_service.dart
│   ├── share_service.dart
│   └── widget_service.dart
├── utils/
│   ├── app_colors.dart
│   ├── app_theme.dart
│   ├── arabic_font_helper.dart
│   ├── number_utils.dart
│   └── quran_utils.dart
└── widgets/
    ├── countdown_timer.dart
    ├── mini_player.dart
    ├── next_prayer_card.dart
    ├── permission_fix_sheet.dart
    ├── share_bottom_sheet.dart
    └── share_card.dart
```

**New asset directories added this session:**
- `assets/fonts/arabic/` — 4 bundled Arabic TTF files
- `docs/` — ARABIC_AUDIT.md, REFERENCES.md

---

## Active Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  cupertino_icons: ^1.0.8
  adhan: ^2.0.0
  geolocator: ^14.0.2
  geocoding: ^4.0.0
  provider: ^6.1.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  intl: ^0.20.2
  google_fonts: ^8.0.2
  awesome_notifications: ^0.11.0
  flutter_qiblah: ^3.2.0
  smooth_page_indicator: ^2.0.1
  flutter_native_splash: ^2.4.7
  home_widget: ^0.9.0
  workmanager: ^0.9.0
  hijri: ^3.0.0
  table_calendar: ^3.1.3
  quran: ^1.4.1
  http: ^1.2.0
  permission_handler: ^12.0.0
  just_audio: ^0.10.5
  just_audio_background: ^0.0.1-beta.17
  audio_service: ^0.18.18
  audioplayers: ^6.1.0
  in_app_review: ^2.0.9
  screenshot: ^3.0.0
  share_plus: ^10.1.4
  path_provider: ^2.1.5
  gal: ^2.3.1
```

**Bundled local fonts (assets/fonts/arabic/):**
- `Amiri-Regular.ttf` (422 KB) — family: `Amiri`
- `ScheherazadeNew-Regular.ttf` (324 KB) — family: `ScheherazadeNew`
- `NotoNaskhArabic-Regular.ttf` (296 KB) — family: `NotoNaskhArabic`
- `Lateef-Regular.ttf` (236 KB) — family: `Lateef`

---

## Recent Completed Work

### 1. Fix adzan audio + universal device notification (v1.0.8+8)
- Custom adzan MP3s bundled, played via `audioplayers`
- Notification channels restructured for all Android API levels
- Committed and uploaded to Play Store

### 2. Hadith references for all 40 dzikir
- `dzikir_data.dart` expanded with source hadith + takrar counts
- `DzikirModel` updated with `reference` field

### 3. Switch Quran transliteration to equran.id (Kemenag)
- Replaced `api.alquran.cloud` (had typos like "udal" for "hudal")
- Primary: `equran.id/api/v2/surat/$n` → `teksLatin` field
- Fallback: `api.quran.com` word-by-word
- Hive disk cache with 30-day TTL (`quran_translit_cache` box)
- File: `lib/providers/quran_provider.dart`

### 6. Uthmani text + Arabic font picker fix (v1.1.1+11)
- Ayah text source switched from `quran` package (simplified Arabic) to `api.quran.com/api/v4/quran/verses/uthmani` (full Tanzil/Mushaf-Madinah encoding)
- Chapter-level fetch with 1-year Hive cache (`quran_uthmani_cache` box); fallback to `quran.getVerse()` if offline on first fetch
- Arabic font picker now works on Al-Quran screen: root cause was `GoogleFonts.poppinsTextTheme` injecting `package:'google_fonts'` into DefaultTextStyle chain → fixed with `inherit: false`, `package: null`, `fontFamilyFallback: const []` in `ArabicFontHelper.getStyle()`
- `_AyahTile` Arabic Text wrapped in `Selector<SettingsProvider, ({String font, double size})>` to isolate rebuilds from MurottalProvider position stream
- All debug/probe widgets removed (`surah_screen.dart` is clean)

### 4. Share prayer schedule as image
- `lib/widgets/share_card.dart` — 1080px navy+gold card
- `lib/services/share_service.dart` — capture / share / save / copy
- `lib/widgets/share_bottom_sheet.dart` — preview + action buttons
- Share button added to home screen prayer card header

### 5. Arabic font picker — 4 fonts (ArabicFontHelper overhaul)
- `lib/utils/arabic_font_helper.dart` — key design decisions:
  - Removed `google_fonts` for all Arabic rendering
  - Fonts bundled as TTF assets in `assets/fonts/arabic/` (pubspec declared)
  - `getStyle()` uses `inherit: false` + `package: null` — critical because
    app theme uses `poppinsTextTheme` which injects `package:'google_fonts'`
    into DefaultTextStyle chain, corrupting font resolution when `inherit: true`
  - `fontFamilyFallback: const []` clears inherited fallback list
  - All callers must pass explicit `color:` — default is `Color(0xFFE8E8F0)`
  - `normalizeArabicText()` exists but is NOT called — opt-in only
- Font picker added to **reading prefs sheet** in `surah_screen.dart`
- Arabic Text in `_AyahTile` wrapped in `Selector<SettingsProvider, ({String font, double size})>`
  isolating rebuilds from MurottalProvider position stream (~16ms during audio)
- No debug code remains — all cleaned up

## Next Planned Features

| # | Feature | Status |
|---|---|---|
| 1 | Mode Ramadan (imsak, berbuka, tarawih) | Done |
| 2 | Arabic language support (3rd language) | Done |
| 3 | Share schedule to WhatsApp as image | Done |
| 4 | Arabic font picker on Al-Quran screen | Done (v1.1.1+11) |
| 5 | Uthmani text encoding in Al-Quran screen | Done (v1.1.1+11) |
| 6 | Build AAB, upload Play Store | **Next step** |

---

## Design Conventions

| Convention | Value |
|---|---|
| Primary dark | `#1A1C2E` (navy) |
| Accent | `#D4A057` (gold) |
| Default Arabic font key | `'scheherazade'` |
| Prayer calc method | Kemenag Indonesia — Shafi'i madhab |
| Primary language | Indonesian (Bahasa Indonesia) |
| Also supported | English, Arabic (3-language toggle) |
| Version policy | Keep at current during dev; bump only before Play Store upload |
| Docs policy | Use context7 MCP for package docs before writing code |
| Content policy | No copyrighted content without permission |

---

## Development Environment

| Item | Value |
|---|---|
| OS | CachyOS (Arch-based Linux) |
| Package manager | `pacman` |
| Shell | Fish |
| Editor | VS Code + Claude Code extension |
| Test device | Xiaomi Poco X6 Pro (HyperOS/MIUI) |
| Flutter channel | stable |
| Signing | Google Play App Signing (Google manages keystore) |

---

## Key File Locations

| Purpose | File |
|---|---|
| Arabic font dispatch | `lib/utils/arabic_font_helper.dart` |
| Font + language settings | `lib/providers/settings_provider.dart` |
| Quran reading screen | `lib/screens/surah_screen.dart` |
| Quran surah list | `lib/screens/quran_screen.dart` |
| Dzikir (works correctly) | `lib/screens/dzikir_screen.dart` |
| Transliteration cache | `lib/providers/quran_provider.dart` |
| Local dzikir corpus | `lib/data/dzikir_data.dart` |
| Share image widget | `lib/widgets/share_card.dart` |
| Notification setup | `lib/services/notification_service.dart` |
