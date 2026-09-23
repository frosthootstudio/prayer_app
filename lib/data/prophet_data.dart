import '../models/prophet_model.dart';

abstract final class ProphetData {
  static const List<ProphetModel> prophets = [
    ProphetModel(
      id: 1,
      name: 'Nabi Adam AS',
      arabicName: 'آدَمُ عَلَيْهِ السَّلَامُ',
      era: 'Manusia Pertama',
      place: 'Surga lalu turun ke Bumi (India & Makkah)',
      isUlulAzmi: false,
      miracles: [
        'Diciptakan langsung oleh Allah SWT dari tanah tanpa perantara ayah dan ibu.',
        'Diajarkan langsung oleh Allah seluruh nama-nama benda di alam semesta.',
        'Memiliki umur yang panjang dan postur tubuh yang agung.',
      ],
      story:
          'Nabi Adam AS adalah manusia pertama sekaligus nabi pertama yang diciptakan oleh Allah SWT dari sari pati tanah dan ditiupkan ruh ke dalamnya. Allah memerintahkan para malaikat dan iblis untuk bersujud menghormati Adam. Malaikat patuh, sedangkan iblis membangkang karena kesombongan merasa dirinya diciptakan dari api yang lebih mulia dari tanah.\n\n'
          'Allah kemudian menciptakan Siti Hawa sebagai pasangan Adam dan mengizinkan mereka tinggal di surga dengan satu larangan: tidak mendekati pohon terlarang (pohon khuldi). Namun, godaan iblis yang terus membujuk membuat Adam dan Hawa lupa hingga memakan buah pohon tersebut. Mereka segera bertaubat dengan penuh penyesalan dengan doa yang diabadikan dalam Al-Qur\'an (QS. Al-A\'raf: 23). Allah menerima taubat mereka dan menurunkan keduanya ke bumi untuk memulai peradaban manusia sebagai khalifah.',
      moralLessons: [
        'Menjauhi sifat sombong dan iri dengki seperti iblis yang menjadi penyebab kehancuran.',
        'Segera bertaubat dan mengakui kesalahan kepada Allah tanpa menunda-nunda.',
        'Pentingnya menjaga ketaatan kepada syariat dan waspada terhadap bisikan setan.',
      ],
    ),
    ProphetModel(
      id: 2,
      name: 'Nabi Idris AS',
      arabicName: 'إِدْرِيسُ عَلَيْهِ السَّلَامُ',
      era: 'Keturunan Keenam Nabi Adam AS',
      place: 'Babilonia (Irak) & Mesir',
      isUlulAzmi: false,
      miracles: [
        'Manusia pertama yang mengenal baca tulis dengan pena.',
        'Menguasai ilmu perbintangan (astronomi) dan matematika dasar.',
        'Ahli menjahit pakaian pertama dari kain (sebelumnya manusia memakai kulit hewan).',
        'Diangkat oleh Allah ke tempat yang tinggi (martabat mulia di langit).',
      ],
      story:
          'Nabi Idris AS adalah nabi kedua yang diutus Allah. Beliau terkenal sangat tekun beribadah, gagah berani menegakkan kebenaran, dan memiliki kecerdasan yang luar biasa. Namanya diambil dari kata "Darasa" yang bermakna banyak belajar atau mengkaji.\n\n'
          'Di masanya, banyak manusia yang mulai melupakan ajaran tauhid warisan Nabi Adam dan Nabi Syits. Nabi Idris berdakwah dengan sabar mengajak kaumnya kembali menyembah Allah. Beliau juga memelopori kemajuan peradaban manusia melalui tulisan pena, perhitungan waktu, dan pakaian yang dijahit rapi. Karena kesalehannya, Allah memujinya dalam QS. Maryam: 56-57 sebagai orang yang sangat membenarkan dan seorang nabi yang diangkat ke martabat yang tinggi.',
      moralLessons: [
        'Mencari ilmu pengetahuan dan teknologi sejalan dengan keimanan kepada Allah.',
        'Keberanian dalam membela kebenaran meskipun berada di tengah masyarakat yang lalai.',
        'Disiplin dalam beribadah dan selalu bertasbih kepada Allah di setiap waktu.',
      ],
    ),
    ProphetModel(
      id: 3,
      name: 'Nabi Nuh AS',
      arabicName: 'نُوحٌ عَلَيْهِ السَّلَامُ',
      era: 'Generasi Awal Setelah Nabi Idris',
      place: 'Mesopotamia (Irak Selatan)',
      isUlulAzmi: true,
      miracles: [
        'Mampu membuat bahtera (kapal raksasa) di atas bukit yang tandus atas wahyu Allah.',
        'Bahtera selamat melayari banjir bandang terdahsyat yang menenggelamkan bumi dan kaum kafir.',
        'Usia dakwah yang sangat panjang mencapai 950 tahun dengan kesabaran luar biasa.',
      ],
      story:
          'Nabi Nuh AS adalah rasul pertama yang diutus ke bumi dan termasuk dalam golongan rasul Ulul Azmi karena kesabarannya yang amat teguh. Di masanya, manusia pertama kali menyembah berhala-berhala (Wadd, Suwa\', Yaghuts, Ya\'uq, dan Nasr).\n\n'
          'Nabi Nuh berdakwah selama 950 tahun, baik secara terang-terangan maupun sembunyi-sembunyi, siang dan malam. Namun sebagian besar kaumnya, termasuk istri dan salah satu putranya (Kan\'an), menolak ajaran beliau dan mengejeknya. Allah kemudian memerintahkan Nabi Nuh membuat kapal besar di atas bukit. Ketika banjir besar melanda, hanya orang-orang beriman dan sepasang hewan dari setiap jenis yang selamat di dalam kapal, sementara kaum yang ingkar tenggelam binasa.',
      moralLessons: [
        'Kesabaran tanpa batas dalam mendakwahkan kebaikan dan kebenaran.',
        'Ikatan keimanan lebih utama daripada ikatan darah semata (kisah Kan\'an).',
        'Keyakinan teguh bahwa janji dan pertolongan Allah pasti akan tiba pada waktunya.',
      ],
    ),
    ProphetModel(
      id: 4,
      name: 'Nabi Hud AS',
      arabicName: 'هُودٌ عَلَيْهِ السَّلَامُ',
      era: 'Pasca Kaum Nuh AS',
      place: 'Al-Ahqaf (Antara Yaman & Oman)',
      isUlulAzmi: false,
      miracles: [
        'Selamat dari ancaman fisik dan pembunuhan oleh kaum \'Ad yang bertubuh raksasa.',
        'Dianugerahi pertolongan saat angin topan dahsyat (Shashar) yang dingin menerjang kaumnya selama 7 malam 8 hari.',
      ],
      story:
          'Nabi Hud AS diutus kepada kaum \'Ad, kaum yang dianugerahi fisik yang kekar, tinggi besar, serta keahlian mendirikan istana-istana megah di pegunungan (Iram yang memiliki tiang-tiang tinggi). Namun, mereka sombong dengan kekuatannya dan berkata: "Siapakah yang lebih kuat dari kami?". Mereka juga menyembah berhala dan menindas kaum yang lemah.\n\n'
          'Nabi Hud mengingatkan mereka akan nikmat Allah dan azab bagi orang yang ingkar. Namun kaum \'Ad menantang agar azab tersebut didatangkan. Allah menghentikan hujan hingga kekeringan panjang, lalu mengirim gumpalan awan hitam yang mereka sangka membawa air hujan. Kenyataannya, awan tersebut membawa angin dingin yang membeku dan sangat dahsyat, membinasakan seluruh kaum yang sombong hingga tak bersisa, sementara Nabi Hud dan orang beriman diselamatkan.',
      moralLessons: [
        'Kekuatan fisik, kekayaan, dan teknologi megah tidak akan mampu menandingi kekuasaan Allah.',
        'Kesombongan atas nikmat duniawi adalah pangkal dari kehancuran suatu peradaban.',
        'Selalu bersyukur dan menggunakan kelebihan raga untuk ketaatan.',
      ],
    ),
    ProphetModel(
      id: 5,
      name: 'Nabi Shaleh AS',
      arabicName: 'صَالِحٌ عَلَيْهِ السَّلَامُ',
      era: 'Pasca Kaum \'Ad',
      place: 'Al-Hijr (Madain Saleh, Arab Saudi Utara)',
      isUlulAzmi: false,
      miracles: [
        'Mengeluarkan seekor unta betina bunting besar dari dalam batu cadas yang keras atas izin Allah.',
        'Air sumur mampu mencukupi minum unta betina tersebut bergantian dengan seluruh penduduk desa.',
      ],
      story:
          'Nabi Shaleh AS diutus kepada kaum Tsamud yang terampil memahat batu-batu gunung menjadi rumah dan istana yang kokoh. Seperti kaum sebelumnya, mereka berbuat syirik dan menentang dakwah tauhid. Mereka menantang Nabi Shaleh untuk membuktikan kenabiannya dengan memunculkan unta betina hidup dari sebuah batu besar.\n\n'
          'Dengan izin Allah, mukjizat tersebut terwujud. Nabi Shaleh berpesan agar tidak mengganggu unta tersebut dan membagi jadwal minum air sumur: sehari untuk unta, sehari untuk penduduk. Namun sekelompok penjahat kaum Tsamud bersekongkol membunuh unta mukjizat tersebut. Nabi Shaleh memberi peringatan bahwa azab akan datang dalam 3 hari. Pada hari ketiga, suara gelegar petir dahsyat dan gempa bumi membinasakan mereka dalam rumah masing-masing.',
      moralLessons: [
        'Tidak mengingkari tanda-tanda kebesaran Allah setelah melihat bukti kebenaran.',
        'Bahaya bersekongkol dalam kejahatan karena dampaknya dapat menimpa seluruh masyarakat.',
        'Menjaga amanah dan tidak merusak alam serta makhluk hidup.',
      ],
    ),
    ProphetModel(
      id: 6,
      name: 'Nabi Ibrahim AS',
      arabicName: 'إِبْرَاهِيمُ عَلَيْهِ السَّلَامُ',
      era: 'Zaman Raja Namrud',
      place: 'Babilonia (Irak), Syam, Mesir, Hijaz (Makkah)',
      isUlulAzmi: true,
      miracles: [
        'Tubuh beliau tidak terbakar saat dilemparkan ke dalam api unggun raksasa oleh Raja Namrud.',
        'Mampu menghidupkan kembali 4 ekor burung yang telah dicincang atas izin Allah.',
        'Membangun Ka\'bah Baitullah bersama putranya Ismail di lembah Makkah.',
        'Mata air Zamzam yang memancar hingga akhir zaman.',
      ],
      story:
          'Nabi Ibrahim AS bergelar Khalilullah (Kekasih Allah) dan bapak para nabi (Abul Anbiya\'). Beliau gigih mencari kebenaran tauhid dengan merenungkan matahari, bulan, dan bintang, hingga meyakini hanya Allah pencipta alam semesta yang wajib disembah.\n\n'
          'Beliau menghancurkan berhala-berhala kaumnya dan mendebat Raja Namrud yang lalim. Namrud menghukumnya dengan membakar Ibrahim dalam kobaran api raksasa, namun Allah berfirman: "Wahai api! Jadilah dingin dan penyelamat bagi Ibrahim". Beliau diuji dengan perintah menyembelih putranya Ismail yang dipatuhi keduanya dengan ikhlas, hingga Allah menggantinya dengan sembelihan domba besar (asal mula Idul Adha). Beliau juga membangun Ka\'bah sebagai kiblat umat Islam.',
      moralLessons: [
        'Ketauhidan yang murni, logis, dan teguh tanpa kompromi terhadap kesyirikan.',
        'Totalitas kepasrahan dan pengorbanan kepada perintah Allah.',
        'Doa seorang bapak untuk kesalehan anak cucu dan kemakmuran negerinya.',
      ],
    ),
    ProphetModel(
      id: 7,
      name: 'Nabi Luth AS',
      arabicName: 'لُوطٌ عَلَيْهِ السَّلَامُ',
      era: 'Semasa dengan Nabi Ibrahim AS (Keponakan)',
      place: 'Sodom & Gomorrah (Laut Mati, Yordania)',
      isUlulAzmi: false,
      miracles: [
        'Diselamatkan dari kepungan kaum Sodom yang hendak berbuat fasik kepada tamu-tamu malaikat.',
        'Perlindungan Allah saat kota Sodom dijungkirbalikkan dan dihujani batu belerang.',
      ],
      story:
          'Nabi Luth AS adalah keponakan Nabi Ibrahim yang diutus ke negeri Sodom. Kaum Sodom terkenal dengan perbuatan keji yang belum pernah dilakukan umat mana pun sebelumnya: homoseksualitas, perampokan di jalan, dan kemaksiatan terbuka di majelis-majelis mereka.\n\n'
          'Nabi Luth berdakwah tanpa henti mengajak mereka bertakwa dan menikah secara fitrah. Namun kaumnya justru mengancam mengusirnya. Allah kemudian mengutus malaikat berwujud pemuda tampan untuk menguji kaum tersebut dan mengabarkan azab. Istri Nabi Luth sendiri termasuk orang yang membela kejahatan kaumnya. Pada waktu fajar, Allah menjungkirbalikkan kota Sodom dan menghujani mereka dengan batu tanah yang terbakar.',
      moralLessons: [
        'Menjaga fitrah kemanusiaan, moralitas, dan kesucian keluarga.',
        'Menjauhi perbuatan maksiat dan tidak bersimpati kepada penyimpangan moral.',
        'Kesalehan pribadi tidak otomatis diwarisi oleh pasangan yang menolak hidayah.',
      ],
    ),
    ProphetModel(
      id: 8,
      name: 'Nabi Ismail AS',
      arabicName: 'إِسْمَاعِيلُ عَلَيْهِ السَّلَامُ',
      era: 'Putra Sulung Nabi Ibrahim AS',
      place: 'Makkah Al-Mukarramah',
      isUlulAzmi: false,
      miracles: [
        'Hentakan kakinya saat bayi memancarkan mata air suci Zamzam di padang pasir tandus.',
        'Selamat dari penyembelihan dan digantikan oleh Allah dengan seekor kibas besar.',
        'Bersama sang ayah meletakkan pondasi Ka\'bah Baitullah.',
      ],
      story:
          'Nabi Ismail AS adalah putra Nabi Ibrahim bersama Siti Hajar. Sejak bayi, beliau ditinggalkan di lembah Makkah yang gersang atas perintah Allah. Saat Siti Hajar berlari antara bukit Shafa dan Marwah mencari air, Allah memancarkan air Zamzam dari bawah kaki mungil Ismail.\n\n'
          'Ketika beranjak remaja, ayahnya bermimpi diperintahkan Allah untuk menyembelihnya. Dengan penuh keikhlasan dan ketenangan Ismail berkata: "Wahai ayahku, kerjakanlah apa yang diperintahkan kepadamu, insya Allah engkau akan mendapatiku termasuk orang-orang yang sabar." Ketaatan ini menjadi tonggak syariat qurban. Dari keturunan Ismail inilah kelak lahir Nabi Muhammad SAW.',
      moralLessons: [
        'Bakti yang sempurna seorang anak kepada orang tua dan ketaatan kepada Allah.',
        'Keikhlasan menerima ketetapan takdir Ilahi.',
        'Tawakkal dan usaha maksimal (seperti sa\'i ibunda Siti Hajar).',
      ],
    ),
    ProphetModel(
      id: 9,
      name: 'Nabi Ishaq AS',
      arabicName: 'إِسْحَاقُ عَلَيْهِ السَّلَامُ',
      era: 'Putra Kedua Nabi Ibrahim AS',
      place: 'Kanaan (Palestina)',
      isUlulAzmi: false,
      miracles: [
        'Kelahirannya dikabarkan oleh para malaikat kepada ibunya (Siti Sarah) yang telah berusia lanjut dan mandul.',
        'Dikaruniai keturunan para nabi dan rasul Bani Israil.',
      ],
      story:
          'Nabi Ishaq AS adalah putra kedua Nabi Ibrahim yang lahir dari rahim Siti Sarah. Ketika para malaikat hendak menuju Sodom untuk menghukum kaum Nabi Luth, mereka terlebih dahulu singgah bertamu ke rumah Nabi Ibrahim untuk menyampaikan kabar gembira tentang kelahiran seorang anak laki-laki yang berilmu (Ishaq) dan cucunya kelak (Ya\'qub).\n\n'
          'Nabi Ishaq meneruskan estafet dakwah tauhid sang ayah di tanah Kanaan (Palestina). Beliau dikenal sebagai nabi yang saleh, penyabar, adil, dan berakhlak mulia. Dari garis keturunan Nabi Ishaq inilah lahir banyak nabi-nabi Bani Israil.',
      moralLessons: [
        'Kekuasaan Allah tidak dibatasi oleh hukum biologis manusia (Sarah melahirkan di usia senja).',
        'Pentingnya menjaga keharmonisan dan pendidikan agama dalam keluarga besar.',
        'Kesejukan akhlak dan kebijaksanaan dalam memimpin masyarakat.',
      ],
    ),
    ProphetModel(
      id: 10,
      name: 'Nabi Ya\'qub AS',
      arabicName: 'يَعْقُوبُ عَلَيْهِ السَّلَامُ',
      era: 'Putra Nabi Ishaq AS (Bergelar Israil)',
      place: 'Kanaan (Palestina) & Harran',
      isUlulAzmi: false,
      miracles: [
        'Kemampuan membaca firasat dan kesabaran luar biasa saat diuji perpisahan dengan Yusuf selama puluhan tahun.',
        'Matanya yang buta akibat kesedihan sembuh kembali seketika setelah diusapkan baju gamis putranya Yusuf.',
      ],
      story:
          'Nabi Ya\'qub AS bergelar "Israil" (Hamba Allah yang setia). Beliau memiliki 12 putra yang menjadi cikal bakal dari 12 suku Bani Israil. Putra kesayangannya adalah Yusuf dan Bunyamin yang memiliki akhlak terpuji.\n\n'
          'Kecemburuan saudara-saudaranya membuat mereka membuang Yusuf ke dalam sumur dan berbohong kepada sang ayah bahwa Yusuf diterkam serigala. Meskipun dirundung kesedihan yang amat mendalam hingga matanya memutih (buta), Nabi Ya\'qub menunjukkan sikap sabar yang indah (Shabrun Jamil) dan tidak pernah berputus asa dari rahmat Allah, hingga akhirnya mereka dipertemukan kembali di Mesir.',
      moralLessons: [
        'Konsep kesabaran paripurna (Shabrun Jamil) di tengah ujian berat.',
        'Tidak berputus asa dari rahmat Allah meskipun situasi tampak mustahil.',
        'Keadilan dan kasih sayang orang tua dalam mendidik anak-anak.',
      ],
    ),
    ProphetModel(
      id: 11,
      name: 'Nabi Yusuf AS',
      arabicName: 'يُوسُفُ عَلَيْهِ السَّلَامُ',
      era: 'Putra Nabi Ya\'qub AS',
      place: 'Kanaan (Palestina) & Mesir',
      isUlulAzmi: false,
      miracles: [
        'Dianugerahi ketampanan luar biasa (separuh ketampanan manusia di bumi).',
        'Mukjizat menafsirkan mimpi secara tepat dan akurat.',
        'Mengangkat Mesir dari krisis kelaparan hebat selama 7 tahun berkat kepemimpinan yang amanah.',
      ],
      story:
          'Kisah Nabi Yusuf AS disebut dalam Al-Qur\'an sebagai "Ahsanul Qashash" (Kisah Terbaik). Dibuang ke sumur oleh saudara-saudaranya, ditemukan kafilah dagang, dijual sebagai budak di Mesir, difitnah oleh istri majikannya (Zulaikha), hingga dipenjara tanpa rasa bersalah.\n\n'
          'Di penjara, beliau menafsirkan mimpi dua tahanan dan kelak menafsirkan mimpi Raja Mesir tentang 7 sapi gemuk yang dimakan 7 sapi kurus. Berkat kejujuran, ketakwaan, dan kecerdasannya mengelola lumbung pangan negara, beliau diangkat menjadi menteri perbendaharaan Mesir. Ketika saudara-saudaranya datang meminta gandum, Nabi Yusuf memaafkan mereka tanpa dendam sedikit pun.',
      moralLessons: [
        'Integritas menjaga kesucian diri di hadapan godaan hawa nafsu dan syahwat.',
        'Ketabahan menjalani roda kehidupan: dari sumur budak hingga singgasana menteri.',
        'Memaafkan dengan lapang dada (tasamuh) terhadap orang yang pernah mendzalimi kita.',
      ],
    ),
    ProphetModel(
      id: 12,
      name: 'Nabi Ayyub AS',
      arabicName: 'أَيُّوبُ عَلَيْهِ السَّلَامُ',
      era: 'Zaman Keturunan Nabi Ishaq AS',
      place: 'Hauran (Dataran Syam/Suriah Selatan)',
      isUlulAzmi: false,
      miracles: [
        'Memukulkan kakinya ke bumi atas perintah Allah, memancar air sejuk yang menyembuhkan seluruh penyakit kulitnya seketika.',
        'Dianugerahi kembali harta kekayaan dan anak-anak yang berlipat ganda setelah ujian kesabaran.',
      ],
      story:
          'Nabi Ayyub AS adalah lambang kesabaran tertinggi bagi manusia saat tertimpa ujian fisik dan kehilangan duniawi. Awalnya beliau adalah orang kaya raya yang memiliki tanah luas, ternak melimpah, dan keluarga yang bahagia.\n\n'
          'Allah mengujinya secara beruntun: seluruh ternaknya mati, rumahnya roboh menewaskan anak-anaknya, dan beliau terserang penyakit kulit yang parah selama bertahun-tahun hingga dijauhi masyarakat, kecuali istrinya yang setia (Rahmah). Selama sakit, lisan beliau tak pernah berhenti berdzikir dan bersyukur. Doa beliau yang santun diabadikan dalam QS. Al-Anbiya: 83. Allah mengabulkannya dan mengembalikan kesehatannya serta melipatgandakan rezekinya.',
      moralLessons: [
        'Sabar yang sejati tidak mengeluh dan tidak berprasangka buruk kepada Allah.',
        'Kekayaan dan kesehatan adalah titipan, sedangkan keimanan adalah inti kehidupan.',
        'Kesetiaan pasangan hidup dalam suka maupun duka.',
      ],
    ),
    ProphetModel(
      id: 13,
      name: 'Nabi Syu\'aib AS',
      arabicName: 'شُعَيْبٌ عَلَيْهِ السَّلَامُ',
      era: 'Masa Antara Nabi Luth dan Nabi Musa',
      place: 'Madyan & Aikah (Yordania/Barat Laut Arab)',
      isUlulAzmi: false,
      miracles: [
        'Dikaruniai kefasihan lisan luar biasa dalam berhujjah hingga bergelar "Khatibul Anbiya" (Juru Bicara Para Nabi).',
        'Selamat dari gempa dahsyat dan awan hitam yang membinasakan kaum Madyan.',
      ],
      story:
          'Nabi Syu\'aib AS diutus kepada penduduk Madyan dan Ashabul Aikah yang gemar mencurangi timbangan dan takaran, merampas hak orang lain di jalan perniagaan, serta menyembah pohon rindang (Aikah).\n\n'
          'Nabi Syu\'aib menyeru mereka untuk berbuat adil dalam jual beli, tidak mengurangi takaran, dan bertauhid kepada Allah. Namun kaumnya menertawakan seruan tersebut dan mengancam akan merajamnya. Allah kemudian mendatangkan hawa panas yang membakar selama 7 hari, lalu gumpalan awan hitam (Yaumazh-Zhulal) yang mereka kira memberi naungan, namun menjatuhkan percikan api dan petir yang menghancurkan mereka dalam sekejap.',
      moralLessons: [
        'Pentingnya kejujuran, etika bisnis, dan keadilan dalam perekonomian.',
        'Mengurangi hak orang lain adalah dosa besar yang mendatangkan kehancuran.',
        'Penyampaian dakwah dengan tutur kata yang santun, logis, dan persuasif.',
      ],
    ),
    ProphetModel(
      id: 14,
      name: 'Nabi Musa AS',
      arabicName: 'مُوسَىٰ عَلَيْهِ السَّلَامُ',
      era: 'Zaman Fir\'aun Ramses II',
      place: 'Mesir, Bukit Tursina (Sinai), & Padang Tiih',
      isUlulAzmi: true,
      miracles: [
        'Tongkat kayu yang berubah menjadi ular besar dan menelan ular-ular buatan penyihir Fir\'aun.',
        'Tongkat yang membelah Laut Merah menjadi 12 jalur kering untuk menyelamatkan Bani Israil.',
        'Tangan yang dimasukkan ke ketiak memancarkan cahaya putih menyilaukan tanpa cacat.',
        'Menurunkan kitab suci Taurat di Bukit Sinai.',
        'Berbicara langsung dengan Allah SWT di Lembah Thuwa (bergelar Kalimullah).',
      ],
      story:
          'Nabi Musa AS adalah nabi yang paling sering dikisahkan dalam Al-Qur\'an. Lahir di era Fir\'aun yang membantai setiap bayi laki-laki Bani Israil, Musa dihanyutkan ibunya ke Sungai Nil dan justru dirawat di istana Fir\'aun oleh Asiyah.\n\n'
          'Setelah beranjak dewasa dan menerima wahyu di Bukit Tursina, Musa dan saudaranya Harun diperintahkan mendatangi Fir\'aun dengan kata-kata lembut untuk membebaskan Bani Israil. Fir\'aun menantangnya dengan ahli sihir, namun sihir mereka kalah oleh tongkat Musa. Puncaknya, Fir\'aun dan pasukannya mengejar Musa hingga Laut Merah. Musa memukulkan tongkatnya, laut terbelah, Bani Israil menyeberang selamat, sementara Fir\'aun dan tentaranya tenggelam binasa.',
      moralLessons: [
        'Keberanian menghadapi penguasa tiran demi membela keadilan dan tauhid.',
        'Skenario Allah selalu melampaui perhitungan manusia (Musa dibesarkan di istana musuhnya).',
        'Tawakkal mutlak di saat jalan keluar di depan mata tampak tertutup.',
      ],
    ),
    ProphetModel(
      id: 15,
      name: 'Nabi Harun AS',
      arabicName: 'هَارُونُ عَلَيْهِ السَّلَامُ',
      era: 'Kakak Kandung Nabi Musa AS',
      place: 'Mesir & Padang Sinai',
      isUlulAzmi: false,
      miracles: [
        'Diangkat menjadi nabi atas doa tulus Nabi Musa AS.',
        'Dianugerahi kefasihan lisan yang memukau dalam berkhutbah dan mendampingi diplomasi Musa dihadapan Fir\'aun.',
      ],
      story:
          'Nabi Harun AS adalah kakak dari Nabi Musa AS. Ketika Musa menerima perintah berdakwah kepada Fir\'aun, Musa memohon kepada Allah agar saudaranya Harun diangkat menjadi nabi pendamping karena lisannya yang lebih fasih dan kepribadiannya yang tenang.\n\n'
          'Harun menjadi rekan setia Musa dalam berhadapan dengan Fir\'aun. Saat Musa pergi bermunajat di Bukit Sinai selama 40 hari, Harun ditugaskan memimpin Bani Israil. Ketika kaumnya tergoda oleh Samiri untuk menyembah patung anak sapi emas, Harun berusaha keras menasihati mereka dengan penuh kesabaran agar tidak berpecah belah sebelum Musa kembali.',
      moralLessons: [
        'Pentingnya kerja sama tim dan saling mendukung dalam kebaikan dan dakwah.',
        'Kematangan emosional dan pendekatan lemah lembut dalam menyelesaikan konflik umat.',
        'Tulus mendoakan saudara sendiri agar meraih kesuksesan bersama.',
      ],
    ),
    ProphetModel(
      id: 16,
      name: 'Nabi Zulkifli AS',
      arabicName: 'ذُو الْكِفْلِ عَلَيْهِ السَّلَامُ',
      era: 'Keturunan Nabi Ayyub AS (Disebut Basyar)',
      place: 'Damaskus (Suriah) & Irak',
      isUlulAzmi: false,
      miracles: [
        'Keteguhan luar biasa memenuhi 3 syarat kepemimpinan: berpuasa di siang hari, shalat di malam hari, dan tidak pernah marah dalam mengadili perkara.',
      ],
      story:
          'Nabi Zulkifli AS (bernama asli Basyar) bergelar "Dzul Kifli" yang bermakna orang yang sanggup memenuhi kesanggupannya. Suatu ketika, seorang raja tua yang saleh hendak mencari penerus tahta dengan syarat: calon pengganti harus sanggup berpuasa di siang hari, beribadah di malam hari, dan tidak pernah melampiaskan amarah.\n\n'
          'Zulkifli menyanggupinya dan terpilih menjadi raja. Beliau menjalankan amanah tersebut dengan sempurna. Suatu hari iblis menyamar sebagai orang tua untuk mengujinya dengan memotong waktu istirahatnya dan mengajukan sengketa palsu berkali-kali. Namun Nabi Zulkifli tetap menyambutnya dengan senyum, sabar, dan adil tanpa menunjukkan amarah sedikit pun.',
      moralLessons: [
        'Konsistensi dan integritas memegang teguh janji serta amanah kepemimpinan.',
        'Kemampuan mengendalikan amarah saat menghadapi provokasi.',
        'Keseimbangan antara ibadah spiritual dan pelayanan sosial kepada sesama.',
      ],
    ),
    ProphetModel(
      id: 17,
      name: 'Nabi Daud AS',
      arabicName: 'دَاوُدُ عَلَيْهِ السَّلَامُ',
      era: 'Masa Raja Thalut & Jalut',
      place: 'Palestina (Baitul Maqdis)',
      isUlulAzmi: false,
      miracles: [
        'Dianugerahi kitab Zabur dengan suara yang sangat merdu; burung dan gunung ikut bertasbih bersamanya.',
        'Mampu melunakkan besi baja dengan tangan kosong seperti adonan lilin dan membuat baju zirah besi.',
        'Mengalahkan raksasa Jalut (Goliath) hanya dengan sebutir batu ketapel.',
      ],
      story:
          'Nabi Daud AS awalnya adalah seorang prajurit muda dalam pasukan Raja Thalut. Dengan keberanian dan izin Allah, Daud berhasil merobohkan pemimpin tiran Jalut hanya dengan ketapelnya. Kelak beliau diangkat menjadi raja Bani Israil sekaligus nabi.\n\n'
          'Kerajaan Nabi Daud sangat adil dan makmur. Beliau menerapkan puasa Daud (sehari puasa, sehari tidak), puasa yang paling dicintai Allah. Meskipun seorang raja agung, beliau tidak mau memakan harta negara dan memilih makan dari hasil keringat tangannya sendiri dengan membuat baju zirah pelindung perang.',
      moralLessons: [
        'Kemuliaan seseorang yang hidup mandiri dari hasil usaha keringatnya sendiri.',
        'Ibadah terbaik adalah yang konsisten dan seimbang (puasa dan shalat Daud).',
        'Kekuasaan duniawi hendaknya tunduk untuk menegakkan keadilan dan tasbih kepada Allah.',
      ],
    ),
    ProphetModel(
      id: 18,
      name: 'Nabi Sulaiman AS',
      arabicName: 'سُلَيْمَانُ عَلَيْهِ السَّلَامُ',
      era: 'Putra Nabi Daud AS',
      place: 'Palestina (Yerusalem)',
      isUlulAzmi: false,
      miracles: [
        'Memahami bahasa binatang (semut, burung hud-hud, dan lainnya).',
        'Mampu menundukkan angin kencang sebagai kendaraan perjalanan cepat.',
        'Dianugerahi tentara gabungan dari bangsa manusia, jin, dan burung.',
        'Memerintah bangsa jin untuk membangun istana megah dan menyelam ke dasar lautan.',
      ],
      story:
          'Nabi Sulaiman AS mewarisi kebijaksanaan ayahnya Nabi Daud. Beliau dikaruniai kerajaan termegah yang tidak pernah dan tidak akan pernah dimiliki manusia setelahnya. Pasukannya terdiri atas bala tentara manusia, jin, dan burung.\n\n'
          'Suatu hari burung Hud-hud mengabarkan adanya kerajaan Saba\' di Yaman yang dipimpin Ratu Balqis yang menyembah matahari. Nabi Sulaiman mengirim surat dakwah bertuliskan "Bismillāhir-Rahmānir-Rahīm" mengajaknya beriman. Dengan memindahkan singgasana Balqis dalam sekejap mata melalui bantuan orang berilmu, Ratu Balqis takjub dan berserah diri kepada Allah bersama Sulaiman. Walau bergelimang kemegahan, Sulaiman selalu bersyukur dan rendah hati.',
      moralLessons: [
        'Kekayaan dan kekuasaan tertinggi tidak melalaikan hati dari sikap tawadhu dan bersyukur.',
        'Menghargai makhluk ciptaan Allah yang paling kecil sekalipun (kisah lembah semut).',
        'Memanfaatkan sains, teknologi, dan kecerdasan diplomasi untuk menyebarkan nilai tauhid.',
      ],
    ),
    ProphetModel(
      id: 19,
      name: 'Nabi Ilyas AS',
      arabicName: 'إِلْيَاسُ عَلَيْهِ السَّلَامُ',
      era: 'Zaman Keturunan Nabi Harun AS',
      place: 'Baalbek (Lebanon)',
      isUlulAzmi: false,
      miracles: [
        'Doanya dikabulkan Allah untuk menghentikan hujan selama 3 tahun hingga kaumnya sadar atas kesyirikan mereka.',
        'Menghidupkan kembali anak seorang janda miskin yang kelak menjadi Nabi Ilyasa atas izin Allah.',
      ],
      story:
          'Nabi Ilyas AS diutus kepada penduduk negeri Baalbek (wilayah Lebanon dan Suriah) yang dipimpin oleh raja yang lalim. Mereka menyembah patung berhala besar bernama "Ba\'al" yang terbuat dari emas murni.\n\n'
          'Nabi Ilyas menegur mereka: "Mengapa kamu menyembah Ba\'al dan meninggalkan sebaik-baik pencipta, yaitu Allah Tuhanmu dan Tuhan nenek moyangmu?" (QS. Ash-Shaffat: 125-126). Kaumnya mendustakannya hingga Allah mendatangkan kemarau panjang yang mengeringkan sumber air. Setelah mereka memohon ampun, Nabi Ilyas berdoa agar hujan turun, namun setelah hujan kembali menyuburkan tanah, sebagian dari mereka kembali ingkar.',
      moralLessons: [
        'Keteguhan memberantas takhayul dan penyembahan selain Allah.',
        'Manusia seringkali baru mengingat Allah saat tertimpa bencana dan lupa saat senang.',
        'Kekuatan doa orang-orang yang ikhlas di sisi Allah.',
      ],
    ),
    ProphetModel(
      id: 20,
      name: 'Nabi Ilyasa AS',
      arabicName: 'الْيَسَعُ عَلَيْهِ السَّلَامُ',
      era: 'Murid dan Penerus Nabi Ilyas AS',
      place: 'Palestina & Suriah',
      isUlulAzmi: false,
      miracles: [
        'Mampu menyembuhkan orang sakit kusta dan buta atas izin Allah.',
        'Mampu menghidupkan orang yang telah meninggal atas kuasa Allah SWT.',
      ],
      story:
          'Nabi Ilyasa AS adalah anak angkat sekaligus murid setia yang selalu mendampingi Nabi Ilyas AS dalam berdakwah. Ketika Nabi Ilyas wafat, Allah mengangkat Ilyasa menjadi nabi untuk melanjutkan dakwah membimbing Bani Israil.\n\n'
          'Nabi Ilyasa memimpin umatnya dengan penuh kesabaran, keadilan, dan ketegasan syariat. Selama masa kepemimpinannya, Bani Israil hidup dalam kedamaian dan ketenteraman karena mereka patuh kepada ajaran tauhid. Al-Qur\'an memujinya dalam QS. Shaad: 48 sebagai salah satu hamba pilihan yang terbaik.',
      moralLessons: [
        'Pentingnya kesinambungan kaderisasi dakwah dan kepemimpinan umat.',
        'Kesetiaan seorang murid meneladani akhlak mulia gurunya.',
        'Kedamaian masyarakat tercipta saat syariat Allah ditegakkan dengan adil.',
      ],
    ),
    ProphetModel(
      id: 21,
      name: 'Nabi Yunus AS',
      arabicName: 'يُونُسُ عَلَيْهِ السَّلَامُ',
      era: 'Abad ke-8 SM',
      place: 'Ninawa (Mosul, Irak)',
      isUlulAzmi: false,
      miracles: [
        'Bertahan hidup di dalam tiga kegelapan: kegelapan malam, kegelapan dasar lautan, dan kegelapan perut ikan paus (Nun).',
        'Tumbuhnya pohon sejenis labu (Yaqthin) yang menaungi tubuhnya yang lemas di tepi pantai.',
        'Seluruh penduduk kota Ninawa (100.000 lebih) akhirnya beriman kepada Allah.',
      ],
      story:
          'Nabi Yunus AS (Dzun-Nun) diutus kepada 100.000 penduduk Ninawa. Karena mereka keras kepala, Yunus merasa kecewa dan pergi meninggalkan kotanya sebelum ada izin dari Allah. Beliau menaiki kapal laut, namun di tengah badai kapal kelebihan muatan. Diadakan undian siapa yang harus dilempar ke laut, dan nama Yunus keluar 3 kali berturut-turut.\n\n'
          'Saat melompat ke laut, beliau ditelan oleh ikan paus besar tanpa terluka. Di dalam perut ikan, beliau menyadari kekhilafannya dan memanjatkan doa agung: "Lā ilāha illā Anta, subhānaka innī kuntu minazh-zhālimīn". Allah menyelamatkannya dan mendamparkannya ke pantai. Saat kembali ke Ninawa, beliau mendapati seluruh penduduknya telah bertaubat dan beriman.',
      moralLessons: [
        'Tidak boleh berputus asa atau tergesa-gesa meninggalkan tugas sebelum ada perintah Allah.',
        'Dahsyatnya kekuatan doa taubat Nabi Yunus untuk melapangkan segala kesulitan hidup.',
        'Pintu taubat selalu terbuka bagi siapa saja yang bersungguh-sungguh kembali kepada Allah.',
      ],
    ),
    ProphetModel(
      id: 22,
      name: 'Nabi Zakaria AS',
      arabicName: 'زَكَرِيَّا عَلَيْهِ السَّلَامُ',
      era: 'Abad ke-1 SM',
      place: 'Baitul Maqdis (Palestina)',
      isUlulAzmi: false,
      miracles: [
        'Doanya dikabulkan Allah dianugerahi putra (Yahya) saat rambutnya telah beruban putih dan istrinya mandul.',
        'Tanda mukjizat tidak dapat berbicara selama 3 hari 3 malam selain dengan bahasa isyarat.',
      ],
      story:
          'Nabi Zakaria AS adalah ulama besar Bani Israil yang mengasuh Maryam binti Imran di mihrab Baitul Maqdis. Setiap kali masuk ke mihrab Maryam, beliau menjumpai rezeki buah-buahan musim dingin di musim panas, dan buah musim panas di musim dingin. Menyaksikan keajaiban itu, tumbuh keyakinan kuat di hati Zakaria untuk memohon keturunan.\n\n'
          'Di usianya yang telah sangat senja dan istrinya yang divonis mandul, beliau bermunajat dengan suara yang lembut memohon seorang pewaris dakwah yang diridhai Allah (QS. Maryam: 2-6). Malaikat Jibril datang mengabarkan bahwa Allah akan menganugerahkannya putra bernama Yahya, nama yang belum pernah diberikan kepada siapa pun sebelumnya.',
      moralLessons: [
        'Berprasangka baik dan tidak pernah meragukan kekuasaan Allah dalam berdoa.',
        'Memohon anak bukan demi kebanggaan duniawi, melainkan untuk meneruskan risalah agama.',
        'Tanggung jawab mendidik dan menjaga generasi penerus dengan penuh kasih sayang.',
      ],
    ),
    ProphetModel(
      id: 23,
      name: 'Nabi Yahya AS',
      arabicName: 'يَحْيَىٰ عَلَيْهِ السَّلَامُ',
      era: 'Putra Nabi Zakaria AS',
      place: 'Palestina & Yordania',
      isUlulAzmi: false,
      miracles: [
        'Dianugerahi hikmah, kecerdasan syariat, dan kelembutan hati sejak masih kanak-kanak.',
        'Sangat disayangi oleh makhluk hidup, hewan liar di padang pasir tidak menyakitinya.',
      ],
      story:
          'Nabi Yahya AS adalah putra Nabi Zakaria AS. Sejak kecil, beliau telah hafal kitab Taurat dan senang beribadah. Ketika anak-anak seusianya mengajaknya bermain, beliau menjawab: "Kita diciptakan bukan untuk sekadar bermain-main." Beliau hidup zuhud, makan dari dedaunan pohon, dan menangis karena takut kepada Allah.\n\n'
          'Nabi Yahya berani menegakkan amar ma\'ruf nahi munkar. Beliau menentang keras pernikahan haram Raja Herodes yang hendak mengawini putri tirinya (Herodias). Karena keberaniannya membela syariat Allah, beliau ditangkap dan wafat sebagai syahid memperjuangkan kebenaran.',
      moralLessons: [
        'Fokus mengisi masa muda dengan ilmu, ibadah, dan karya yang bermanfaat.',
        'Keteguhan prinsip syariat yang tidak goyah oleh rayuan penguasa.',
        'Sikap zuhud, rendah hati, dan berbakti kepada kedua orang tua.',
      ],
    ),
    ProphetModel(
      id: 24,
      name: 'Nabi Isa AS',
      arabicName: 'عِيسَىٰ عَلَيْهِ السَّلَامُ',
      era: 'Awal Tarikh Masehi',
      place: 'Nazaret & Baitul Maqdis (Palestina)',
      isUlulAzmi: true,
      miracles: [
        'Dilahirkan dari rahim perawan suci Maryam tanpa sentuhan laki-laki (perantara ayah).',
        'Mampu berbicara membela kesucian ibunya sejak masih bayi di dalam ayunan.',
        'Membuat burung dari tanah liat lalu ditiup menjadi hidup atas izin Allah.',
        'Menyembuhkan orang buta sejak lahir dan orang berpenyakit kusta.',
        'Menghidupkan orang mati atas izin Allah SWT.',
        'Menurunkan hidangan makanan dari langit (Al-Ma\'idah) untuk para pengikutnya (Hawariyyun).',
        'Menerima kitab suci Injil dan diangkat ke langit dalam keadaan hidup.',
      ],
      story:
          'Nabi Isa Al-Masih AS adalah rasul Ulul Azmi yang dilahirkan dari Siti Maryam atas kalimat Allah melalui perantara Malaikat Jibril. Sejak bayi, beliau membela ibunya dari tuduhan keji kaumnya dengan berkata: "Sesungguhnya aku hamba Allah, Dia memberiku Kitab (Injil) dan Dia menjadikanku seorang nabi."\n\n'
          'Beliau berdakwah mengajak Bani Israil kembali kepada kemurnian tauhid dan membenarkan Taurat sebelumnya. Kaum munafik berkomplot dengan penguasa Romawi untuk membunuhnya. Namun Allah menyelamatkannya dan mengangkatnya ke langit, serta menyerupakan wajah orang yang mengkhianatinya (Yudas Iskariot) yang akhirnya disalib. Di akhir zaman, Nabi Isa akan turun kembali ke bumi untuk menegakkan syariat Islam dan mengalahkan Dajjal.',
      moralLessons: [
        'Tauhid murni bahwa Isa AS adalah hamba dan utusan Allah, bukan anak Tuhan.',
        'Mukjizat materi hanyalah sarana, sedangkan hidayah mutlak dari Allah.',
        'Kekuatan tawakkal Maryam dan Isa dalam menghadapi fitnah kejam masyarakat.',
      ],
    ),
    ProphetModel(
      id: 25,
      name: 'Nabi Muhammad SAW',
      arabicName: 'مُحَمَّدٌ رَسُولُ اللَّهِ ﷺ',
      era: '571 M - 632 M (Penutup Seluruh Nabi)',
      place: 'Makkah Al-Mukarramah & Madinah Al-Munawwarah',
      isUlulAzmi: true,
      miracles: [
        'Al-Qur\'an Al-Karim, mukjizat abadi sepanjang zaman yang terjaga keasliannya.',
        'Peristiwa Isra\' Mi\'raj: perjalanan malam dari Masjidil Haram ke Masjidil Aqsha hingga Sidratul Muntaha menerima perintah shalat 5 waktu.',
        'Membelah bulan menjadi dua bagian di hadapan kaum kafir Quraisy.',
        'Air memancar dari sela-sela jari beliau hingga mampu mencukupi wudhu dan minum 1.500 pasukan.',
        'Makanan yang sedikit mampu mengenyangkan ratusan sahabat (Perang Khandaq).',
        'Batang pohon kurma menangis karena rindu kepada beliau saat mimbar baru dibuat.',
      ],
      story:
          'Nabi Muhammad SAW adalah Khatamun Nabiyyin (penutup seluruh nabi dan rasul) yang diutus sebagai rahmat bagi seluruh alam semesta (Rahmatan lil \'Alamin). Lahir sebagai anak yatim di Makkah pada Tahun Gajah, beliau dikenal dengan gelar Al-Amin (orang yang sangat terpercaya).\n\n'
          'Menerima wahyu pertama di Gua Hira pada usia 40 tahun (Surah Al-\'Alaq). Beliau menghadapi penindasan, pemboikotan, dan percobaan pembunuhan selama 13 tahun di Makkah dengan kesabaran luar biasa. Beliau berhijrah ke Madinah dan mendirikan peradaban Islam yang adil, mempersaudarakan kaum Muhajirin dan Anshar, serta menaklukkan Makkah kembali (Fathu Makkah) tanpa pertumpahan darah dengan memaafkan seluruh musuh-musuhnya. Ajaran beliau menyempurnakan seluruh syariat sebelumnya hingga akhir zaman.',
      moralLessons: [
        'Akhlak mulia (Uswatun Hasanah) adalah inti utama dari ajaran Islam.',
        'Rahmat dan kasih sayang kepada seluruh makhluk, termasuk kepada musuh yang memusuhi.',
        'Kegigihan, kejujuran, dan keadilan dalam memimpin keluarga, masyarakat, dan bangsa.',
      ],
    ),
  ];
}
