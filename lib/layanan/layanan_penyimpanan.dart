import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/model_transaksi.dart';
import '../model/model_target.dart';

/// Layanan untuk mengelola penyimpanan data lokal secara offline dan gratis
class LayananPenyimpanan {
  static const String _kunciDaftarTransaksi = 'kunci_daftar_transaksi';
  static const String _kunciTaskTarget = 'kunci_task_target';

  /// Mengambil semua transaksi dari memori HP
  Future<List<ModelTransaksi>> ambilSemuaTransaksi() async {
    final preferensi = await SharedPreferences.getInstance();
    final String? dataMentah = preferensi.getString(_kunciDaftarTransaksi);

    if (dataMentah == null || dataMentah.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> daftarJson = json.decode(dataMentah);
      final daftarTransaksi = daftarJson
          .map((item) => ModelTransaksi.dariMap(item as Map<String, dynamic>))
          .toList();

      // Urutkan dari yang terbaru ke terlama
      daftarTransaksi.sort((a, b) => b.tanggalTransaksi.compareTo(a.tanggalTransaksi));
      return daftarTransaksi;
    } catch (e) {
      return [];
    }
  }

  /// Menyimpan seluruh daftar transaksi ke memori HP
  Future<bool> simpanSemuaTransaksi(List<ModelTransaksi> daftarTransaksi) async {
    final preferensi = await SharedPreferences.getInstance();
    final daftarMap = daftarTransaksi.map((t) => t.keMap()).toList();
    final String dataTeks = json.encode(daftarMap);
    return await preferensi.setString(_kunciDaftarTransaksi, dataTeks);
  }

  /// Menambahkan satu transaksi baru
  Future<void> tambahTransaksi(ModelTransaksi transaksiBaru) async {
    final daftar = await ambilSemuaTransaksi();
    daftar.insert(0, transaksiBaru);
    await simpanSemuaTransaksi(daftar);
  }

  /// Menghapus transaksi berdasarkan ID
  Future<void> hapusTransaksi(String idTransaksi) async {
    final daftar = await ambilSemuaTransaksi();
    daftar.removeWhere((item) => item.idTransaksi == idTransaksi);
    await simpanSemuaTransaksi(daftar);
  }

  /// Menghapus semua catatan transaksi
  Future<void> hapusSemuaTransaksi() async {
    final preferensi = await SharedPreferences.getInstance();
    await preferensi.remove(_kunciDaftarTransaksi);
  }

  /// Menambahkan beberapa data contoh simulasi untuk menguji fitur
  Future<void> pasangDataContoh() async {
    final sekarang = DateTime.now();
    final dataContoh = [
      // Pemasukan awal bulan
      ModelTransaksi(
        idTransaksi: 'cth_1',
        judulTransaksi: 'Uang Saku / Pemasukan Virtual',
        jumlahUang: 800000,
        jenisTransaksi: JenisTransaksi.pemasukan,
        kategoriTransaksi: 'Uang Saku',
        tanggalTransaksi: sekarang.subtract(const Duration(days: 20)),
        catatanTambahan: 'Saldo awal untuk simulasi',
      ),
      // Pengeluaran 1 bulan lalu (22 hari lalu)
      ModelTransaksi(
        idTransaksi: 'cth_2',
        judulTransaksi: 'Buku Catatan & Alat Tulis',
        jumlahUang: 45000,
        jenisTransaksi: JenisTransaksi.pengeluaran,
        kategoriTransaksi: 'Pendidikan',
        tanggalTransaksi: sekarang.subtract(const Duration(days: 22)),
      ),
      // Pengeluaran minggu sebelumnya (10 hari lalu)
      ModelTransaksi(
        idTransaksi: 'cth_3',
        judulTransaksi: 'Makan Malam Bersama Teman',
        jumlahUang: 85000,
        jenisTransaksi: JenisTransaksi.pengeluaran,
        kategoriTransaksi: 'Makanan & Minuman',
        tanggalTransaksi: sekarang.subtract(const Duration(days: 10)),
      ),
      ModelTransaksi(
        idTransaksi: 'cth_4',
        judulTransaksi: 'Bensin & Parkir Motor',
        jumlahUang: 30000,
        jenisTransaksi: JenisTransaksi.pengeluaran,
        kategoriTransaksi: 'Transportasi',
        tanggalTransaksi: sekarang.subtract(const Duration(days: 9)),
      ),
      // Pengeluaran minggu ini (2 hari lalu & hari ini)
      ModelTransaksi(
        idTransaksi: 'cth_5',
        judulTransaksi: 'Paket Internet Bulanan',
        jumlahUang: 100000,
        jenisTransaksi: JenisTransaksi.pengeluaran,
        kategoriTransaksi: 'Tagihan',
        tanggalTransaksi: sekarang.subtract(const Duration(days: 2)),
      ),
      ModelTransaksi(
        idTransaksi: 'cth_6',
        judulTransaksi: 'Kopi & Camilan Sore',
        jumlahUang: 35000,
        jenisTransaksi: JenisTransaksi.pengeluaran,
        kategoriTransaksi: 'Makanan & Minuman',
        tanggalTransaksi: sekarang,
      ),
    ];

    await simpanSemuaTransaksi(dataContoh);

    // Target anggaran 500k
    await simpanTaskTarget(
      ModelTarget(
        namaTarget: 'Batas Belanja',
        jumlahTarget: 500000,
        keteranganTarget: 'Batas belanja bulanan',
      ),
    );
  }

