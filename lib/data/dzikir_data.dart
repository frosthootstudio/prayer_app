import '../models/dzikir_model.dart';

/// Static repository of all dzikir & doa content.
class DzikirData {
  DzikirData._();

  static const List<DzikirItem> all = [
    // ─────────────────────────────────────────────────────────────────────────
    // PAGI
    // ─────────────────────────────────────────────────────────────────────────
    DzikirItem(
      id: 'pagi_01',
      category: 'pagi',
      count: 1,
      title: 'Dzikir Pagi',
      arabic:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      latin:
          "Allahumma bika ashbahnaa wa bika amsaynaa, wa bika nahyaa wa bika namuutu, wa ilaykan nusyuur.",
      translation:
          'Ya Allah, dengan-Mu kami memasuki pagi dan petang, dengan-Mu kami hidup dan mati, dan kepada-Mu kebangkitan.',
    ),
    DzikirItem(
      id: 'pagi_02',
      category: 'pagi',
      count: 3,
      title: 'Surah Al-Ikhlas',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      latin:
          "Qul huwallahu ahad, Allahush shamad, lam yalid wa lam yuulad, wa lam yakul lahu kufuwan ahad.",
      translation:
          'Katakanlah: Dialah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan, dan tidak ada yang setara dengan-Nya.',
    ),
    DzikirItem(
      id: 'pagi_03',
      category: 'pagi',
      count: 3,
      title: 'Surah Al-Falaq',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      latin:
          "Qul a'uudzu birabbil falaq, min syarri maa khalaq, wa min syarri ghaasiqin idzaa waqab, wa min syarrin naffaatsaati fil 'uqad, wa min syarri haasidin idzaa hasad.",
      translation:
          'Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk-Nya, malam yang gelap, para tukang sihir, dan orang yang dengki.',
    ),
    DzikirItem(
      id: 'pagi_04',
      category: 'pagi',
      count: 3,
      title: 'Surah An-Nas',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      latin:
          "Qul a'uudzu birabbin naas, malikin naas, ilaahin naas, min syarril waswaasil khannaas, alladzii yuwaswisu fii shuduurin naas, minal jinnati wan naas.",
      translation:
          'Aku berlindung kepada Tuhan pemelihara manusia, Raja manusia, Sembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari golongan jin dan manusia.',
    ),
    DzikirItem(
      id: 'pagi_05',
      category: 'pagi',
      count: 1,
      title: 'Ayat Kursi',
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
    ),
    DzikirItem(
      id: 'pagi_06',
      category: 'pagi',
      count: 1,
      title: 'Sayyidul Istighfar',
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      latin:
          "Allahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa anaa 'abduka, wa anaa 'alaa 'ahdika wa wa'dika mastatha'tu, a'uudzu bika min syarri maa shana'tu, abuu'u laka bini'matika 'alayya wa abuu'u bidzanbii, faghfir lii fa innahu laa yaghfirudz dzunuuba illaa anta.",
      translation:
          'Ya Allah, Engkau adalah Tuhanku, tiada tuhan selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku pada perjanjian dan janji-Mu sesuai kemampuanku. Aku berlindung dari kejahatan perbuatanku. Aku mengakui nikmat-Mu dan dosaku, maka ampunilah aku.',
    ),
    DzikirItem(
      id: 'pagi_07',
      category: 'pagi',
      count: 100,
      title: 'Subhanallah wa Bihamdihi',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      latin: 'Subhaanallahi wa bihamdih.',
      translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
    ),
    DzikirItem(
      id: 'pagi_08',
      category: 'pagi',
      count: 10,
      title: 'La Ilaha Illallah',
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          "Laa ilaaha illallahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'alaa kulli syay'in qadiir.",
      translation:
          'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya segala kekuasaan dan pujian. Dia Mahakuasa atas segala sesuatu.',
    ),
    DzikirItem(
      id: 'pagi_09',
      category: 'pagi',
      count: 10,
      title: 'Shalawat Nabi',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      latin:
          "Allahumma shalli 'alaa Muhammad wa 'alaa aali Muhammad, kamaa shallayta 'alaa Ibrahim wa 'alaa aali Ibrahim, innaka hamiidum majiid.",
      translation:
          'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad dan keluarganya, sebagaimana Engkau limpahkan shalawat kepada Ibrahim dan keluarganya. Sesungguhnya Engkau Maha Terpuji lagi Maha Agung.',
    ),
    DzikirItem(
      id: 'pagi_10',
      category: 'pagi',
      count: 100,
      title: 'Astaghfirullah',
      arabic:
          'أَسْتَغْفِرُ اللهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      latin:
          "Astaghfirullaahal ladzii laa ilaaha illaa huwal hayyul qayyuumu wa atuubu ilayh.",
      translation:
          'Aku memohon ampun kepada Allah yang tiada tuhan selain Dia, Yang Maha Hidup dan Maha Mengurus, dan aku bertaubat kepada-Nya.',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // PETANG
    // ─────────────────────────────────────────────────────────────────────────
    DzikirItem(
      id: 'petang_01',
      category: 'petang',
      count: 1,
      title: 'Dzikir Petang',
      arabic:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      latin:
          "Allahumma bika amsaynaa wa bika ashbahnaa, wa bika nahyaa wa bika namuutu, wa ilaykal mashiir.",
      translation:
          'Ya Allah, dengan-Mu kami memasuki petang dan pagi, dengan-Mu kami hidup dan mati, dan kepada-Mu lah tempat kembali.',
    ),
    DzikirItem(
      id: 'petang_02',
      category: 'petang',
      count: 3,
      title: 'Surah Al-Ikhlas',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      latin:
          "Qul huwallahu ahad, Allahush shamad, lam yalid wa lam yuulad, wa lam yakul lahu kufuwan ahad.",
      translation:
          'Katakanlah: Dialah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan, dan tidak ada yang setara dengan-Nya.',
    ),
    DzikirItem(
      id: 'petang_03',
      category: 'petang',
      count: 3,
      title: 'Surah Al-Falaq',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      latin:
          "Qul a'uudzu birabbil falaq, min syarri maa khalaq, wa min syarri ghaasiqin idzaa waqab, wa min syarrin naffaatsaati fil 'uqad, wa min syarri haasidin idzaa hasad.",
      translation:
          'Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk-Nya, malam yang gelap, para tukang sihir, dan orang yang dengki.',
    ),
    DzikirItem(
      id: 'petang_04',
      category: 'petang',
      count: 3,
      title: 'Surah An-Nas',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      latin:
          "Qul a'uudzu birabbin naas, malikin naas, ilaahin naas, min syarril waswaasil khannaas, alladzii yuwaswisu fii shuduurin naas, minal jinnati wan naas.",
      translation:
          'Aku berlindung kepada Tuhan pemelihara manusia, Raja manusia, Sembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari golongan jin dan manusia.',
    ),
    DzikirItem(
      id: 'petang_05',
      category: 'petang',
      count: 1,
      title: 'Ayat Kursi',
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
    ),
    DzikirItem(
      id: 'petang_06',
      category: 'petang',
      count: 1,
      title: 'Sayyidul Istighfar',
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      latin:
          "Allahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa anaa 'abduka, wa anaa 'alaa 'ahdika wa wa'dika mastatha'tu, a'uudzu bika min syarri maa shana'tu, abuu'u laka bini'matika 'alayya wa abuu'u bidzanbii, faghfir lii fa innahu laa yaghfirudz dzunuuba illaa anta.",
      translation:
          'Ya Allah, Engkau adalah Tuhanku, tiada tuhan selain Engkau. Engkau menciptakanku dan aku adalah hamba-Mu. Aku pada perjanjian dan janji-Mu sesuai kemampuanku. Aku berlindung dari kejahatan perbuatanku. Aku mengakui nikmat-Mu dan dosaku, maka ampunilah aku.',
    ),
    DzikirItem(
      id: 'petang_07',
      category: 'petang',
      count: 100,
      title: 'Subhanallah wa Bihamdihi',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      latin: 'Subhaanallahi wa bihamdih.',
      translation: 'Maha Suci Allah dan segala puji bagi-Nya.',
    ),
    DzikirItem(
      id: 'petang_08',
      category: 'petang',
      count: 10,
      title: 'La Ilaha Illallah',
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          "Laa ilaaha illallahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'alaa kulli syay'in qadiir.",
      translation:
          'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya segala kekuasaan dan pujian. Dia Mahakuasa atas segala sesuatu.',
    ),
    DzikirItem(
      id: 'petang_09',
      category: 'petang',
      count: 10,
      title: 'Shalawat Nabi',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      latin:
          "Allahumma shalli 'alaa Muhammad wa 'alaa aali Muhammad, kamaa shallayta 'alaa Ibrahim wa 'alaa aali Ibrahim, innaka hamiidum majiid.",
      translation:
          'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad dan keluarganya, sebagaimana Engkau limpahkan shalawat kepada Ibrahim dan keluarganya. Sesungguhnya Engkau Maha Terpuji lagi Maha Agung.',
    ),
    DzikirItem(
      id: 'petang_10',
      category: 'petang',
      count: 100,
      title: 'Astaghfirullah',
      arabic:
          'أَسْتَغْفِرُ اللهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      latin:
          "Astaghfirullaahal ladzii laa ilaaha illaa huwal hayyul qayyuumu wa atuubu ilayh.",
      translation:
          'Aku memohon ampun kepada Allah yang tiada tuhan selain Dia, Yang Maha Hidup dan Maha Mengurus, dan aku bertaubat kepada-Nya.',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // SETELAH SHALAT
    // ─────────────────────────────────────────────────────────────────────────
    DzikirItem(
      id: 'shalat_01',
      category: 'setelah_shalat',
      count: 3,
      title: 'Istighfar',
      arabic: 'أَسْتَغْفِرُ اللهَ',
      latin: 'Astaghfirullah.',
      translation: 'Aku memohon ampun kepada Allah.',
    ),
    DzikirItem(
      id: 'shalat_02',
      category: 'setelah_shalat',
      count: 1,
      title: 'Allahumma Antas Salam',
      arabic:
          'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      latin:
          "Allahumma antas salaam, wa minkas salaam, tabaarakta yaa dzal jalaali wal ikraam.",
      translation:
          'Ya Allah, Engkau adalah Yang Maha Sejahtera dan dari-Mu lah keselamatan. Maha Berkah Engkau wahai Yang Maha Agung dan Maha Mulia.',
    ),
    DzikirItem(
      id: 'shalat_03',
      category: 'setelah_shalat',
      count: 33,
      title: 'Subhanallah',
      arabic: 'سُبْحَانَ اللهِ',
      latin: 'Subhaanallah.',
      translation: 'Maha Suci Allah.',
    ),
    DzikirItem(
      id: 'shalat_04',
      category: 'setelah_shalat',
      count: 33,
      title: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      latin: 'Alhamdulillah.',
      translation: 'Segala puji bagi Allah.',
    ),
    DzikirItem(
      id: 'shalat_05',
      category: 'setelah_shalat',
      count: 33,
      title: 'Allahu Akbar',
      arabic: 'اللهُ أَكْبَرُ',
      latin: 'Allahu akbar.',
      translation: 'Allah Maha Besar.',
    ),
    DzikirItem(
      id: 'shalat_06',
      category: 'setelah_shalat',
      count: 1,
      title: 'Penutup Tasbih',
      arabic:
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      latin:
          "Laa ilaaha illallahu wahdahu laa syariika lah, lahul mulku wa lahul hamdu wa huwa 'alaa kulli syay'in qadiir.",
      translation:
          'Tidak ada tuhan selain Allah semata, tiada sekutu bagi-Nya. Milik-Nya segala kekuasaan dan pujian. Dia Mahakuasa atas segala sesuatu.',
    ),
    DzikirItem(
      id: 'shalat_07',
      category: 'setelah_shalat',
      count: 1,
      title: 'Ayat Kursi',
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
    ),
    DzikirItem(
      id: 'shalat_08',
      category: 'setelah_shalat',
      count: 10,
      title: 'Shalawat Nabi',
      arabic:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      latin:
          "Allahumma shalli 'alaa Muhammad wa 'alaa aali Muhammad, kamaa shallayta 'alaa Ibrahim wa 'alaa aali Ibrahim, innaka hamiidum majiid.",
      translation:
          'Ya Allah, limpahkanlah shalawat kepada Nabi Muhammad dan keluarganya, sebagaimana Engkau limpahkan shalawat kepada Ibrahim dan keluarganya. Sesungguhnya Engkau Maha Terpuji lagi Maha Agung.',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // TIDUR
    // ─────────────────────────────────────────────────────────────────────────
    DzikirItem(
      id: 'tidur_01',
      category: 'tidur',
      count: 1,
      title: 'Doa Sebelum Tidur',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      latin: 'Bismikallahumma amuutu wa ahyaa.',
      translation: 'Dengan nama-Mu ya Allah, aku mati dan aku hidup.',
    ),
    DzikirItem(
      id: 'tidur_02',
      category: 'tidur',
      count: 3,
      title: 'Surah Al-Ikhlas',
      arabic:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      latin:
          "Qul huwallahu ahad, Allahush shamad, lam yalid wa lam yuulad, wa lam yakul lahu kufuwan ahad.",
      translation:
          'Katakanlah: Dialah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tidak beranak dan tidak pula diperanakkan, dan tidak ada yang setara dengan-Nya.',
    ),
    DzikirItem(
      id: 'tidur_03',
      category: 'tidur',
      count: 3,
      title: 'Surah Al-Falaq',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      latin:
          "Qul a'uudzu birabbil falaq, min syarri maa khalaq, wa min syarri ghaasiqin idzaa waqab, wa min syarrin naffaatsaati fil 'uqad, wa min syarri haasidin idzaa hasad.",
      translation:
          'Aku berlindung kepada Tuhan yang menguasai subuh, dari kejahatan makhluk-Nya, malam yang gelap, para tukang sihir, dan orang yang dengki.',
    ),
    DzikirItem(
      id: 'tidur_04',
      category: 'tidur',
      count: 3,
      title: 'Surah An-Nas',
      arabic:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
      latin:
          "Qul a'uudzu birabbin naas, malikin naas, ilaahin naas, min syarril waswaasil khannaas, alladzii yuwaswisu fii shuduurin naas, minal jinnati wan naas.",
      translation:
          'Aku berlindung kepada Tuhan pemelihara manusia, Raja manusia, Sembahan manusia, dari kejahatan bisikan setan yang bersembunyi, yang membisikkan kejahatan ke dalam dada manusia, dari golongan jin dan manusia.',
    ),
    DzikirItem(
      id: 'tidur_05',
      category: 'tidur',
      count: 1,
      title: 'Ayat Kursi',
      arabic:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      latin:
          "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhu sinatuw wa laa nawm, lahu maa fis samaawaati wa maa fil ardh, man dzal ladzii yasyfa'u 'indahu illaa bi'idznih, ya'lamu maa bayna aydiihim wa maa khalfahum, wa laa yuhiithuuna bisyay'im min 'ilmihi illaa bimaa syaa', wasi'a kursiyyuhus samaawaati wal ardha, wa laa ya'uuduhu hifzhuhumaa, wa huwal 'aliyyul 'azhiim.",
      translation:
          'Allah, tidak ada tuhan selain Dia, Yang Maha Hidup dan terus-menerus mengurus makhluk-Nya. Tidak dilanda kantuk dan tidak pula tidur. Milik-Nya apa yang ada di langit dan bumi. Kursi-Nya meliputi langit dan bumi. Dialah Yang Mahatinggi lagi Mahaagung.',
    ),
    DzikirItem(
      id: 'tidur_06',
      category: 'tidur',
      count: 33,
      title: 'Tasbih Sebelum Tidur',
      arabic: 'سُبْحَانَ اللهِ',
      latin: 'Subhaanallah.',
      translation: 'Maha Suci Allah.',
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // DOA
    // ─────────────────────────────────────────────────────────────────────────
    DzikirItem(
      id: 'doa_01',
      category: 'doa',
      count: 1,
      title: 'Doa Bangun Tidur',
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      latin:
          "Alhamdulillaahil ladzii ahyaanaa ba'da maa amaatanaa wa ilayhin nusyuur.",
      translation:
          'Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan kepada-Nya tempat kembali.',
    ),
    DzikirItem(
      id: 'doa_02',
      category: 'doa',
      count: 1,
      title: 'Doa Masuk Kamar Mandi',
      arabic:
          'بِسْمِ اللهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      latin:
          "Bismillah, Allahumma innii a'uudzu bika minal khubutsi wal khabaa'its.",
      translation:
          'Dengan nama Allah. Ya Allah, aku berlindung kepada-Mu dari setan laki-laki dan perempuan.',
    ),
    DzikirItem(
      id: 'doa_03',
      category: 'doa',
      count: 1,
      title: 'Doa Keluar Kamar Mandi',
      arabic:
          'غُفْرَانَكَ، الْحَمْدُ لِلَّهِ الَّذِي أَذْهَبَ عَنِّي الْأَذَى وَعَافَانِي',
      latin:
          "Ghufraaanak, alhamdulillaahil ladzii adzhaba 'annil adzaa wa 'aafaanii.",
      translation:
          'Aku memohon ampunan-Mu. Segala puji bagi Allah yang telah menghilangkan penyakit dariku dan menyehatkanku.',
    ),
    DzikirItem(
      id: 'doa_04',
      category: 'doa',
      count: 1,
      title: 'Doa Sebelum Makan',
      arabic: 'بِسْمِ اللهِ وَعَلَى بَرَكَةِ اللهِ',
      latin: "Bismillahi wa 'alaa barakatillah.",
      translation: 'Dengan nama Allah dan atas berkah Allah.',
    ),
    DzikirItem(
      id: 'doa_05',
      category: 'doa',
      count: 1,
      title: 'Doa Keluar Rumah',
      arabic:
          'بِسْمِ اللهِ، تَوَكَّلْتُ عَلَى اللهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
      latin:
          "Bismillahi, tawakkaltu 'alallahi, wa laa hawla wa laa quwwata illaa billah.",
      translation:
          'Dengan nama Allah, aku bertawakal kepada Allah, tidak ada daya dan kekuatan kecuali dengan Allah.',
    ),
    DzikirItem(
      id: 'doa_06',
      category: 'doa',
      count: 1,
      title: 'Doa Naik Kendaraan',
      arabic:
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
      latin:
          "Subhaanalladzii sakhkhara lanaa haadzaa wa maa kunnaa lahu muqriniin, wa innaa ilaa rabbinaa lamunqalibuun.",
      translation:
          'Maha Suci Allah yang telah menundukkan semua ini bagi kami, padahal kami sebelumnya tidak mampu menguasainya, dan sesungguhnya kami akan kembali kepada Tuhan kami.',
    ),
  ];
}
