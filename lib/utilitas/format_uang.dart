import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilitas untuk memformat mata uang Rupiah dan tanggal dalam Bahasa Indonesia
class FormatUang {
  /// Format angka ke bentuk mata uang Rupiah (contoh: Rp 500.000)
  static String keRupiah(double jumlahUang) {
    final formatMataUang = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatMataUang.format(jumlahUang);
  }

  /// Format angka singkat (contoh: 500k, 1.5jt)
  static String keFormatSingkat(double jumlahUang) {
    if (jumlahUang >= 1000000000) {
      return '${(jumlahUang / 1000000000).toStringAsFixed(1)}M';
    } else if (jumlahUang >= 1000000) {
      return '${(jumlahUang / 1000000).toStringAsFixed(1)}jt';
    } else if (jumlahUang >= 1000) {
      return '${(jumlahUang / 1000).toStringAsFixed(0)}k';
    }
    return jumlahUang.toStringAsFixed(0);
  }

  /// Format tanggal singkat (contoh: 10 Nov 2026)
  static String keTanggalSingkat(DateTime tanggal) {
    final formatTanggal = DateFormat('d MMM yyyy', 'id_ID');
    return formatTanggal.format(tanggal);
  }

  /// Format tanggal lengkap beserta hari (contoh: Selasa, 10 November 2026)
  static String keTanggalLengkap(DateTime tanggal) {
    final formatTanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    return formatTanggal.format(tanggal);
  }

  /// Format waktu (contoh: 14:30)
  static String keJam(DateTime tanggal) {
    final formatJam = DateFormat('HH:mm');
    return formatJam.format(tanggal);
  }

  /// Mendapatkan ikon berdasarkan nama kategori
  static IconData ambilIkonKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'belanja':
        return Icons.shopping_bag;
      case 'hiburan':
        return Icons.movie;
      case 'tagihan':
        return Icons.receipt_long;
      case 'kesehatan':
        return Icons.medical_services;
      case 'pendidikan':
        return Icons.school;
      case 'gaji':
        return Icons.account_balance_wallet;
      case 'bonus':
      case 'investasi':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  /// Mendapatkan warna tema berdasarkan nama kategori
  static Color ambilWarnaKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.blue;
      case 'belanja':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'tagihan':
        return Colors.redAccent;
      case 'kesehatan':
        return Colors.teal;
      case 'pendidikan':
        return Colors.indigo;
      case 'gaji':
        return Colors.green;
      case 'bonus':
      case 'investasi':
        return Colors.tealAccent;
      default:
        return Colors.blueGrey;
    }
  }
}
