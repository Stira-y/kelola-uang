import 'dart:convert';

/// Jenis transaksi: pemasukan atau pengeluaran
enum JenisTransaksi {
  pemasukan,
  pengeluaran,
}

/// Model data untuk setiap catatan transaksi keuangan
class ModelTransaksi {
  final String idTransaksi;
  final String judulTransaksi;
  final double jumlahUang;
  final JenisTransaksi jenisTransaksi;
  final String kategoriTransaksi;
  final DateTime tanggalTransaksi;
  final String catatanTambahan;

  ModelTransaksi({
    required this.idTransaksi,
    required this.judulTransaksi,
    required this.jumlahUang,
    required this.jenisTransaksi,
    required this.kategoriTransaksi,
    required this.tanggalTransaksi,
    this.catatanTambahan = '',
  });

  /// Mengonversi objek transaksi menjadi Map JSON
  Map<String, dynamic> keMap() {
    return {
      'idTransaksi': idTransaksi,
      'judulTransaksi': judulTransaksi,
      'jumlahUang': jumlahUang,
      'jenisTransaksi': jenisTransaksi.name,
      'kategoriTransaksi': kategoriTransaksi,
      'tanggalTransaksi': tanggalTransaksi.toIso8601String(),
      'catatanTambahan': catatanTambahan,
    };
  }

  /// Membuat objek transaksi dari Map JSON
  factory ModelTransaksi.dariMap(Map<String, dynamic> dataMap) {
    return ModelTransaksi(
      idTransaksi: dataMap['idTransaksi'] ?? '',
      judulTransaksi: dataMap['judulTransaksi'] ?? '',
      jumlahUang: (dataMap['jumlahUang'] as num).toDouble(),
      jenisTransaksi: dataMap['jenisTransaksi'] == 'pemasukan'
          ? JenisTransaksi.pemasukan
          : JenisTransaksi.pengeluaran,
      kategoriTransaksi: dataMap['kategoriTransaksi'] ?? 'Umum',
      tanggalTransaksi: DateTime.parse(dataMap['tanggalTransaksi']),
      catatanTambahan: dataMap['catatanTambahan'] ?? '',
    );
  }

  /// Mengonversi ke teks JSON
  String keJson() => json.encode(keMap());

  /// Membuat dari teks JSON
  factory ModelTransaksi.dariJson(String sumberJson) =>
      ModelTransaksi.dariMap(json.decode(sumberJson));
}

