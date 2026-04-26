import '../models/dzikir_model.dart';

/// Static repository of all dzikir & doa content.
/// Every item carries a verified hadith or Quranic reference.
/// Sources: Kutub as-Sittah, Hisnul Muslim (Said bin Ali al-Qahthani),
/// Al-Adzkar (Imam An-Nawawi), Al-Silsilah As-Shahihah (Albani).
class DzikirData {
  DzikirData._();

  static const List<DzikirItem> all = [
    // ─────────────────────────────────────────────────────────────────────────
    // PAGI
    // ─────────────────────────────────────────────────────────────────────────

    DzikirItem(
      id:          'pagi_01',
      category:    'pagi',
      count:       1,
      title:       'Dzikir Pagi',
      arabic:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      latin:
          "Allaahumma bika ashbahnaa wa bika amsaynaa, wa bika nahyaa wa bika namuutu, wa ilaykan nusyuur.",
      translation:
          'Ya Allah, dengan-Mu kami memasuki waktu pagi dan petang, dengan-Mu kami hidup dan mati, dan kepada-Mu kami dibangkitkan.',
      reference:   'HR. Abu Dawud no. 5068, Tirmidzi no. 3391',
    ),

    DzikirItem(
      id:          'pagi_02',
      category:    'pagi',
      count:       3,
      title:       'Surah Al-Ikhlas',
      arabic:
          'قُلۡ هُوَ ٱللَّهُ أَحَدٌ ۝ ٱللَّهُ ٱلصَّمَدُ ۝ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ۝ وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدٌ',
      latin:
          "Qul huwallahu ahad, Allahush shamad, lam yalid wa lam yuulad, wa lam yakul lahu kufuwan ahad.",
      translation:
          'Katakanlah: Dialah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan, dan tidak ada yang setara dengan-Nya.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
      note:        'Membaca Al-Ikhlas, Al-Falaq, dan An-Nas sebanyak 3x di pagi, petang, dan sebelum tidur',
    ),

    DzikirItem(
      id:          'pagi_03',
      category:    'pagi',
      count:       3,
      title:       'Surah Al-Falaq',
      arabic:
          'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      latin:
          "Qul a'uudzu birabbil falaq, min syarri maa khalaq, wa min syarri ghaasiqin idzaa waqab, wa min syarrin naffaatsaati fil 'uqad, wa min syarri haasidin idzaa hasad.",
      translation:
          'Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk-Nya, dari kejahatan malam yang gelap, dari kejahatan para tukang sihir, dan dari kejahatan orang yang dengki.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'pagi_04',
      category:    'pagi',
      count:       3,
      title:       'Surah An-Nas',
      arabic:
          'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ۝ مَلِكِ ٱلنَّاسِ ۝ إِلَٰهِ ٱلنَّاسِ ۝ مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ۝ ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ ۝ مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ',
      latin:
          "Qul a'uudzu birabbin naas, malikin naas, ilaahin naas, min syarril waswaasil khannaas, alladzii yuwaswisu fii shuduurin naas, minal jinnati wan naas.",
      translation:
          'Aku berlindung kepada Tuhan pemelihara manusia, Raja manusia, Sembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari golongan jin dan manusia.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'pagi_05',
      category:    'pagi',
      count:       1,
      title:       'Ayat Kursi',
      arabic:
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
      reference:   'QS. Al-Baqarah: 255; Hisnul Muslim, bab dzikir pagi & petang',
    ),

    DzikirItem(
      id:          'pagi_06',
      category:    'pagi',
      count:       1,
      title:       'Sayyidul Istighfar',
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      latin:
          "Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa anaa 'abduka, wa anaa 'alaa 'ahdika wa wa'dika mastatha'tu, a'uudzu bika min syarri maa shana'tu, abuu'u laka bini'matika 'alayya wa abuu'u bidzanbii, faghfir lii fa innahu laa yaghfirudz dzunuuba illaa anta.",
      translation:
          'Ya Allah, Engkau adalah Tuhanku, tiada tuhan selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku berpegang pada perjanjian dan janji-Mu semampu yang aku bisa. Aku berlindung dari kejahatan perbuatanku. Aku mengakui nikmat-Mu atasku dan aku mengakui dosaku, maka ampunilah aku, sebab tidak ada yang mengampuni dosa-dosa kecuali Engkau.',
      reference:   'HR. Bukhari no. 6306',
      note:        'Sayyidul Istighfar (Penghulu Istighfar). Siapa membacanya di pagi dengan penuh keyakinan lalu meninggal di hari itu, maka ia termasuk penghuni surga.',
    ),

    DzikirItem(
      id:          'pagi_07',
      category:    'pagi',
      count:       100,
      title:       'Subhanallah wa Bihamdihi',
      arabic:      'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      latin:       'Subhaanallahi wa bihamdih.',
      translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
      reference:   'HR. Muslim no. 2692',
      note:        'Siapa membacanya 100x di pagi dan petang, akan datang pada hari kiamat tanpa ada yang menandingi kecuali orang yang membaca sepertinya atau lebih.',
    ),

    DzikirItem(
      id:          'pagi_08',
      category:    'pagi',
      count:       10,
      title:       'La Ilaha Illallah Wahdah',
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          "Laa ilaaha illallahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'alaa kulli syay'in qadiir.",
      translation:
          'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya segala kekuasaan dan pujian. Dia Mahakuasa atas segala sesuatu.',
      reference:   'HR. Muslim no. 2693; Hisnul Muslim',
    ),

    DzikirItem(
      id:          'pagi_09',
      category:    'pagi',
      count:       10,
      title:       'Shalawat Nabi',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      latin:
          "Allaahumma shalli 'alaa Muhammad wa 'alaa aali Muhammad, kamaa shallayta 'alaa Ibrahim wa 'alaa aali Ibrahim, innaka hamiidum majiid.",
      translation:
          'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad dan keluarganya, sebagaimana Engkau limpahkan shalawat kepada Ibrahim dan keluarganya. Sesungguhnya Engkau Maha Terpuji lagi Maha Agung.',
      reference:   'HR. Bukhari no. 3370, Muslim no. 406; HR. Tirmidzi no. 484, hasan',
      note:        'Shalawat Ibrahimiyyah. Membaca shalawat 10x di pagi dan petang menjadikan Nabi ﷺ memberikan syafa\'at pada hari kiamat.',
    ),

    DzikirItem(
      id:          'pagi_10',
      category:    'pagi',
      count:       100,
      title:       'Astaghfirullah',
      arabic:
          'أَسْتَغْفِرُ اللهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      latin:
          "Astaghfirullaahal ladzii laa ilaaha illaa huwal hayyul qayyuumu wa atuubu ilayh.",
      translation:
          'Aku memohon ampun kepada Allah yang tiada tuhan selain Dia, Yang Maha Hidup dan Maha Mengurus, dan aku bertaubat kepada-Nya.',
      reference:   'HR. Abu Dawud no. 1516, Tirmidzi no. 3577; Hisnul Muslim',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // PETANG
    // ─────────────────────────────────────────────────────────────────────────

    DzikirItem(
      id:          'petang_01',
      category:    'petang',
      count:       1,
      title:       'Dzikir Petang',
      arabic:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      latin:
          "Allaahumma bika amsaynaa wa bika ashbahnaa, wa bika nahyaa wa bika namuutu, wa ilaykal mashiir.",
      translation:
          'Ya Allah, dengan-Mu kami memasuki waktu petang dan pagi, dengan-Mu kami hidup dan mati, dan kepada-Mu lah tempat kembali.',
      reference:   'HR. Abu Dawud no. 5068, Tirmidzi no. 3391',
    ),

    DzikirItem(
      id:          'petang_02',
      category:    'petang',
      count:       3,
      title:       'Surah Al-Ikhlas',
      arabic:
          'قُلۡ هُوَ ٱللَّهُ أَحَدٌ ۝ ٱللَّهُ ٱلصَّمَدُ ۝ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ۝ وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدٌ',
      latin:
          "Qul huwallahu ahad, Allahush shamad, lam yalid wa lam yuulad, wa lam yakul lahu kufuwan ahad.",
      translation:
          'Katakanlah: Dialah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan, dan tidak ada yang setara dengan-Nya.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
      note:        'Membaca Al-Ikhlas, Al-Falaq, dan An-Nas sebanyak 3x di pagi, petang, dan sebelum tidur',
    ),

    DzikirItem(
      id:          'petang_03',
      category:    'petang',
      count:       3,
      title:       'Surah Al-Falaq',
      arabic:
          'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      latin:
          "Qul a'uudzu birabbil falaq, min syarri maa khalaq, wa min syarri ghaasiqin idzaa waqab, wa min syarrin naffaatsaati fil 'uqad, wa min syarri haasidin idzaa hasad.",
      translation:
          'Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk-Nya, dari kejahatan malam yang gelap, dari kejahatan para tukang sihir, dan dari kejahatan orang yang dengki.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'petang_04',
      category:    'petang',
      count:       3,
      title:       'Surah An-Nas',
      arabic:
          'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ۝ مَلِكِ ٱلنَّاسِ ۝ إِلَٰهِ ٱلنَّاسِ ۝ مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ۝ ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ ۝ مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ',
      latin:
          "Qul a'uudzu birabbin naas, malikin naas, ilaahin naas, min syarril waswaasil khannaas, alladzii yuwaswisu fii shuduurin naas, minal jinnati wan naas.",
      translation:
          'Aku berlindung kepada Tuhan pemelihara manusia, Raja manusia, Sembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari golongan jin dan manusia.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'petang_05',
      category:    'petang',
      count:       1,
      title:       'Ayat Kursi',
      arabic:
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
      reference:   'QS. Al-Baqarah: 255; Hisnul Muslim, bab dzikir pagi & petang',
    ),

    DzikirItem(
      id:          'petang_06',
      category:    'petang',
      count:       1,
      title:       'Sayyidul Istighfar',
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      latin:
          "Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa anaa 'abduka, wa anaa 'alaa 'ahdika wa wa'dika mastatha'tu, a'uudzu bika min syarri maa shana'tu, abuu'u laka bini'matika 'alayya wa abuu'u bidzanbii, faghfir lii fa innahu laa yaghfirudz dzunuuba illaa anta.",
      translation:
          'Ya Allah, Engkau adalah Tuhanku, tiada tuhan selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku berpegang pada perjanjian dan janji-Mu semampu yang aku bisa. Aku berlindung dari kejahatan perbuatanku. Aku mengakui nikmat-Mu atasku dan aku mengakui dosaku, maka ampunilah aku, sebab tidak ada yang mengampuni dosa-dosa kecuali Engkau.',
      reference:   'HR. Bukhari no. 6306',
      note:        'Siapa membacanya di petang dengan penuh keyakinan lalu meninggal di malam itu, maka ia termasuk penghuni surga.',
    ),

    DzikirItem(
      id:          'petang_07',
      category:    'petang',
      count:       100,
      title:       'Subhanallah wa Bihamdihi',
      arabic:      'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      latin:       'Subhaanallahi wa bihamdih.',
      translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
      reference:   'HR. Muslim no. 2692',
      note:        'Menghapus dosa meski sebanyak buih di lautan, dan pahalanya seperti membebaskan 10 budak.',
    ),

    DzikirItem(
      id:          'petang_08',
      category:    'petang',
      count:       10,
      title:       'La Ilaha Illallah Wahdah',
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          "Laa ilaaha illallahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'alaa kulli syay'in qadiir.",
      translation:
          'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya segala kekuasaan dan pujian. Dia Mahakuasa atas segala sesuatu.',
      reference:   'HR. Muslim no. 2693; Hisnul Muslim',
    ),

    DzikirItem(
      id:          'petang_09',
      category:    'petang',
      count:       10,
      title:       'Shalawat Nabi',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      latin:
          "Allaahumma shalli 'alaa Muhammad wa 'alaa aali Muhammad, kamaa shallayta 'alaa Ibrahim wa 'alaa aali Ibrahim, innaka hamiidum majiid.",
      translation:
          'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad dan keluarganya, sebagaimana Engkau limpahkan shalawat kepada Ibrahim dan keluarganya. Sesungguhnya Engkau Maha Terpuji lagi Maha Agung.',
      reference:   'HR. Bukhari no. 3370, Muslim no. 406; HR. Tirmidzi no. 484, hasan',
    ),

    DzikirItem(
      id:          'petang_10',
      category:    'petang',
      count:       100,
      title:       'Astaghfirullah',
      arabic:
          'أَسْتَغْفِرُ اللهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      latin:
          "Astaghfirullaahal ladzii laa ilaaha illaa huwal hayyul qayyuumu wa atuubu ilayh.",
      translation:
          'Aku memohon ampun kepada Allah yang tiada tuhan selain Dia, Yang Maha Hidup dan Maha Mengurus, dan aku bertaubat kepada-Nya.',
      reference:   'HR. Abu Dawud no. 1516, Tirmidzi no. 3577; Hisnul Muslim',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // SETELAH SHALAT
    // ─────────────────────────────────────────────────────────────────────────

    DzikirItem(
      id:          'shalat_01',
      category:    'setelah_shalat',
      count:       3,
      title:       'Istighfar',
      arabic:      'أَسْتَغْفِرُ اللهَ',
      latin:       'Astaghfirullah.',
      translation: 'Aku memohon ampun kepada Allah.',
      reference:   'HR. Muslim no. 591',
      note:        'Nabi ﷺ membaca istighfar 3x setelah salam dari shalat.',
    ),

    DzikirItem(
      id:          'shalat_02',
      category:    'setelah_shalat',
      count:       1,
      title:       'Allahumma Antas Salam',
      arabic:
          'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      latin:
          "Allaahumma antas salaam, wa minkas salaam, tabaarakta yaa dzal jalaali wal ikraam.",
      translation:
          'Ya Allah, Engkau adalah Yang Maha Sejahtera dan dari-Mu lah keselamatan. Maha Berkah Engkau wahai Yang Maha Agung dan Maha Mulia.',
      reference:   'HR. Muslim no. 591',
    ),

    DzikirItem(
      id:          'shalat_03',
      category:    'setelah_shalat',
      count:       33,
      title:       'Subhanallah',
      arabic:      'سُبْحَانَ اللهِ',
      latin:       'Subhaanallah.',
      translation: 'Maha Suci Allah.',
      reference:   'HR. Muslim no. 597',
    ),

    DzikirItem(
      id:          'shalat_04',
      category:    'setelah_shalat',
      count:       33,
      title:       'Alhamdulillah',
      arabic:      'الْحَمْدُ لِلَّهِ',
      latin:       'Alhamdulillah.',
      translation: 'Segala puji bagi Allah.',
      reference:   'HR. Muslim no. 597',
    ),

    DzikirItem(
      id:          'shalat_05',
      category:    'setelah_shalat',
      count:       33,
      title:       'Allahu Akbar',
      arabic:      'اللهُ أَكْبَرُ',
      latin:       'Allahu akbar.',
      translation: 'Allah Maha Besar.',
      reference:   'HR. Muslim no. 597',
    ),

    DzikirItem(
      id:          'shalat_06',
      category:    'setelah_shalat',
      count:       1,
      title:       'Penutup Tasbih',
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          "Laa ilaaha illallahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'alaa kulli syay'in qadiir.",
      translation:
          'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya segala kekuasaan dan pujian. Dia Mahakuasa atas segala sesuatu.',
      reference:   'HR. Muslim no. 597',
      note:        'Melengkapi hitungan 100 setelah Subhanallah 33x, Alhamdulillah 33x, Allahu Akbar 33x.',
    ),

    DzikirItem(
      id:          'shalat_07',
      category:    'setelah_shalat',
      count:       1,
      title:       'Ayat Kursi',
      arabic:
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
      reference:   'Al-Silsilah As-Shahihah no. 972 (Albani); HR. An-Nasai, Thabrani dari Abu Umamah',
      note:        'Siapa membacanya setelah setiap shalat fardhu, tidak ada yang menghalanginya masuk surga kecuali kematian.',
    ),

    DzikirItem(
      id:          'shalat_08',
      category:    'setelah_shalat',
      count:       10,
      title:       'Shalawat Nabi',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      latin:
          "Allaahumma shalli 'alaa Muhammad wa 'alaa aali Muhammad, kamaa shallayta 'alaa Ibrahim wa 'alaa aali Ibrahim, innaka hamiidum majiid.",
      translation:
          'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad dan keluarganya, sebagaimana Engkau limpahkan shalawat kepada Ibrahim dan keluarganya. Sesungguhnya Engkau Maha Terpuji lagi Maha Agung.',
      reference:   'HR. Tirmidzi no. 484, hasan lighairihi',
      note:        'Dianjurkan khususnya setelah shalat Subuh dan Maghrib.',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // TIDUR
    // ─────────────────────────────────────────────────────────────────────────

    DzikirItem(
      id:          'tidur_01',
      category:    'tidur',
      count:       1,
      title:       'Doa Sebelum Tidur',
      arabic:      'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      latin:       'Bismikallahumma amuutu wa ahyaa.',
      translation: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
      reference:   'HR. Bukhari no. 6312',
    ),

    DzikirItem(
      id:          'tidur_02',
      category:    'tidur',
      count:       3,
      title:       'Surah Al-Ikhlas',
      arabic:
          'قُلۡ هُوَ ٱللَّهُ أَحَدٌ ۝ ٱللَّهُ ٱلصَّمَدُ ۝ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ۝ وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدٌ',
      latin:
          "Qul huwallahu ahad, Allahush shamad, lam yalid wa lam yuulad, wa lam yakul lahu kufuwan ahad.",
      translation:
          'Katakanlah: Dialah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan, dan tidak ada yang setara dengan-Nya.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'tidur_03',
      category:    'tidur',
      count:       3,
      title:       'Surah Al-Falaq',
      arabic:
          'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      latin:
          "Qul a'uudzu birabbil falaq, min syarri maa khalaq, wa min syarri ghaasiqin idzaa waqab, wa min syarrin naffaatsaati fil 'uqad, wa min syarri haasidin idzaa hasad.",
      translation:
          'Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk-Nya, dari kejahatan malam yang gelap, dari kejahatan para tukang sihir, dan dari kejahatan orang yang dengki.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'tidur_04',
      category:    'tidur',
      count:       3,
      title:       'Surah An-Nas',
      arabic:
          'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ۝ مَلِكِ ٱلنَّاسِ ۝ إِلَٰهِ ٱلنَّاسِ ۝ مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ۝ ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ ۝ مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ',
      latin:
          "Qul a'uudzu birabbin naas, malikin naas, ilaahin naas, min syarril waswaasil khannaas, alladzii yuwaswisu fii shuduurin naas, minal jinnati wan naas.",
      translation:
          'Aku berlindung kepada Tuhan pemelihara manusia, Raja manusia, Sembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari golongan jin dan manusia.',
      reference:   'HR. Abu Dawud no. 5082, Tirmidzi no. 3575, shahih',
    ),

    DzikirItem(
      id:          'tidur_05',
      category:    'tidur',
      count:       1,
      title:       'Ayat Kursi',
      arabic:
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
      reference:   'HR. Bukhari no. 2311',
      note:        'Siapa membacanya sebelum tidur, Allah senantiasa menjaganya dan setan tidak mendekatinya.',
    ),

    DzikirItem(
      id:          'tidur_06',
      category:    'tidur',
      count:       33,
      title:       'Tasbih Sebelum Tidur',
      arabic:      'سُبْحَانَ اللهِ',
      latin:       'Subhaanallah.',
      translation: 'Maha Suci Allah.',
      reference:   'HR. Bukhari no. 3113, Muslim no. 2727',
      note:        'Lengkapi dengan Alhamdulillah 33x dan Allahu Akbar 34x. Dari Ali bin Abi Thalib, Nabi ﷺ mengajarkan ini kepada Fatimah sebagai pengganti pembantu rumah tangga.',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // DOA
    // ─────────────────────────────────────────────────────────────────────────

    DzikirItem(
      id:          'doa_01',
      category:    'doa',
      count:       1,
      title:       'Doa Bangun Tidur',
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      latin:
          "Alhamdulillaahil ladzii ahyaanaa ba'da maa amaatanaa wa ilayhin nusyuur.",
      translation:
          'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan kepada-Nya tempat kembali.',
      reference:   'HR. Bukhari no. 6312',
    ),

    DzikirItem(
      id:          'doa_02',
      category:    'doa',
      count:       1,
      title:       'Doa Masuk Kamar Mandi',
      arabic:
          'بِسْمِ اللهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      latin:
          "Bismillah, Allaahumma innii a'uudzu bika minal khubutsi wal khabaa'its.",
      translation:
          'Dengan nama Allah. Ya Allah, aku berlindung kepada-Mu dari setan laki-laki dan perempuan.',
      reference:   'HR. Bukhari no. 142, Muslim no. 375',
    ),

    DzikirItem(
      id:          'doa_03',
      category:    'doa',
      count:       1,
      title:       'Doa Keluar Kamar Mandi',
      arabic:
          'غُفْرَانَكَ، الْحَمْدُ لِلَّهِ الَّذِي أَذْهَبَ عَنِّي الْأَذَى وَعَافَانِي',
      latin:
          "Ghufraaanak, alhamdulillaahil ladzii adzhaba 'annil adzaa wa 'aafaanii.",
      translation:
          'Aku memohon ampunan-Mu. Segala puji bagi Allah yang telah menghilangkan penyakit dariku dan menyehatkanku.',
      reference:   'HR. Abu Dawud no. 30, Tirmidzi no. 7, shahih; HR. Ibn Majah no. 301',
    ),

    DzikirItem(
      id:          'doa_04',
      category:    'doa',
      count:       1,
      title:       'Doa Sebelum Makan',
      arabic:      'بِسْمِ اللهِ وَعَلَى بَرَكَةِ اللهِ',
      latin:       "Bismillahi wa 'alaa barakatillah.",
      translation: 'Dengan nama Allah dan atas berkah Allah.',
      reference:   'HR. Abu Dawud no. 3767',
    ),

    DzikirItem(
      id:          'doa_05',
      category:    'doa',
      count:       1,
      title:       'Doa Keluar Rumah',
      arabic:
          'بِسْمِ اللهِ، تَوَكَّلْتُ عَلَى اللهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
      latin:
          "Bismillahi, tawakkaltu 'alallahi, wa laa hawla wa laa quwwata illaa billah.",
      translation:
          'Dengan nama Allah, aku bertawakal kepada Allah, tidak ada daya dan kekuatan kecuali dengan Allah.',
      reference:   'HR. Abu Dawud no. 5095, Tirmidzi no. 3426, shahih',
      note:        'Malaikat berkata kepada orang yang membacanya: "Engkau telah diberi petunjuk, dicukupkan, dan dilindungi."',
    ),

    DzikirItem(
      id:          'doa_06',
      category:    'doa',
      count:       1,
      title:       'Doa Naik Kendaraan',
      arabic:
          'سُبۡحَٰنَ ٱلَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُۥ مُقۡرِنِينَ ۝ وَإِنَّآ إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
      latin:
          "Subhaanalladzii sakhkhara lanaa haadzaa wa maa kunnaa lahu muqriniin, wa innaa ilaa rabbinaa lamunqalibuun.",
      translation:
          'Maha Suci Allah yang telah menundukkan semua ini bagi kami, padahal kami sebelumnya tidak mampu menguasainya, dan sesungguhnya kami akan kembali kepada Tuhan kami.',
      reference:   'HR. Muslim no. 1342; QS. Az-Zukhruf: 13-14',
    ),
  ];
}
