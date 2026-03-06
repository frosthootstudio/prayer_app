/// Latin transliterations for selected surahs.
///
/// Organised as `Map&lt;surahNumber, Map&lt;ayahNumber, transliterationText&gt;&gt;`.
/// Surahs covered: 1 (Al-Fatihah) and the most commonly memorised surahs
/// from Juz 30: 97, 99, 103, 108–114.
/// Returns null for surahs not in this dataset — UI should hide the line.
class TransliterationData {
  TransliterationData._();

  static String? get(int surah, int ayah) =>
      _data[surah]?[ayah];

  static bool hasSurah(int surah) => _data.containsKey(surah);

  static const Map<int, Map<int, String>> _data = {
    // ── Surah 1 – Al-Fatihah ─────────────────────────────────────────────────
    1: {
      1: 'Bismi llāhi r-raḥmāni r-raḥīm',
      2: 'Al-ḥamdu lillāhi rabbi l-ʿālamīn',
      3: 'Ar-raḥmāni r-raḥīm',
      4: 'Māliki yawmi d-dīn',
      5: 'Iyyāka naʿbudu wa-iyyāka nastaʿīn',
      6: 'Ihdinā ṣ-ṣirāṭa l-mustaqīm',
      7: 'Ṣirāṭa lladhīna anʿamta ʿalayhim, ghayri l-maghḍūbi ʿalayhim wa-lā ḍ-ḍāllīn',
    },
    // ── Surah 97 – Al-Qadr ───────────────────────────────────────────────────
    97: {
      1: 'Innā anzalnāhu fī laylati l-qadr',
      2: 'Wa-mā adrāka mā laylatu l-qadr',
      3: 'Laylatu l-qadri khayrun min alfi shahr',
      4: 'Tanazzalu l-malāʾikatu wa-r-rūḥu fīhā bi-idhni rabbihim min kulli amr',
      5: 'Salāmun hiya ḥattā maṭlaʿi l-fajr',
    },
    // ── Surah 99 – Az-Zalzalah ───────────────────────────────────────────────
    99: {
      1: 'Idhā zulzilati l-arḍu zilzālahā',
      2: 'Wa-akhraja l-arḍu athqālahā',
      3: 'Wa-qāla l-insānu mā lahā',
      4: 'Yawmaʾidhin tuḥadditu akhbārahā',
      5: 'Bi-anna rabbaka awḥā lahā',
      6: 'Yawmaʾidhin yaṣduru n-nāsu ashtātan li-yuraw aʿmālahum',
      7: 'Fa-man yaʿmal mithqāla dharratin khayran yarah',
      8: 'Wa-man yaʿmal mithqāla dharratin sharran yarah',
    },
    // ── Surah 103 – Al-Asr ───────────────────────────────────────────────────
    103: {
      1: 'Wa-l-ʿaṣr',
      2: 'Inna l-insāna la-fī khusr',
      3: 'Illā lladhīna āmanū wa-ʿamilū ṣ-ṣāliḥāti wa-tawāṣaw bi-l-ḥaqqi wa-tawāṣaw bi-ṣ-ṣabr',
    },
    // ── Surah 108 – Al-Kawthar ───────────────────────────────────────────────
    108: {
      1: 'Innā aʿṭaynāka l-kawthar',
      2: 'Fa-ṣalli li-rabbika wa-nḥar',
      3: 'Inna shāniʾaka huwa l-abtar',
    },
    // ── Surah 109 – Al-Kafirun ───────────────────────────────────────────────
    109: {
      1: 'Qul yā ayyuhā l-kāfirūn',
      2: 'Lā aʿbudu mā taʿbudūn',
      3: 'Wa-lā antum ʿābidūna mā aʿbud',
      4: 'Wa-lā anā ʿābidun mā ʿabadtum',
      5: 'Wa-lā antum ʿābidūna mā aʿbud',
      6: 'Lakum dīnukum wa-liya dīn',
    },
    // ── Surah 110 – An-Nasr ──────────────────────────────────────────────────
    110: {
      1: 'Idhā jāʾa naṣru llāhi wa-l-fatḥ',
      2: 'Wa-raʾayta n-nāsa yadkhulūna fī dīni llāhi afwājā',
      3: 'Fa-sabbiḥ bi-ḥamdi rabbika wa-staghfirh, innahu kāna tawwābā',
    },
    // ── Surah 112 – Al-Ikhlas ────────────────────────────────────────────────
    112: {
      1: 'Qul huwa llāhu aḥad',
      2: 'Allāhu ṣ-ṣamad',
      3: 'Lam yalid wa-lam yūlad',
      4: 'Wa-lam yakun lahu kufuwan aḥad',
    },
    // ── Surah 113 – Al-Falaq ─────────────────────────────────────────────────
    113: {
      1: 'Qul aʿūdhu bi-rabbi l-falaq',
      2: 'Min sharri mā khalaq',
      3: 'Wa-min sharri ghāsiqin idhā waqab',
      4: 'Wa-min sharri n-naffāthāti fī l-ʿuqad',
      5: 'Wa-min sharri ḥāsidin idhā ḥasad',
    },
    // ── Surah 114 – An-Nas ───────────────────────────────────────────────────
    114: {
      1: 'Qul aʿūdhu bi-rabbi n-nās',
      2: 'Maliki n-nās',
      3: 'Ilāhi n-nās',
      4: 'Min sharri l-waswāsi l-khannās',
      5: 'Alladhī yuwaswisu fī ṣudūri n-nās',
      6: 'Mina l-jinnati wa-n-nās',
    },
  };
}
