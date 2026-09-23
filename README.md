<div align="center">

<img src="assets/icon/app_icon.png" width="128" height="128" alt="Waktu Shalat Logo" style="border-radius: 20%;" />

# 🕌 Waktu Shalat
### Modern, Accurate & Offline-First Islamic Companion for Android

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Gradle](https://img.shields.io/badge/Gradle-9.4.1-02303A?logo=gradle&logoColor=white)](https://gradle.org)
[![AGP](https://img.shields.io/badge/AGP-9.2.0-3DDC84?logo=android&logoColor=white)](https://developer.android.com/studio/releases/gradle-plugin)
[![Java](https://img.shields.io/badge/Java-17_Bytecode-ED8B00?logo=openjdk&logoColor=white)](https://adoptium.net)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Google Play](https://img.shields.io/badge/Google_Play-Live_Production-414141?logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=studio.frosthoot.prayer_app)

<br/>

[📱 **Download on Google Play**](https://play.google.com/store/apps/details?id=studio.frosthoot.prayer_app) • [📖 **Privacy Policy**](docs/PRIVACY_POLICY_ID.md) • [✨ **Features**](#-features) • [🏗️ **Architecture**](#️-technical-highlights--architecture)

<br/>

</div>

---

## 📌 Overview

**Waktu Shalat** is a production-grade Islamic companion app built with Flutter. Engineered with an **offline-first philosophy**, it delivers pinpoint astronomical prayer times, live Qibla compass tracking, a full Quran reader with audio murottal, daily dzikir/dua, Hijri calendar tracking, and Android home screen widgets.

### 💡 Core Design Philosophy
* **Zero Intrusive Ads:** Strictly **no banners, interstitials, or pop-up ads** during prayer times or Quran recitation. 
* **100% Offline Core:** Astronomical calculations, local databases, and audio engines operate without internet connectivity.
* **Privacy & Battery Minded:** Precise background alarms scheduled with battery-friendly exact alarm policies; no continuous background GPS drains.

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| ⏱️ **Pinpoint Prayer Calculations** | Offline calculation via mathematical models with 5 major conventions (Kemenag RI, Muslim World League, Egyptian Authority, ISNA, Umm Al-Qura) + Hanafi / Standard Asr calculation. |
| 🧭 **Pure Dart Qibla Engine** | Spherical trigonometry calculating the Great Circle bearing to the Kaaba with live sensor fusion and declination correction. |
| 🔔 **Smart Adzan Notifications** | Multi-channel sound notifications, exact alarm scheduling, pre-adzan reminders, and custom adzan audio playback. |
| 📖 **Al-Qur'an & Murottal** | 114 Surahs with Indonesian & English translations, multi-Qari audio streaming/caching with background playback services, and 5 typography-optimized Arabic fonts. |
| 📿 **Dzikir & Daily Prayers** | Morning/evening dzikir, daily doa collections, and integrated digital tasbih counter. |
| 📅 **Hijri Calendar & Tracker** | Comprehensive Islamic calendar with worship habit tracker and fasting schedule. |
| 📱 **Home Screen Widget** | Glanceable next prayer time widget for Android home screens (multi-size support). |
| 🌐 **Localization & Theming** | Fully localized in Indonesian, English, and Arabic (RTL support) with Light and Dark themes. |

---

## 🏗️ Technical Highlights & Architecture

This repository demonstrates modern Android and Flutter engineering standards for enterprise and high-reliability consumer applications:

```
prayer_app/
├── android/            # Gradle 9.4.1, AGP 9.2.0, Java 17 bytecode, review-ktx native bridge
├── lib/
│   ├── models/         # Immutable data models & entities
│   ├── providers/      # Reactive state management with Provider
│   ├── screens/        # Clean UI layers with responsive layouts
│   ├── services/       # Decoupled domain services (Audio, Adzan, Qibla, Database, Location)
│   └── widgets/        # Reusable UI components and Home Widgets
└── test/               # Unit and widget test suites
```

* **Modern Android Build Tooling:** Built on **Gradle 9.4.1**, **Android Gradle Plugin 9.2.0**, and compiles with **Java 17 bytecode** (`compileSdk = 37`, `targetSdk = 36`).
* **Decoupled Pure-Dart Mathematical Engine:** Removed third-party brittle native libraries for Qibla calculation; calculations use pure Dart `adhan` astronomical formulas and `flutter_compass` hardware streams.
* **Native In-App Review via Kotlin Platform Channel:** Direct integration with Google Play's modern `com.google.android.play:review-ktx` artifact without unmaintained plugin dependencies.
* **Efficient Persistence:** High-performance local storage leveraging `Hive` for sub-millisecond key-value lookups and user settings.
* **Background Audio Engine:** Rock-solid audio lifecycle management using `audio_service` and `just_audio` with lock-screen media controls and background audio focus handling.
* **AdMob Kindness Guards:** Strict developer guards including minimum 4-hour cooldowns, daily caps, and automatic prayer-time ad silencing. Built-in `kDebugMode` switch to Google's official test ad units to prevent accidental invalid traffic strikes.

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.0` or newer)
* [Android Studio](https://developer.android.com/studio) with Android SDK 36/37 installed
* JDK 17 (Temurin or OpenJDK recommended)

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/frosthootstudio/prayer_app.git
   cd prayer_app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Code Analyzer & Tests:**
   ```bash
   dart analyze
   flutter test
   ```

4. **Launch in Debug Mode:**
   ```bash
   flutter run
   ```
   > ℹ️ *Note: When running in Debug Mode, the application automatically uses official Google AdMob test ad units.*

---

## 🛠️ Production Build Flags

For Google Play production releases, the project is configured with code obfuscation, R8 shrinking, and symbol extraction:

```bash
# Generate Release App Bundle (.aab) with debug symbols
flutter build appbundle --release \
  --target-platform android-arm64 \
  --obfuscate \
  --split-debug-info=build/symbols
```

---

## ⚖️ License & Brand Protection

The source code of this application is licensed under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE).

> **Important Trademark Notice:**  
> The brand names **"FrostHoot Studio"**, **"Waktu Shalat"**, the application icons, logos, graphic design assets, and proprietary audio media are proprietary assets of FrostHoot Studio and are explicitly **excluded** from the GPL-3.0 license. Anyone creating derivative works or forks must replace all branding, application icons, and package identifiers before redistribution.

---

## 👨‍💻 Creator & Author

Developed by **FrostHoot Studio**  
* **Lead Developer:** Babah ([LinkedIn Profile](https://www.linkedin.com) • [GitHub](https://github.com/frosthootstudio))
* **Email:** `frosthoot.studio@gmail.com`
* **Website:** [frosthootstudio.github.io](https://frosthootstudio.github.io)
