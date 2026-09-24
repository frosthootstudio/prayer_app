class IndonesianCity {
  final String name;
  final String province;
  final double latitude;
  final double longitude;

  const IndonesianCity({
    required this.name,
    required this.province,
    required this.latitude,
    required this.longitude,
  });
}

class IndonesianCitiesData {
  IndonesianCitiesData._();

  static const List<IndonesianCity> cities = [
    // DKI Jakarta
    IndonesianCity(name: 'Jakarta Pusat', province: 'DKI Jakarta', latitude: -6.1818, longitude: 106.8223),
    IndonesianCity(name: 'Jakarta Selatan', province: 'DKI Jakarta', latitude: -6.2615, longitude: 106.8106),
    IndonesianCity(name: 'Jakarta Barat', province: 'DKI Jakarta', latitude: -6.1683, longitude: 106.7589),
    IndonesianCity(name: 'Jakarta Timur', province: 'DKI Jakarta', latitude: -6.2250, longitude: 106.9004),
    IndonesianCity(name: 'Jakarta Utara', province: 'DKI Jakarta', latitude: -6.1214, longitude: 106.7741),
    IndonesianCity(name: 'Kepulauan Seribu', province: 'DKI Jakarta', latitude: -5.6122, longitude: 106.5615),

    // Jawa Barat
    IndonesianCity(name: 'Kota Bandung', province: 'Jawa Barat', latitude: -6.9175, longitude: 107.6191),
    IndonesianCity(name: 'Kab. Bandung', province: 'Jawa Barat', latitude: -7.0252, longitude: 107.5198),
    IndonesianCity(name: 'Kab. Bandung Barat', province: 'Jawa Barat', latitude: -6.8439, longitude: 107.4939),
    IndonesianCity(name: 'Kota Bekasi', province: 'Jawa Barat', latitude: -6.2383, longitude: 106.9756),
    IndonesianCity(name: 'Kab. Bekasi', province: 'Jawa Barat', latitude: -6.2425, longitude: 107.1472),
    IndonesianCity(name: 'Kota Bogor', province: 'Jawa Barat', latitude: -6.5971, longitude: 106.8060),
    IndonesianCity(name: 'Kab. Bogor', province: 'Jawa Barat', latitude: -6.4800, longitude: 106.8300),
    IndonesianCity(name: 'Kota Depok', province: 'Jawa Barat', latitude: -6.4025, longitude: 106.7942),
    IndonesianCity(name: 'Kota Cimahi', province: 'Jawa Barat', latitude: -6.8723, longitude: 107.5420),
    IndonesianCity(name: 'Kota Cirebon', province: 'Jawa Barat', latitude: -6.7320, longitude: 108.5523),
    IndonesianCity(name: 'Kab. Cirebon', province: 'Jawa Barat', latitude: -6.7645, longitude: 108.4795),
    IndonesianCity(name: 'Kota Sukabumi', province: 'Jawa Barat', latitude: -6.9277, longitude: 106.9300),
    IndonesianCity(name: 'Kab. Sukabumi', province: 'Jawa Barat', latitude: -6.9944, longitude: 106.5511),
    IndonesianCity(name: 'Kota Tasikmalaya', province: 'Jawa Barat', latitude: -7.3274, longitude: 108.2207),
    IndonesianCity(name: 'Kab. Tasikmalaya', province: 'Jawa Barat', latitude: -7.3542, longitude: 108.1105),
    IndonesianCity(name: 'Kota Banjar', province: 'Jawa Barat', latitude: -7.3739, longitude: 108.5342),
    IndonesianCity(name: 'Kab. Ciamis', province: 'Jawa Barat', latitude: -7.3262, longitude: 108.3533),
    IndonesianCity(name: 'Kab. Cianjur', province: 'Jawa Barat', latitude: -6.8222, longitude: 107.1394),
    IndonesianCity(name: 'Kab. Garut', province: 'Jawa Barat', latitude: -7.2278, longitude: 107.9086),
    IndonesianCity(name: 'Kab. Indramayu', province: 'Jawa Barat', latitude: -6.3264, longitude: 108.3200),
    IndonesianCity(name: 'Kab. Karawang', province: 'Jawa Barat', latitude: -6.3073, longitude: 107.3019),
    IndonesianCity(name: 'Kab. Kuningan', province: 'Jawa Barat', latitude: -6.9764, longitude: 108.4831),
    IndonesianCity(name: 'Kab. Majalengka', province: 'Jawa Barat', latitude: -6.8361, longitude: 108.2278),
    IndonesianCity(name: 'Kab. Pangandaran', province: 'Jawa Barat', latitude: -7.7042, longitude: 108.4950),
    IndonesianCity(name: 'Kab. Purwakarta', province: 'Jawa Barat', latitude: -6.5569, longitude: 107.4433),
    IndonesianCity(name: 'Kab. Subang', province: 'Jawa Barat', latitude: -6.5592, longitude: 107.7608),
    IndonesianCity(name: 'Kab. Sumedang', province: 'Jawa Barat', latitude: -6.8586, longitude: 107.9267),

    // Banten
    IndonesianCity(name: 'Kota Tangerang', province: 'Banten', latitude: -6.1783, longitude: 106.6319),
    IndonesianCity(name: 'Kota Tangerang Selatan', province: 'Banten', latitude: -6.2888, longitude: 106.7179),
    IndonesianCity(name: 'Kab. Tangerang', province: 'Banten', latitude: -6.1706, longitude: 106.4678),
    IndonesianCity(name: 'Kota Serang', province: 'Banten', latitude: -6.1104, longitude: 106.1640),
    IndonesianCity(name: 'Kab. Serang', province: 'Banten', latitude: -6.1150, longitude: 106.0150),
    IndonesianCity(name: 'Kota Cilegon', province: 'Banten', latitude: -5.9961, longitude: 106.0161),
    IndonesianCity(name: 'Kab. Lebak', province: 'Banten', latitude: -6.5383, longitude: 106.2514),
    IndonesianCity(name: 'Kab. Pandeglang', province: 'Banten', latitude: -6.3086, longitude: 106.1067),

    // Jawa Tengah
    IndonesianCity(name: 'Kota Semarang', province: 'Jawa Tengah', latitude: -6.9667, longitude: 110.4167),
    IndonesianCity(name: 'Kota Surakarta (Solo)', province: 'Jawa Tengah', latitude: -7.5667, longitude: 110.8167),
    IndonesianCity(name: 'Kota Magelang', province: 'Jawa Tengah', latitude: -7.4706, longitude: 110.2178),
    IndonesianCity(name: 'Kota Pekalongan', province: 'Jawa Tengah', latitude: -6.8886, longitude: 109.6753),
    IndonesianCity(name: 'Kota Salatiga', province: 'Jawa Tengah', latitude: -7.3306, longitude: 110.5083),
    IndonesianCity(name: 'Kota Tegal', province: 'Jawa Tengah', latitude: -6.8694, longitude: 109.1403),
    IndonesianCity(name: 'Kab. Banyumas (Purwokerto)', province: 'Jawa Tengah', latitude: -7.4244, longitude: 109.2300),
    IndonesianCity(name: 'Kab. Batang', province: 'Jawa Tengah', latitude: -6.9078, longitude: 109.7317),
    IndonesianCity(name: 'Kab. Blora', province: 'Jawa Tengah', latitude: -7.0000, longitude: 111.4167),
    IndonesianCity(name: 'Kab. Boyolali', province: 'Jawa Tengah', latitude: -7.5333, longitude: 110.6000),
    IndonesianCity(name: 'Kab. Brebes', province: 'Jawa Tengah', latitude: -6.8667, longitude: 109.0333),
    IndonesianCity(name: 'Kab. Cilacap', province: 'Jawa Tengah', latitude: -7.7167, longitude: 109.0167),
    IndonesianCity(name: 'Kab. Demak', province: 'Jawa Tengah', latitude: -6.8944, longitude: 110.6389),
    IndonesianCity(name: 'Kab. Jepara', province: 'Jawa Tengah', latitude: -6.5944, longitude: 110.6689),
    IndonesianCity(name: 'Kab. Karanganyar', province: 'Jawa Tengah', latitude: -7.5958, longitude: 110.9511),
    IndonesianCity(name: 'Kab. Kebumen', province: 'Jawa Tengah', latitude: -7.6694, longitude: 109.6528),
    IndonesianCity(name: 'Kab. Kendal', province: 'Jawa Tengah', latitude: -6.9200, longitude: 110.2000),
    IndonesianCity(name: 'Kab. Klaten', province: 'Jawa Tengah', latitude: -7.7056, longitude: 110.6044),
    IndonesianCity(name: 'Kab. Kudus', province: 'Jawa Tengah', latitude: -6.8048, longitude: 110.8405),
    IndonesianCity(name: 'Kab. Pati', province: 'Jawa Tengah', latitude: -6.7558, longitude: 111.0378),
    IndonesianCity(name: 'Kab. Pemalang', province: 'Jawa Tengah', latitude: -6.8917, longitude: 109.3806),
    IndonesianCity(name: 'Kab. Purbalingga', province: 'Jawa Tengah', latitude: -7.3892, longitude: 109.3639),
    IndonesianCity(name: 'Kab. Purworejo', province: 'Jawa Tengah', latitude: -7.7167, longitude: 110.0167),
    IndonesianCity(name: 'Kab. Rembang', province: 'Jawa Tengah', latitude: -6.7111, longitude: 111.3417),
    IndonesianCity(name: 'Kab. Sragen', province: 'Jawa Tengah', latitude: -7.4267, longitude: 111.0222),
    IndonesianCity(name: 'Kab. Sukoharjo', province: 'Jawa Tengah', latitude: -7.6833, longitude: 110.8333),
    IndonesianCity(name: 'Kab. Wonogiri', province: 'Jawa Tengah', latitude: -7.8167, longitude: 110.9167),
    IndonesianCity(name: 'Kab. Wonosobo', province: 'Jawa Tengah', latitude: -7.3611, longitude: 109.9000),

    // DI Yogyakarta
    IndonesianCity(name: 'Kota Yogyakarta', province: 'DI Yogyakarta', latitude: -7.7956, longitude: 110.3695),
    IndonesianCity(name: 'Kab. Sleman', province: 'DI Yogyakarta', latitude: -7.7156, longitude: 110.3556),
    IndonesianCity(name: 'Kab. Bantul', province: 'DI Yogyakarta', latitude: -7.8922, longitude: 110.3283),
    IndonesianCity(name: 'Kab. Kulon Progo (Wates)', province: 'DI Yogyakarta', latitude: -7.8572, longitude: 110.1583),
    IndonesianCity(name: 'Kab. Gunungkidul (Wonosari)', province: 'DI Yogyakarta', latitude: -7.9622, longitude: 110.6033),

    // Jawa Timur
    IndonesianCity(name: 'Kota Surabaya', province: 'Jawa Timur', latitude: -7.2575, longitude: 112.7521),
    IndonesianCity(name: 'Kota Malang', province: 'Jawa Timur', latitude: -7.9797, longitude: 112.6304),
    IndonesianCity(name: 'Kab. Malang', province: 'Jawa Timur', latitude: -8.1500, longitude: 112.6000),
    IndonesianCity(name: 'Kota Batu', province: 'Jawa Timur', latitude: -7.8711, longitude: 112.5269),
    IndonesianCity(name: 'Kota Sidoarjo', province: 'Jawa Timur', latitude: -7.4478, longitude: 112.7183),
    IndonesianCity(name: 'Kab. Gresik', province: 'Jawa Timur', latitude: -7.1564, longitude: 112.6556),
    IndonesianCity(name: 'Kota Kediri', province: 'Jawa Timur', latitude: -7.8167, longitude: 112.0167),
    IndonesianCity(name: 'Kab. Kediri', province: 'Jawa Timur', latitude: -7.7833, longitude: 112.1833),
    IndonesianCity(name: 'Kota Blitar', province: 'Jawa Timur', latitude: -8.0983, longitude: 112.1681),
    IndonesianCity(name: 'Kab. Blitar', province: 'Jawa Timur', latitude: -8.1333, longitude: 112.2500),
    IndonesianCity(name: 'Kota Madiun', province: 'Jawa Timur', latitude: -7.6298, longitude: 111.5239),
    IndonesianCity(name: 'Kab. Madiun', province: 'Jawa Timur', latitude: -7.5500, longitude: 111.6500),
    IndonesianCity(name: 'Kota Mojokerto', province: 'Jawa Timur', latitude: -7.4722, longitude: 112.4381),
    IndonesianCity(name: 'Kab. Mojokerto', province: 'Jawa Timur', latitude: -7.5500, longitude: 112.5000),
    IndonesianCity(name: 'Kota Pasuruan', province: 'Jawa Timur', latitude: -7.6453, longitude: 112.9075),
    IndonesianCity(name: 'Kab. Pasuruan', province: 'Jawa Timur', latitude: -7.7167, longitude: 112.8333),
    IndonesianCity(name: 'Kota Probolinggo', province: 'Jawa Timur', latitude: -7.7544, longitude: 113.2158),
    IndonesianCity(name: 'Kab. Probolinggo', province: 'Jawa Timur', latitude: -7.8167, longitude: 113.3333),
    IndonesianCity(name: 'Kab. Banyuwangi', province: 'Jawa Timur', latitude: -8.2192, longitude: 114.3692),
    IndonesianCity(name: 'Kab. Bojonegoro', province: 'Jawa Timur', latitude: -7.1500, longitude: 111.8833),
    IndonesianCity(name: 'Kab. Jember', province: 'Jawa Timur', latitude: -8.1725, longitude: 113.7000),
    IndonesianCity(name: 'Kab. Jombang', province: 'Jawa Timur', latitude: -7.5461, longitude: 112.2331),
    IndonesianCity(name: 'Kab. Lamongan', province: 'Jawa Timur', latitude: -7.1206, longitude: 112.4144),
    IndonesianCity(name: 'Kab. Lumajang', province: 'Jawa Timur', latitude: -8.1333, longitude: 113.2167),
    IndonesianCity(name: 'Kab. Magetan', province: 'Jawa Timur', latitude: -7.6539, longitude: 111.3281),
    IndonesianCity(name: 'Kab. Nganjuk', province: 'Jawa Timur', latitude: -7.6047, longitude: 111.9039),
    IndonesianCity(name: 'Kab. Ngawi', province: 'Jawa Timur', latitude: -7.4042, longitude: 111.4456),
    IndonesianCity(name: 'Kab. Pacitan', province: 'Jawa Timur', latitude: -8.2044, longitude: 111.0922),
    IndonesianCity(name: 'Kab. Pamekasan (Madura)', province: 'Jawa Timur', latitude: -7.1600, longitude: 113.4756),
    IndonesianCity(name: 'Kab. Bangkalan (Madura)', province: 'Jawa Timur', latitude: -7.0306, longitude: 112.7483),
    IndonesianCity(name: 'Kab. Sampang (Madura)', province: 'Jawa Timur', latitude: -7.1878, longitude: 113.2394),
    IndonesianCity(name: 'Kab. Sumenep (Madura)', province: 'Jawa Timur', latitude: -7.0167, longitude: 113.8667),
    IndonesianCity(name: 'Kab. Ponorogo', province: 'Jawa Timur', latitude: -7.8683, longitude: 111.4625),
    IndonesianCity(name: 'Kab. Situbondo', province: 'Jawa Timur', latitude: -7.7061, longitude: 114.0044),
    IndonesianCity(name: 'Kab. Tuban', province: 'Jawa Timur', latitude: -6.8978, longitude: 112.0647),
    IndonesianCity(name: 'Kab. Tulungagung', province: 'Jawa Timur', latitude: -8.0667, longitude: 111.9000),

    // Sumatera Utara
    IndonesianCity(name: 'Kota Medan', province: 'Sumatera Utara', latitude: 3.5952, longitude: 98.6722),
    IndonesianCity(name: 'Kota Binjai', province: 'Sumatera Utara', latitude: 3.6000, longitude: 98.4833),
    IndonesianCity(name: 'Kota Pematangsiantar', province: 'Sumatera Utara', latitude: 2.9597, longitude: 99.0683),
    IndonesianCity(name: 'Kota Padang Sidempuan', province: 'Sumatera Utara', latitude: 1.3733, longitude: 99.2731),
    IndonesianCity(name: 'Kab. Deli Serdang', province: 'Sumatera Utara', latitude: 3.5186, longitude: 98.7117),
    IndonesianCity(name: 'Kab. Asahan (Kisaran)', province: 'Sumatera Utara', latitude: 2.9839, longitude: 99.6267),
    IndonesianCity(name: 'Kab. Langkat', province: 'Sumatera Utara', latitude: 3.7381, longitude: 98.2431),

    // Sumatera Barat
    IndonesianCity(name: 'Kota Padang', province: 'Sumatera Barat', latitude: -0.9471, longitude: 100.4172),
    IndonesianCity(name: 'Kota Bukittinggi', province: 'Sumatera Barat', latitude: -0.3056, longitude: 100.3692),
    IndonesianCity(name: 'Kota Payakumbuh', province: 'Sumatera Barat', latitude: -0.2244, longitude: 100.6331),
    IndonesianCity(name: 'Kota Pariaman', province: 'Sumatera Barat', latitude: -0.6264, longitude: 100.1200),
    IndonesianCity(name: 'Kota Solok', province: 'Sumatera Barat', latitude: -0.7989, longitude: 100.6586),

    // Riau & Kep. Riau
    IndonesianCity(name: 'Kota Pekanbaru', province: 'Riau', latitude: 0.5071, longitude: 101.4478),
    IndonesianCity(name: 'Kota Dumai', province: 'Riau', latitude: 1.6667, longitude: 101.4500),
    IndonesianCity(name: 'Kota Batam', province: 'Kepulauan Riau', latitude: 1.1301, longitude: 104.0529),
    IndonesianCity(name: 'Kota Tanjung Pinang', province: 'Kepulauan Riau', latitude: 0.9167, longitude: 104.4500),

    // Aceh
    IndonesianCity(name: 'Kota Banda Aceh', province: 'Aceh', latitude: 5.5483, longitude: 95.3238),
    IndonesianCity(name: 'Kota Lhokseumawe', province: 'Aceh', latitude: 5.1803, longitude: 97.1408),
    IndonesianCity(name: 'Kota Langsa', province: 'Aceh', latitude: 4.4719, longitude: 97.9686),
    IndonesianCity(name: 'Kab. Aceh Besar (Jantho)', province: 'Aceh', latitude: 5.2917, longitude: 95.6167),

    // Sumatera Selatan & Lampung
    IndonesianCity(name: 'Kota Palembang', province: 'Sumatera Selatan', latitude: -2.9761, longitude: 104.7754),
    IndonesianCity(name: 'Kota Lubuklinggau', province: 'Sumatera Selatan', latitude: -3.2944, longitude: 102.8611),
    IndonesianCity(name: 'Kota Prabumulih', province: 'Sumatera Selatan', latitude: -3.4333, longitude: 104.2333),
    IndonesianCity(name: 'Kota Bandar Lampung', province: 'Lampung', latitude: -5.4500, longitude: 105.2667),
    IndonesianCity(name: 'Kota Metro', province: 'Lampung', latitude: -5.1136, longitude: 105.3067),

    // Jambi, Bengkulu, Bangka Belitung
    IndonesianCity(name: 'Kota Jambi', province: 'Jambi', latitude: -1.6100, longitude: 103.6100),
    IndonesianCity(name: 'Kota Bengkulu', province: 'Bengkulu', latitude: -3.8004, longitude: 102.2655),
    IndonesianCity(name: 'Kota Pangkal Pinang', province: 'Bangka Belitung', latitude: -2.1333, longitude: 106.1167),

    // Kalimantan
    IndonesianCity(name: 'Kota Pontianak', province: 'Kalimantan Barat', latitude: -0.0263, longitude: 109.3425),
    IndonesianCity(name: 'Kota Singkawang', province: 'Kalimantan Barat', latitude: 0.9067, longitude: 108.9867),
    IndonesianCity(name: 'Kota Banjarmasin', province: 'Kalimantan Selatan', latitude: -3.3194, longitude: 114.5908),
    IndonesianCity(name: 'Kota Banjarbaru', province: 'Kalimantan Selatan', latitude: -3.4403, longitude: 114.8300),
    IndonesianCity(name: 'Kota Balikpapan', province: 'Kalimantan Timur', latitude: -1.2654, longitude: 116.8312),
    IndonesianCity(name: 'Kota Samarinda', province: 'Kalimantan Timur', latitude: -0.5022, longitude: 117.1536),
    IndonesianCity(name: 'Kota Bontang', province: 'Kalimantan Timur', latitude: 0.1333, longitude: 117.5000),
    IndonesianCity(name: 'Kota IKN (Nusantara)', province: 'Kalimantan Timur', latitude: -0.9744, longitude: 116.7092),
    IndonesianCity(name: 'Kota Palangka Raya', province: 'Kalimantan Tengah', latitude: -2.2078, longitude: 113.9164),
    IndonesianCity(name: 'Kota Tarakan', province: 'Kalimantan Utara', latitude: 3.3000, longitude: 117.6333),

    // Sulawesi
    IndonesianCity(name: 'Kota Makassar', province: 'Sulawesi Selatan', latitude: -5.1477, longitude: 119.4327),
    IndonesianCity(name: 'Kota Parepare', province: 'Sulawesi Selatan', latitude: -4.0133, longitude: 119.6256),
    IndonesianCity(name: 'Kota Palopo', province: 'Sulawesi Selatan', latitude: -2.9942, longitude: 120.1969),
    IndonesianCity(name: 'Kota Manado', province: 'Sulawesi Utara', latitude: 1.4748, longitude: 124.8428),
    IndonesianCity(name: 'Kota Kotamobagu', province: 'Sulawesi Utara', latitude: 0.7417, longitude: 124.3167),
    IndonesianCity(name: 'Kota Palu', province: 'Sulawesi Tengah', latitude: -0.8917, longitude: 119.8707),
    IndonesianCity(name: 'Kota Kendari', province: 'Sulawesi Tenggara', latitude: -3.9985, longitude: 122.5126),
    IndonesianCity(name: 'Kota Gorontalo', province: 'Gorontalo', latitude: 0.5433, longitude: 123.0567),
    IndonesianCity(name: 'Kab. Mamuju', province: 'Sulawesi Barat', latitude: -2.6778, longitude: 118.8872),

    // Bali & Nusa Tenggara
    IndonesianCity(name: 'Kota Denpasar', province: 'Bali', latitude: -8.6705, longitude: 115.2126),
    IndonesianCity(name: 'Kota Mataram (Lombok)', province: 'NTB', latitude: -8.5833, longitude: 116.1167),
    IndonesianCity(name: 'Kota Bima (Sumbawa)', province: 'NTB', latitude: -8.4608, longitude: 118.7267),
    IndonesianCity(name: 'Kota Kupang', province: 'NTT', latitude: -10.1772, longitude: 123.6070),

    // Maluku & Papua
    IndonesianCity(name: 'Kota Ambon', province: 'Maluku', latitude: -3.6954, longitude: 128.1814),
    IndonesianCity(name: 'Kota Ternate', province: 'Maluku Utara', latitude: 0.7833, longitude: 127.3667),
    IndonesianCity(name: 'Kota Jayapura', province: 'Papua', latitude: -2.5337, longitude: 140.7181),
    IndonesianCity(name: 'Kota Sorong', province: 'Papua Barat Daya', latitude: -0.8762, longitude: 131.2558),
    IndonesianCity(name: 'Kab. Manokwari', province: 'Papua Barat', latitude: -0.8615, longitude: 134.0620),
    IndonesianCity(name: 'Kota Merauke', province: 'Papua Selatan', latitude: -8.4991, longitude: 140.4049),
  ];
}
