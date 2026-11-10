import 'dart:convert';

/// Model data untuk task target anggaran
class ModelTarget {
  final String namaTarget;
  final double jumlahTarget;
  final String keteranganTarget;

  ModelTarget({
    required this.namaTarget,
    required this.jumlahTarget,
    this.keteranganTarget = '',
  });

  /// Mengonversi ke Map
  Map<String, dynamic> keMap() {
    return {
      'namaTarget': namaTarget,
      'jumlahTarget': jumlahTarget,
      'keteranganTarget': keteranganTarget,
    };
  }

  /// Membuat objek dari Map
  factory ModelTarget.dariMap(Map<String, dynamic> dataMap) {
    return ModelTarget(
      namaTarget: dataMap['namaTarget'] ?? 'Target Anggaran',
      jumlahTarget: (dataMap['jumlahTarget'] as num?)?.toDouble() ?? 500000.0,
      keteranganTarget: dataMap['keteranganTarget'] ?? '',
    );
  }

  /// Mengonversi ke teks JSON
  String keJson() => json.encode(keMap());

  /// Membuat dari teks JSON
  factory ModelTarget.dariJson(String sumberJson) =>
      ModelTarget.dariMap(json.decode(sumberJson));
}

