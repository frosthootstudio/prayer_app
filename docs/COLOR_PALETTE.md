# Color Palette — Waktu Shalat

> Auto-extracted from source: `app_theme.dart`, `main.dart`, and all screens/providers.
> All colors listed with hex, RGB, and primary usage locations.

---

## 1. Brand / Accent Colors

| Name | Hex | RGB | Used In |
|---|---|---|---|
| Gold (dark accent) | `#D4A057` | rgb(212, 160, 87) | Dark theme accent, notifications, Quran player, mini player, adzan settings |
| Warm Orange (light accent) | `#CE7E50` | rgb(206, 126, 80) | Light theme accent, Material3 seed color |

---

## 2. Theme-Aware Colors (`context.appXxx` — via `app_theme.dart`)

These colors switch automatically between dark and light mode.

### Text

| Property | Dark Hex | Dark RGB | Light Hex | Light RGB | Used In |
|---|---|---|---|---|---|
| `appTextPrimary` | `#E8E8F0` | rgb(232, 232, 240) | `#2A1A0E` | rgb(42, 26, 14) | All primary text |
| `appTextSecondary` | `#B0B3C6` | rgb(176, 179, 198) | `#8B6545` | rgb(139, 101, 69) | Subtitles, labels |
| `appTextFaded` | `#6E7090` | rgb(110, 112, 144) | `#BBA88A` | rgb(187, 168, 138) | Hints, placeholders |

### Backgrounds

| Property | Dark Hex | Dark RGB | Light Hex | Light RGB | Used In |
|---|---|---|---|---|---|
| `appCardBg` | `#252840` | rgb(37, 40, 64) | `#FAF3EC` | rgb(250, 243, 236) | Cards everywhere |
| `appSheetBg` | `#1E2138` | rgb(30, 33, 56) | `#FBF6F0` | rgb(251, 246, 240) | Bottom sheets |
| `appChevronBg` | `#252840` | rgb(37, 40, 64) | `#F5EDE4` | rgb(245, 237, 228) | Chevron button bg |
| `appRefreshBg` | `#2A2D45` | rgb(42, 45, 69) | `#F5EDE4` | rgb(245, 237, 228) | Refresh button |
| `appCardWarm` | `#252038` | rgb(37, 32, 56) | `#F2D9C4` | rgb(242, 217, 196) | Next-prayer card (warm) |
| `appCardLight` | `#1E2138` | rgb(30, 33, 56) | `#F8EFE4` | rgb(248, 239, 228) | Next-prayer card (light) |
| `appIconPassedBg` | `#2A2D45` | rgb(42, 45, 69) | `#F3EDE6` | rgb(243, 237, 230) | Past prayer icon bg |

### Foregrounds / Indicators

| Property | Dark Hex | Dark RGB | Light Hex | Light RGB | Used In |
|---|---|---|---|---|---|
| `appAccent` | `#D4A057` | rgb(212, 160, 87) | `#CE7E50` | rgb(206, 126, 80) | Highlights, icons |
| `appDivider` | `#2E3150` | rgb(46, 49, 80) | `#F0E8DE` | rgb(240, 232, 222) | Card dividers |
| `appSunDivider` | `#2E3150` | rgb(46, 49, 80) | `#E8D9C8` | rgb(232, 217, 200) | Sunrise/sunset row divider |
| `appSheetHandle` | `#4A4D65` | rgb(74, 77, 101) | `#D4C0AE` | rgb(212, 192, 174) | Bottom sheet drag handle |
| `appBellOff` | `#4A4D65` | rgb(74, 77, 101) | `#CCC0B5` | rgb(204, 192, 181) | Bell icon (muted state) |
| `appIconPassedFg` | `#6E7090` | rgb(110, 112, 144) | `#CBB89E` | rgb(203, 184, 158) | Past prayer icon fg |

### Overlays / Semi-Transparent

| Property | Dark Value | Light Value | Used In |
|---|---|---|---|
| `appCardShadow` | `#000000` @ 30% | `#2A1A0E` @ 7% | Card drop shadows |
| `appRowHighlight` | `#D4A057` @ 12% | `#FFF6F0` | Active prayer row highlight |
| `appMosqueOverlayWarm` | `#D4A057` @ 6% | `#CE7E50` @ 12% | Warm mosque silhouette overlay |
| `appMosqueOverlayLight` | `#D4A057` @ 4% | `#CE7E50` @ 9% | Light mosque silhouette overlay |

