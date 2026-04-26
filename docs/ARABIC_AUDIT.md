# Arabic Script Audit — Dzikir & Doa

**Audit date:** 2026-04-20  
**Auditor:** Frosthoot Studio  
**Scope:** All 40 DzikirItem entries in `lib/data/dzikir_data.dart`  
**Outcome:** 14 items fixed (all Quranic verses), 26 hadith/dua items verified correct

---

## Summary

| Category | Total items | Fixed | Status |
|----------|-------------|-------|--------|
| Pagi | 10 | 4 | ✅ Done |
| Petang | 10 | 4 | ✅ Done |
| Setelah Shalat | 8 | 2 | ✅ Done |
| Tidur | 6 | 4 | ✅ Done |
| Doa | 6 | 1 | ✅ Done |
| **Total** | **40** | **15** | **✅ All clean** |

---

## Items Fixed (Quranic Verses → Uthmani Script)

All Quranic text was previously in simplified Arabic (standard Unicode diacritics)
and has been updated to **Tanzil/Mushaf-Madinah Uthmani encoding**.

### Key Uthmani features applied

| Feature | Simplified (before) | Uthmani (after) |
|---------|--------------------|--------------------|
| Alif wasla | `الله` | `ٱللَّهُ` |
| Uthmani sukun | `ْ` (U+0652) | `ۡ` (U+06E1) |
| Small waw (dhamir hu) | `هُ` | `هُۥ` (U+06E5) |
| Small ya (dhamir hi) | `هِ` | `هِۦ` (U+06E6) |
| Madd/mad sign | none | `ٓ` (U+0653) |
| Uthmani tanwin | `ٌ ً ٍ` | `ٞ ٗ ٟ` |
| Superscript alef | `ا` in word | `ٰ` (U+0670) |
| Rounded stop | ` ۗ ۚ ۖ` | retained from Tanzil |

### 1. Surah Al-Ikhlas (QS. 112:1–4)
**Affected items:** `pagi_02`, `petang_02`, `tidur_02` (3 items)  
**Source:** Tanzil Uthmani database / Quran.com API v4  
**Change:** `قُلْ` → `قُلۡ`, `اللَّهُ` → `ٱللَّهُ`, `لَهُ` → `لَّهُۥ` etc.

```
Before: قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ
After:  قُلۡ هُوَ ٱللَّهُ أَحَدٌ ۝ ٱللَّهُ ٱلصَّمَدُ ۝ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ۝ وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدٌ
```

### 2. Surah Al-Falaq (QS. 113:1–5)
**Affected items:** `pagi_03`, `petang_03`, `tidur_03` (3 items)  
**Source:** Tanzil Uthmani database / Quran.com API v4  
**Change:** `الْفَلَقِ` → `ٱلۡفَلَقِ`, `النَّفَّاثَاتِ` → `ٱلنَّفَّٰثَٰتِ` (superscript alef), etc.

```
Before: قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ ... النَّفَّاثَاتِ فِي الْعُقَدِ ...
After:  قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ۝ ... ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ...
```

### 3. Surah An-Nas (QS. 114:1–6)
**Affected items:** `pagi_04`, `petang_04`, `tidur_04` (3 items)  
**Source:** Tanzil Uthmani database / Quran.com API v4  
**Change:** `النَّاسِ` → `ٱلنَّاسِ`, `الَّذِي` → `ٱلَّذِي`, `الْجِنَّةِ` → `ٱلۡجِنَّةِ`, etc.

```
Before: قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ...
After:  قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ۝ مَلِكِ ٱلنَّاسِ ...
```

### 4. Ayat Kursi (QS. Al-Baqarah: 255)
**Affected items:** `pagi_05`, `petang_05`, `shalat_07`, `tidur_05` (4 items)  
**Source:** Tanzil Uthmani database  
**Change:** Full verse rewritten with Uthmani encoding — alif wasla, small waw/ya on
dhamirs (`هُۥ`, `هِۦ`), Uthmani sukun, madd signs, special tanwin forms, stop marks.

```
Before: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ...
After:  ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُۚ ...
```

### 5. QS. Az-Zukhruf: 13–14 (Doa Naik Kendaraan)
**Affected items:** `doa_06` (1 item)  
**Source:** Tanzil Uthmani database / Quran.com API v4  
**Change:** `سُبْحَانَ` → `سُبۡحَٰنَ`, `الَّذِي` → `ٱلَّذِي`, `لَهُ` → `لَهُۥ`, ayat separator `۝` added.

```
Before: سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ
After:  سُبۡحَٰنَ ٱلَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُۥ مُقۡرِنِينَ ۝ وَإِنَّآ إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ
```

