# Waktu Shalat — Context for Claude Chat (Project Knowledge)

> **Generated 2026-05-08** — Consolidated context from prior Claude sessions.
> Upload this as project knowledge in claude.ai. Babah will paste Claude Code
> commands into VS Code terminal as the new workflow.

---

## 1. Project at a glance

**App:** "Waktu Shalat" — Indonesian prayer times app with Quran reader, dzikir, qibla compass, hijri calendar, murottal player.

**Stack:**
- Flutter (SDK ^3.11.0), Dart
- State: `provider 6.1.3`
- Storage: `hive 2.2.3`
- Notifications: `awesome_notifications`
- Audio: `just_audio`, `audio_service`
- Compass: `flutter_qiblah ^3.2.0` (uses flutter_compass_v2)
- Auth/Analytics: `firebase_core ^3.6.0`, `firebase_analytics ^11.3.0`, `firebase_crashlytics ^4.1.3`
- Ads: `google_mobile_ads ^5.3.1` (App Open Ad only — see monetization)
- IAP: `in_app_purchase ^3.2.0` (premium_lifetime, donation-style)

**Repo:** `github.com/frosthootstudio/prayer_app` — push directly to `main` (no PR workflow).

**Android applicationId:** `studio.frosthoot.prayer_app` (NOT `com.frosthoot.prayerapp` — that's outdated). Live Play Store package, CANNOT be changed without breaking installs.

**Firebase project:** `waktu-shalat-b4a47` (project ID), project number `1090953246408`.

**Frosthoot Studio contact email:** `frosthoot.studio@gmail.com`.

**Privacy policy:** Public at https://sites.google.com/view/waktu-shalat-privacy-policy/home — source of truth in repo at `docs/PRIVACY_POLICY_ID.md` + `docs/PRIVACY_POLICY_EN.md`. Update both whenever a new SDK is added (Firebase/AdMob/IAP). Pattern: update repo first, then patch Google Sites.

**AdMob Publisher ID:** `pub-4236028330675226`.
- Android App ID (PROD): `ca-app-pub-4236028330675226~1941898552`
- App Open Ad Unit (PROD): `ca-app-pub-4236028330675226/7453854346`
- iOS: still TEST (iOS not shipped)
- app-ads.txt: `https://frosthootstudio.github.io/app-ads.txt`

---

## 2. User profile — Babah

**Solo developer at Frosthoot Studio.** Vibe coder — relies heavily on Claude for technical reasoning, architecture decisions, and execution. Not deeply hands-on with low-level technical debugging.

**Language:** Indonesian first, mixes English for technical terms (commit, push, dependency). Casual register ("kau", "aku", "yakan", "gitu loh"). Match this.

**Tools setup:**
- VS Code with Claude Code installed (PRIMARY for build/test/git operations + file edits)
- Android emulator (sdk gphone64 x86 64) for device testing
- Waydroid for IAP/Play Store testing (with GApps + uncertified Android ID registered)
- Default Waydroid IP for ADB: `192.168.240.112:5555`

**How to be most helpful:**
- Lead with answer/decision, not deep technical reasoning unless asked
- Always offer concrete next-step terminal commands he can paste
- Be patient with workflow questions — still learning Claude product ecosystem

---

## 3. Workflow preferences (IMPORTANT)

### 3a. Commit separation
**Don't bundle unrelated changes.** Each commit = one cohesive narrative. Six months later for blame/bisect, separate commits = clear attribution. Default: suggest splitting per-concern. BUT respect explicit "push semua sekaligus" override.

Always show `git status` before commit.

### 3b. Don't ship dep upgrades right after a fix release
After Play Store release, wait 2-3 days before merging dependency upgrades or KGP migration on the same branch. Crash attribution becomes impossible if mixed.

### 3c. Build command flags (ALWAYS use these by default)

**APK builds:**
```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/symbols \
  --split-per-abi
  [--dart-define=KEY=VALUE ...]
```

**AAB builds (Play Store):**
```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/symbols
  [--dart-define=KEY=VALUE ...]
```

(NO `--split-per-abi` for AAB — bundle format handles ABI splits at Play Store delivery layer.)

**Symbol path:** `build/symbols` — needed to deobfuscate Crashlytics traces via `flutter symbolize -i <stack> -d build/symbols/app.android-arm64.symbols`.

**Dart-defines:**
- Production: NONE (Firebase/AdMob keys are in `google-services.json` + AndroidManifest, not env-injected)
- Testing-only (for AdService guard verification):
  - `--dart-define=AD_COOLDOWN_MINUTES=N` (default 240 = 4h)
  - `--dart-define=AD_KINDNESS_HOURS=N` (default 24)
  - `--dart-define=AD_PRAYER_WINDOW_MINUTES=N` (default 10)
  - `--dart-define=AD_DAILY_CAP=N` (default 3)
- **NEVER ship production with these dart-defines passed.**

---

## 4. Current state (as of 2026-05-08)

**Versions:**
- pubspec.yaml: `1.2.2+21` (latest dev — Crashlytics-driven hardening)
- Internal Testing track: `1.1.4+14` (PROD AdMob verified; older versions also there)
- Play Store live (Production): `1.0.8+8` — pending promotion of newer versions

**Recent shipped:**
- 1.1.7+18 — ProGuard hardening + R8 full mode disable + 3-arg startForeground
- 1.2.0+19 — Bulan 3 paywall UI live (caused FGS crash)
- 1.2.1+20 — HOTFIX removed PrayerForegroundService entirely
- 1.2.2+21 — Qibla NaN persistent failure counter + explicit ProGuard keeps for awesome_notifications receivers (READY TO SHIP)

---

## 5. Monetization strategy (Q3 2026 — APPROVED)

**Decision (2026-04-26, REVISED 2026-04-28):**

**Selected revenue streams:**
- **App Open Ad ONLY** — single ad on cold start / warm resume. ZERO ads inside app. 4h cooldown, max 3/day, skip prayer-time window, skip first 24h post-install
- **IAP "Premium" one-time** — Rp 25.000 (~$1.50). Reframed as "ad-free + support developer" donation-style. **ALL FEATURES STAY FREE FOR EVERYONE.** Premium ONLY removes the App Open Ad + signals supporter status. Product ID: `premium_lifetime`
- Donation/sadaqah (consumable IAP, future ship)
- Sponsorship (parallel outreach track)

**REJECTED:** Subscription (Indonesian market resistant + adds support overhead).

**Non-negotiable principles:**
1. Worship features (prayer times, qibla, Quran, dzikir) NEVER paywalled
2. ALL FEATURES STAY FREE FOR EVERYONE — premium IAP only removes ad + signals supporter
3. NO ads inside the app — only App Open Ad on entry. NO banners, interstitials, native, rewarded
4. Halal-conscious AdMob category blocklist: alcohol, gambling, dating, predatory loans, riba-based finance
5. Solo-maintainable only — reject if needs custom backend
6. Transparent messaging to user about why monetization exists

**Crash-free user rate must be ≥99% before each monetization ship.**

---

## 6. Active issues (Crashlytics 2026-05-06)

**Overall:** 51.85% crash-free users (improving from 42% but still BELOW 99% target). 168 crashes, 52 users affected (Last 7 days).

**Recurring (1.2.2+21 attempts to fix):**
- **Qibla NaN (Azimuth.<init>)** — 76 events / 18 users, versions 1.1.2-1.2.1. Native-side throw, Dart filter doesn't help. 1.2.2+21 adds Hive failure counter to skip subscribe after 3 errors.
- **Awesome Notifications ClassNotFoundException** — 50 events / 31 users, 6 variants, versions 1.1.2-1.2.1. ProGuard wildcard alone wasn't enough. 1.2.2+21 adds explicit keep for each receiver in merged manifest.

**FIXED in 1.2.1+20 (will fade as users update):**
- ActivityThread$H.handleMessage RemoteServiceException
- MainActivity.onCreate startServiceCommon (FGS related)
- generateForegroundServiceDidNotStartInTimeException

**Old version-only (will fade naturally):**
- Font network fail (1.1.3-1.1.4)
- Glance widget trampoline (1.1.2-1.1.3)
- ProxyBillingActivity NPE (1.1.3)
- libflutter.so missing (1.1.6)

---

## 7. Feature request queue

**Babah's own:** Done in 1.2.0+19:
- ✅ Swipe-right gesture on home prayer schedule → tomorrow's prayer times (PageView in `home_screen.dart`)

**Play Store reviews pending:**
- Ottoman/Uthmani Arabic font option (review S*****A 2026-04-21, 2★, Samsung Galaxy A04s, app v1.0.8). Currently 4 fonts (Amiri, ScheherazadeNew, NotoNaskhArabic, Lateef). Source: KFGQPC Uthman Taha Naskh / Uthmanic Script HAFS (royalty-free).

---

## 8. Pending dep upgrade branch (`chore/dep-upgrade-1.3.0`)

**Do NOT start until 1.2.2+21 (or current stable) at full 100% Production rollout AND Crashlytics shows no new issues for 3-5 days.**

**Scope:**
- Remove `id("kotlin-android")` from `android/app/build.gradle.kts` (redundant since Flutter ≥3.27)
- Major plugin bumps (use Context7 MCP to fetch breaking-change docs first):
  - `firebase_core 3 → 4`, `firebase_analytics 11 → 12`, `firebase_crashlytics 4 → 5`
  - `google_mobile_ads 5 → 8` (3 majors! Risky given monetization just stabilized — verify thoroughly on Internal Testing)
  - `share_plus 10 → 13`, `geocoding 4 → 5`
  - `home_widget 0.9 → ?`, `audioplayers 6 → 7`, `workmanager 0.9 → ?`, `in_app_review 2 → ?`
  - `package_info_plus 9 → 10`, `xml 6 → 7`, `cli_util`, `win32 5 → 6` (transitive)
- Target version: `1.3.0+22+`

---

## 9. AD_ID gotcha (lesson learned 2026-04-29)

`google_mobile_ads ^5.x` stopped auto-declaring `com.google.android.gms.permission.AD_ID`. Apps using AdMob MUST explicitly add to AndroidManifest.xml:

```xml
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

Without this:
- Play Console blocks Production rollout when "Advertising ID" declaration is "Yes"
- Android 13+ users get zeroed advertising_id → non-personalized ads → eCPM drops 30-50%

Currently declared in `android/app/src/main/AndroidManifest.xml`.

**Play Console "Turn off release errors"** must remain CHECKED permanently because old artifacts (1.0.8+8 etc.) without AD_ID still exist in app history. Unchecking later = future release block.

---

## 10. Key file locations

- `/lib/main.dart` — App entry, initializes Firebase → AdMob SDK → Hive → SettingsProvider → IapService → AdService (in this order, FGS removed in 1.2.1+20)
- `/lib/screens/home_screen.dart` — Main prayer times UI with PageView swipe (today/tomorrow)
- `/lib/screens/qibla_screen.dart` — Compass with Hive-backed sensor failure counter (1.2.2+21)
- `/lib/screens/settings_screen.dart` — Settings with "Dukungan" section linking to paywall
- `/lib/screens/support_developer_screen.dart` — Donation-style paywall (Bulan 3)
- `/lib/services/ad_service.dart` — App Open Ad with 5 guards
- `/lib/services/iap_service.dart` — IAP with ValueNotifier surfaces
- `/lib/services/analytics_service.dart` — Firebase Analytics wrapper
- `/lib/providers/prayer_provider.dart` — Prayer times calculation + lifecycle
- `/lib/providers/settings_provider.dart` — App settings + localization (3 languages: ID/EN/AR)
- `/android/app/build.gradle.kts` — `applicationId = studio.frosthoot.prayer_app`, minify on, proguardFiles
- `/android/app/proguard-rules.pro` — Comprehensive keep rules (especially for awesome_notifications receivers)
- `/android/app/src/main/AndroidManifest.xml` — Permissions, AdMob meta-data, receivers
- `/android/gradle.properties` — `android.enableR8.fullMode=false`
- `/docs/CLAUDE_CONTEXT.md` — In-repo "save game" file (legacy, this file supersedes)
- `/docs/PRIVACY_POLICY_ID.md` + `/docs/PRIVACY_POLICY_EN.md` — Privacy policy source of truth
- `/docs/ARABIC_AUDIT.md` + `/docs/REFERENCES.md` — Uthmani encoding reference for Quranic text

---

## 11. Workflow note for new Claude chat

**Babah's NEW workflow (effective 2026-05-08):**
- Edits + builds happen in **VS Code with Claude Code** (you'll generate prompts to paste)
- This claude.ai chat = strategy, decision-making, design discussions
- For each task that requires file edits/builds: write a **complete Claude Code prompt** that Babah copies into his VS Code Claude Code panel
- Don't try to use file_system tools — there's no live workspace in claude.ai chat. Source code is read-only via project knowledge.

**Format for Claude Code prompts:**
```
File: lib/services/ad_service.dart
Change: [describe what + why]
Then run: flutter analyze && git add -A && git commit -m "..." && git push
```

Keep prompts SHORT and ACTIONABLE. Don't recreate this entire context in each prompt — Claude Code has its own workspace context.
