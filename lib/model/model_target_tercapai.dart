import 'dart:convert';

/// Model untuk menyimpan riwayat target belanja yang telah berhasil terpenuhi
class ModelTargetTercapai {
  final String idTarget;
  final String namaTarget;
  final double jumlahTarget;
  final DateTime tanggalDibuat;
  final DateTime tanggalTercapai;
  final String keterangan;

  ModelTargetTercapai({
    required this.idTarget,
    required this.namaTarget,
    required this.jumlahTarget,
    required this.tanggalDibuat,
    required this.tanggalTercapai,
    this.keterangan = '',
  });

  Map<String, dynamic> keMap() {
    return {
      'idTarget': idTarget,
      'namaTarget': namaTarget,
      'jumlahTarget': jumlahTarget,
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
      'tanggalTercapai': tanggalTercapai.toIso8601String(),
      'keterangan': keterangan,
    };
  }

  factory ModelTargetTercapai.dariMap(Map<String, dynamic> dataMap) {
    return ModelTargetTercapai(
      idTarget: dataMap['idTarget'] ?? '',
      namaTarget: dataMap['namaTarget'] ?? 'Target Belanja',
      jumlahTarget: (dataMap['jumlahTarget'] as num?)?.toDouble() ?? 0.0,
      tanggalDibuat: dataMap['tanggalDibuat'] != null
          ? DateTime.tryParse(dataMap['tanggalDibuat']) ?? DateTime.now()
          : DateTime.now(),
      tanggalTercapai: dataMap['tanggalTercapai'] != null
          ? DateTime.tryParse(dataMap['tanggalTercapai']) ?? DateTime.now()
          : DateTime.now(),
      keterangan: dataMap['keterangan'] ?? '',
    );
  }

  String keJson() => json.encode(keMap());

  factory ModelTargetTercapai.dariJson(String sumberJson) =>
      ModelTargetTercapai.dariMap(json.decode(sumberJson));
}