---

## 3. Scaffold / App Background Colors

| Mode | Hex | RGB | Used In |
|---|---|---|---|
| Dark scaffold | `#1A1C2E` | rgb(26, 28, 46) | `scaffoldBackgroundColor` (dark) |
| Light scaffold | `#FBF6F0` | rgb(251, 246, 240) | `scaffoldBackgroundColor` (light) |

---

## 4. Material3 ColorScheme (Dark Theme — `main.dart`)

| Role | Hex | RGB |
|---|---|---|
| `primary` | `#D4A057` | rgb(212, 160, 87) |
| `onPrimary` | `#1A1C2E` | rgb(26, 28, 46) |
| `primaryContainer` | `#2E3150` | rgb(46, 49, 80) |
| `secondary` | `#D4A057` | rgb(212, 160, 87) |
| `surface` | `#252840` | rgb(37, 40, 64) |
| `onSurface` | `#E8E8F0` | rgb(232, 232, 240) |
| `onSurfaceVariant` | `#B0B3C6` | rgb(176, 179, 198) |
| `outline` | `#2E3150` | rgb(46, 49, 80) |

---

## 5. Prayer Time Icon Colors (`home_screen.dart`)

Each prayer has a unique background/foreground pair for its icon chip.

| Prayer | BG Hex | BG RGB | FG Hex | FG RGB |
|---|---|---|---|---|
| Subuh (Fajr) | `#EEF2FF` | rgb(238, 242, 255) | `#6366F1` | rgb(99, 102, 241) — Indigo 500 |
| Syuruk (Sunrise) | `#FFFBEB` | rgb(255, 251, 235) | `#F59E0B` | rgb(245, 158, 11) — Amber 500 |
| Dzuhur (Dhuhr) | `#FFF7ED` | rgb(255, 247, 237) | `#F97316` | rgb(249, 115, 22) — Orange 500 |
| Ashar (Asr) | `#ECFDF5` | rgb(236, 253, 245) | `#10B981` | rgb(16, 185, 129) — Emerald 500 |
| Maghrib | `#FFF1F2` | rgb(255, 241, 242) | `#F43F5E` | rgb(244, 63, 94) — Rose 500 |
| Isya (Isha) | `#F5F3FF` | rgb(245, 243, 255) | `#8B5CF6` | rgb(139, 92, 246) — Violet 500 |
| Default | `#F5F5F5` | rgb(245, 245, 245) | — | `Colors.grey` |

---

## 6. Tracking Screen Colors (`tracking_screen.dart`)

### Category Colors

| Category | Hex | RGB | Tailwind Equivalent |
|---|---|---|---|
| malam (night) | `#8B5CF6` | rgb(139, 92, 246) | Violet 500 |
| subuh (fajr) | `#6366F1` | rgb(99, 102, 241) | Indigo 500 |
| pagi (morning) | `#F59E0B` | rgb(245, 158, 11) | Amber 500 |
| zuhur (dhuhr) | `#F97316` | rgb(249, 115, 22) | Orange 500 |
| ashar (asr) | `#10B981` | rgb(16, 185, 129) | Emerald 500 |
| petang (afternoon) | `#F43F5E` | rgb(244, 63, 94) | Rose 500 |
| maghrib | `#EF4444` | rgb(239, 68, 68) | Red 500 |
| isya (isha) | `#7C3AED` | rgb(124, 58, 237) | Violet 600 |
| default | `#6B7280` | rgb(107, 114, 128) | Gray 500 |

### Progress Ring Colors

| Threshold | Hex | RGB | Meaning |
|---|---|---|---|
| 100% complete | `#16A34A` | rgb(22, 163, 74) | Full — Green 600 |
| ≥ 75% complete | `#4ADE80` | rgb(74, 222, 128) | Good — Green 400 |
| ≥ 50% complete | `#F97316` | rgb(249, 115, 22) | Medium — Orange 500 |
| < 50% complete | `#9CA3AF` | rgb(156, 163, 175) | Low — Gray 400 |