---

## Items Verified — No Change Needed (Hadith/Dua)

The following 26 items use standard diacritised Arabic, which is the correct script
for hadith and dua text. Uthmani conventions (ٱ, ۡ, ۥ) apply only to Quranic verses.

| ID | Title | Status |
|----|-------|--------|
| pagi_01 | Dzikir Pagi | ✅ Correct (hadith dua) |
| pagi_06 | Sayyidul Istighfar | ✅ Correct (HR. Bukhari 6306) |
| pagi_07 | Subhanallah wa Bihamdihi | ✅ Correct (dhikr phrase) |
| pagi_08 | La Ilaha Illallah Wahdah | ✅ Correct (dhikr phrase) |
| pagi_09 | Shalawat Nabi (Ibrahimiyyah) | ✅ Correct (HR. Bukhari 3370) |
| pagi_10 | Astaghfirullah | ✅ Correct (dhikr phrase) |
| petang_01 | Dzikir Petang | ✅ Correct (hadith dua) |
| petang_06 | Sayyidul Istighfar | ✅ Correct (HR. Bukhari 6306) |
| petang_07 | Subhanallah wa Bihamdihi | ✅ Correct (dhikr phrase) |
| petang_08 | La Ilaha Illallah Wahdah | ✅ Correct (dhikr phrase) |
| petang_09 | Shalawat Nabi | ✅ Correct (HR. Bukhari 3370) |
| petang_10 | Astaghfirullah | ✅ Correct (dhikr phrase) |
| shalat_01 | Istighfar | ✅ Correct (HR. Muslim 591) |
| shalat_02 | Allahumma Antas Salam | ✅ Correct (HR. Muslim 591) |
| shalat_03 | Subhanallah | ✅ Correct (HR. Muslim 597) |
| shalat_04 | Alhamdulillah | ✅ Correct (HR. Muslim 597) |
| shalat_05 | Allahu Akbar | ✅ Correct (HR. Muslim 597) |
| shalat_06 | Penutup Tasbih | ✅ Correct (HR. Muslim 597) |
| shalat_08 | Shalawat Nabi | ✅ Correct (HR. Tirmidzi 484) |
| tidur_01 | Doa Sebelum Tidur | ✅ Correct (HR. Bukhari 6312) |
| tidur_06 | Tasbih Sebelum Tidur | ✅ Correct (HR. Bukhari 3113) |
| doa_01 | Doa Bangun Tidur | ✅ Correct (HR. Bukhari 6312) |
| doa_02 | Doa Masuk Kamar Mandi | ✅ Correct (HR. Bukhari 142) |
| doa_03 | Doa Keluar Kamar Mandi | ✅ Correct (HR. Abu Dawud 30) |
| doa_04 | Doa Sebelum Makan | ✅ Correct (HR. Abu Dawud 3767) |
| doa_05 | Doa Keluar Rumah | ✅ Correct (HR. Abu Dawud 5095) |

---

## arabicScript Field

A new `arabicScript` field has been added to `DzikirItem` (default: `'uthmani'`).

| Value | Meaning | Used for |
|-------|---------|----------|
| `'uthmani'` | Mushaf Madinah / Tanzil encoding | Quranic ayat |
| `'simple'` | Standard diacritised Arabic | Hadith / dua text |
| `'indopak'` | South Asian calligraphic style | Reserved for future use |

All 40 items default to `'uthmani'`. Future items that use simplified or IndoPak
encoding can override this field explicitly.

---

## Encoding Reference

This app uses the **Tanzil Uthmani** encoding, which matches the printed
Mushaf Al-Madinah An-Nabawiyyah (King Fahd Quran Printing Complex standard).

Key Unicode codepoints used:
- `ٱ` U+0671 — Alif Wasla  
- `ۡ` U+06E1 — Uthmani Small High Dotless Head of Khah (sukun)  
- `ۥ` U+06E5 — Arabic Small Waw (dhamir "hu")  
- `ۦ` U+06E6 — Arabic Small Ya (dhamir "hi")  
- `ٰ` U+0670 — Arabic Letter Superscript Alef  
- `ٞ` U+069E — Uthmani Tanwin Damm Above  
- `ۢ` U+06E2 — Arabic Small High Meem Isolated Form (tajweed, not used)

Cross-reference sources:
- Tanzil.net Uthmani database — https://tanzil.net/download/
- Quran.com API v4 (text_uthmani field)
- Hisnul Muslim — Said bin Ali al-Qahthani (Darussalam edition)

---

*Report errors: frosthoot.studio@gmail.com*