  /// Mengambil pengaturan task target anggaran
  Future<ModelTarget> ambilTaskTarget() async {
    final preferensi = await SharedPreferences.getInstance();
    final String? dataMentah = preferensi.getString(_kunciTaskTarget);

    if (dataMentah == null || dataMentah.isEmpty) {
      // Nilai bawaan awal Rp 500.000 sesuai contoh pengguna
      return ModelTarget(
        namaTarget: 'Batas Belanja',
        jumlahTarget: 500000.0,
        keteranganTarget: 'Batas anggaran bulanan',
      );
    }

    try {
      return ModelTarget.dariJson(dataMentah);
    } catch (e) {
      return ModelTarget(
        namaTarget: 'Batas Belanja',
        jumlahTarget: 500000.0,
      );
    }
  }

  /// Menyimpan pengaturan task target anggaran
  Future<bool> simpanTaskTarget(ModelTarget targetBaru) async {
    final preferensi = await SharedPreferences.getInstance();
    return await preferensi.setString(_kunciTaskTarget, targetBaru.keJson());
  }

  // ========================================================================
  // PERHITUNGAN FILTER PENGELUARAN (Minggu Ini, Minggu Sebelumnya, 1 Bulan)
  // ========================================================================

  /// Menghitung total saldo saat ini (Uang Saya = Total Pemasukan - Total Pengeluaran)
  double hitungTotalUangSaya(List<ModelTransaksi> daftarTransaksi) {
    double total = 0.0;
    for (final t in daftarTransaksi) {
      if (t.jenisTransaksi == JenisTransaksi.pemasukan) {
        total += t.jumlahUang;
      } else {
        total -= t.jumlahUang;
      }
    }
    return total;
  }

  /// Mengambil transaksi pengeluaran pada minggu ini (Senin s.d. Minggu ini)
  List<ModelTransaksi> ambilPengeluaranMingguIni(List<ModelTransaksi> daftar) {
    final sekarang = DateTime.now();
    // Hari Senin minggu ini jam 00:00:00
    final awalMingguIni = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day - (sekarang.weekday - 1),
    );
    // Akhir minggu ini (Minggu jam 23:59:59)
    final akhirMingguIni = awalMingguIni
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));

    return daftar.where((t) {
      return t.jenisTransaksi == JenisTransaksi.pengeluaran &&
          !t.tanggalTransaksi.isBefore(awalMingguIni) &&
          !t.tanggalTransaksi.isAfter(akhirMingguIni);
    }).toList();
  }

  /// Mengambil transaksi pengeluaran pada minggu sebelumnya
  List<ModelTransaksi> ambilPengeluaranMingguSebelumnya(List<ModelTransaksi> daftar) {
    final sekarang = DateTime.now();
    // Awal minggu ini
    final awalMingguIni = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day - (sekarang.weekday - 1),
    );
    // Awal minggu sebelumnya: 7 hari sebelum awal minggu ini
    final awalMingguSebelumnya = awalMingguIni.subtract(const Duration(days: 7));
    // Akhir minggu sebelumnya: tepat sebelum awal minggu ini
    final akhirMingguSebelumnya = awalMingguIni.subtract(const Duration(seconds: 1));

    return daftar.where((t) {
      return t.jenisTransaksi == JenisTransaksi.pengeluaran &&
          !t.tanggalTransaksi.isBefore(awalMingguSebelumnya) &&
          !t.tanggalTransaksi.isAfter(akhirMingguSebelumnya);
    }).toList();
  }

  /// Mengambil transaksi pengeluaran selama 1 bulan (30 hari terakhir)
  List<ModelTransaksi> ambilPengeluaranSatuBulan(List<ModelTransaksi> daftar) {
    final sekarang = DateTime.now();
    final batasSatuBulanLalu = sekarang.subtract(const Duration(days: 30));

    return daftar.where((t) {
      return t.jenisTransaksi == JenisTransaksi.pengeluaran &&
          !t.tanggalTransaksi.isBefore(batasSatuBulanLalu) &&
          !t.tanggalTransaksi.isAfter(sekarang);
    }).toList();
  }

  /// Menghitung total jumlah uang dari daftar transaksi tertentu
  double hitungTotalPengeluaran(List<ModelTransaksi> daftar) {
    double total = 0.0;
    for (final item in daftar) {
      total += item.jumlahUang;
    }
    return total;
  }
}