### Task States

| State | Color |
|---|---|
| Done | `#22C55E` rgb(34, 197, 94) — Green 500 |
| Not done | `Colors.transparent` |

---

## 7. Calendar Event Colors (`calendar_provider.dart`)

| Event | Hex | RGB |
|---|---|---|
| Tahun Baru Islam / Idul Fitri / Idul Fitri H+2 | `#4CAF50` | rgb(76, 175, 80) — Material Green |
| Hari Asyura / Isra Mi'raj | `#2196F3` / `#9C27B0` | rgb(33, 150, 243) / rgb(156, 39, 176) |
| Maulid Nabi / Nuzulul Qur'an / Idul Adha | `#D4A057` | rgb(212, 160, 87) — Brand gold |
| Nisfu Sha'ban | `#00BCD4` | rgb(0, 188, 212) — Cyan |
| Awal Ramadhan / Hari Tasyrik | `#FF9800` | rgb(255, 152, 0) — Orange |
| Lailatul Qadar | `#E91E63` | rgb(233, 30, 99) — Pink |
| Hari Arafah | `#FF5722` | rgb(255, 87, 34) — Deep Orange |

---

## 8. Navigation Bar Colors (`main_screen.dart`)

| State | Dark Hex | Dark RGB | Light Hex | Light RGB |
|---|---|---|---|---|
| Inactive item | `#6E7090` | rgb(110, 112, 144) | `#B09880` | rgb(176, 152, 128) |
| Active item | `appAccent` | (theme-aware) | `appAccent` | (theme-aware) |

---

## 9. Onboarding Colors (`onboarding_screen.dart`)

| Page | Hex | RGB | Tailwind |
|---|---|---|---|
| Location permission | `#10B981` | rgb(16, 185, 129) | Emerald 500 |
| Notification permission | `#6366F1` | rgb(99, 102, 241) | Indigo 500 |

---

## 10. Quran / Surah Type Colors (`quran_screen.dart`)

| Type | BG | FG |
|---|---|---|
| Makki | `Colors.orange` @ 15% | `Colors.orange` |
| Madini | `Colors.teal` @ 15% | `Colors.teal` |

---

## 11. System / Notification Colors

| Element | Hex | RGB | Used In |
|---|---|---|---|
| Android notification icon tint | `#D4A057` | rgb(212, 160, 87) | `notification_service.dart` |
| System nav bar | `transparent` | — | `main.dart`, `SystemUiOverlayStyle` |

---

## Color Roles Summary

```
BRAND
  Gold (dark)    #D4A057   — primary accent in dark mode, notifications
  Gold (light)   #CE7E50   — primary accent in light mode, M3 seed

BACKGROUNDS (dark)
  Deepest        #1A1C2E   — scaffold
  Card           #252840   — cards, nav bar
  Card alt       #1E2138   — sheets, calendar cells
  Elevated       #2A2D45   — refresh btn, icon bg
  Border/Divider #2E3150   — dividers, primary container

BACKGROUNDS (light)
  Scaffold       #FBF6F0   — scaffold
  Card           #FAF3EC   — cards
  Sheet          #FBF6F0   — bottom sheets
  Warm card      #F2D9C4   — next prayer warm card
  Light card     #F8EFE4   — next prayer light card

TEXT (dark)
  Primary        #E8E8F0
  Secondary      #B0B3C6
  Faded          #6E7090

TEXT (light)
  Primary        #2A1A0E
  Secondary      #8B6545
  Faded          #BBA88A

PRAYER ICONS (Tailwind-aligned)
  Indigo 500     #6366F1   — Fajr
  Amber 500      #F59E0B   — Sunrise
  Orange 500     #F97316   — Dhuhr
  Emerald 500    #10B981   — Asr
  Rose 500       #F43F5E   — Maghrib
  Violet 500     #8B5CF6   — Isha

SEMANTIC
  Success        #22C55E / #16A34A
  Warning        #F97316 / #F59E0B
  Danger         #EF4444 / #F43F5E
  Info           #6366F1 / #2196F3
```
