import 'dart:convert';

/// Pilihan tipe periode pendapatan tetap untuk estimasi target
enum TipePeriodeTarget {
  harian,
  mingguan,
  bulanan,
}

/// Model data untuk Target Belanja dan estimasi pencapaiannya
class ModelTarget {
  final String namaTarget;
  final double jumlahTarget;
  final TipePeriodeTarget tipePeriode;
  final double pendapatanTetap;
  final String keteranganTarget;
  final DateTime tanggalDibuat;
  final bool apakahAktif;

  ModelTarget({
    required this.namaTarget,
    required this.jumlahTarget,
    this.tipePeriode = TipePeriodeTarget.mingguan,
    this.pendapatanTetap = 50000.0,
    this.keteranganTarget = '',
    DateTime? tanggalDibuat,
    this.apakahAktif = true,
  }) : tanggalDibuat = tanggalDibuat ?? DateTime.now();

  /// Mengonversi ke bentuk Map untuk disimpan di SharedPreferences
  Map<String, dynamic> keMap() {
    return {
      'namaTarget': namaTarget,
      'jumlahTarget': jumlahTarget,
      'tipePeriode': tipePeriode.name,
      'pendapatanTetap': pendapatanTetap,
      'keteranganTarget': keteranganTarget,
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
      'apakahAktif': apakahAktif,
    };
  }

  /// Membuat objek dari Map JSON
  factory ModelTarget.dariMap(Map<String, dynamic> dataMap) {
    TipePeriodeTarget periode = TipePeriodeTarget.mingguan;
    final teksPeriode = dataMap['tipePeriode']?.toString().toLowerCase();
    if (teksPeriode == 'harian') {
      periode = TipePeriodeTarget.harian;
    } else if (teksPeriode == 'bulanan') {
      periode = TipePeriodeTarget.bulanan;
    }

    return ModelTarget(
      namaTarget: dataMap['namaTarget'] ?? 'Target Belanja',
      jumlahTarget: (dataMap['jumlahTarget'] as num?)?.toDouble() ?? 500000.0,
      tipePeriode: periode,
      pendapatanTetap: (dataMap['pendapatanTetap'] as num?)?.toDouble() ?? 50000.0,
      keteranganTarget: dataMap['keteranganTarget'] ?? '',
      tanggalDibuat: dataMap['tanggalDibuat'] != null
          ? DateTime.tryParse(dataMap['tanggalDibuat']) ?? DateTime.now()
          : DateTime.now(),
      apakahAktif: dataMap['apakahAktif'] ?? true,
    );
  }

  /// Mengonversi ke teks JSON
  String keJson() => json.encode(keMap());

  /// Membuat dari teks JSON
  factory ModelTarget.dariJson(String sumberJson) =>
      ModelTarget.dariMap(json.decode(sumberJson));
}
