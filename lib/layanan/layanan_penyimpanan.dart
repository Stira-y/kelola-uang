import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/model_transaksi.dart';
import '../model/model_target.dart';
import '../model/model_target_tercapai.dart';
import '../model/model_estimasi_target.dart';

/// Layanan untuk mengelola penyimpanan data lokal secara offline dan gratis
class LayananPenyimpanan {
  static const String _kunciDaftarTransaksi = 'kunci_daftar_transaksi';
  static const String _kunciTaskTarget = 'kunci_task_target';
  static const String _kunciTargetTercapai = 'kunci_target_tercapai';

  // ========================================================================
  // CRUD TRANSAKSI (CREATE, READ, UPDATE, DELETE)
  // ========================================================================

  /// Mengambil semua transaksi dari memori HP (READ)
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

      // Urutkan dari tanggal terbaru ke terlama
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

  /// Menambahkan satu transaksi baru (CREATE)
  Future<void> tambahTransaksi(ModelTransaksi transaksiBaru) async {
    final daftar = await ambilSemuaTransaksi();
    daftar.insert(0, transaksiBaru);
    await simpanSemuaTransaksi(daftar);
  }

  /// Memperbarui catatan transaksi yang sudah ada (UPDATE)
  Future<void> perbaruiTransaksi(ModelTransaksi transaksiDiperbarui) async {
    final daftar = await ambilSemuaTransaksi();
    final indeks = daftar.indexWhere((item) => item.idTransaksi == transaksiDiperbarui.idTransaksi);
    if (indeks != -1) {
      daftar[indeks] = transaksiDiperbarui;
      // Urutkan kembali berdasarkan tanggal transaksi
      daftar.sort((a, b) => b.tanggalTransaksi.compareTo(a.tanggalTransaksi));
      await simpanSemuaTransaksi(daftar);
    }
  }

  /// Menghapus transaksi berdasarkan ID (DELETE)
  Future<void> hapusTransaksi(String idTransaksi) async {
    final daftar = await ambilSemuaTransaksi();
    daftar.removeWhere((item) => item.idTransaksi == idTransaksi);
    await simpanSemuaTransaksi(daftar);
  }

  /// Menghapus semua catatan transaksi (RESET)
  Future<void> hapusSemuaTransaksi() async {
    final preferensi = await SharedPreferences.getInstance();
    await preferensi.remove(_kunciDaftarTransaksi);
  }

  // ========================================================================
  // KELOLA TARGET BELANJA
  // ========================================================================

  /// Mengambil pengaturan task target belanja
  Future<ModelTarget?> ambilTaskTarget() async {
    final preferensi = await SharedPreferences.getInstance();
    final String? dataMentah = preferensi.getString(_kunciTaskTarget);

    if (dataMentah == null || dataMentah.isEmpty) {
      return null;
    }

    try {
      final target = ModelTarget.dariJson(dataMentah);
      return target.apakahAktif ? target : null;
    } catch (e) {
      return null;
    }
  }

  /// Menyimpan pengaturan task target belanja
  Future<bool> simpanTaskTarget(ModelTarget targetBaru) async {
    final preferensi = await SharedPreferences.getInstance();
    return await preferensi.setString(_kunciTaskTarget, targetBaru.keJson());
  }

  /// Menghapus target belanja aktif
  Future<bool> hapusTaskTarget() async {
    final preferensi = await SharedPreferences.getInstance();
    return await preferensi.remove(_kunciTaskTarget);
  }

  // ========================================================================
  // RIWAYAT TARGET BELANJA YANG TELAH TERPENUHI
  // ========================================================================

  /// Mengambil semua target belanja yang telah terpenuhi
  Future<List<ModelTargetTercapai>> ambilSemuaTargetTercapai() async {
    final preferensi = await SharedPreferences.getInstance();
    final String? dataMentah = preferensi.getString(_kunciTargetTercapai);
    if (dataMentah == null || dataMentah.isEmpty) return [];

    try {
      final List<dynamic> daftarJson = json.decode(dataMentah);
      final hasil = daftarJson
          .map((item) => ModelTargetTercapai.dariMap(item as Map<String, dynamic>))
          .toList();
      hasil.sort((a, b) => b.tanggalTercapai.compareTo(a.tanggalTercapai));
      return hasil;
    } catch (e) {
      return [];
    }
  }

  /// Menyimpan target yang sudah terpenuhi dan menghapus target aktif
  Future<void> simpanTargetTercapai(ModelTargetTercapai targetTercapai) async {
    final daftar = await ambilSemuaTargetTercapai();
    daftar.insert(0, targetTercapai);

    final preferensi = await SharedPreferences.getInstance();
    final String dataTeks = json.encode(daftar.map((item) => item.keMap()).toList());
    await preferensi.setString(_kunciTargetTercapai, dataTeks);

    // Hapus target aktif karena sudah berhasil dicapai dan diarsipkan
    await hapusTaskTarget();
  }

  /// Menghapus riwayat target tercapai berdasarkan ID
  Future<void> hapusRiwayatTargetTercapai(String idTarget) async {
    final daftar = await ambilSemuaTargetTercapai();
    daftar.removeWhere((item) => item.idTarget == idTarget);

    final preferensi = await SharedPreferences.getInstance();
    final String dataTeks = json.encode(daftar.map((item) => item.keMap()).toList());
    await preferensi.setString(_kunciTargetTercapai, dataTeks);
  }

  // ========================================================================
  // PERHITUNGAN & ESTIMASI PENCAPAIAN TARGET DINAMIS
  // ========================================================================

  /// Menghitung estimasi pencapaian target berdasarkan pendapatan tetap dan arus kas riil
  ModelEstimasiTarget hitungEstimasiTarget({
    required ModelTarget target,
    required List<ModelTransaksi> daftarTransaksi,
  }) {
    final totalUangSaatIni = hitungTotalUangSaya(daftarTransaksi);
    final sekarang = DateTime.now();

    DateTime batasAwalPeriode;
    if (target.tipePeriode == TipePeriodeTarget.harian) {
      // Hari ini jam 00:00:00
      batasAwalPeriode = DateTime(sekarang.year, sekarang.month, sekarang.day);
    } else if (target.tipePeriode == TipePeriodeTarget.bulanan) {
      // 30 hari terakhir
      batasAwalPeriode = sekarang.subtract(const Duration(days: 30));
    } else {
      // Mingguan: Awal minggu ini (Senin)
      batasAwalPeriode = DateTime(
        sekarang.year,
        sekarang.month,
        sekarang.day - (sekarang.weekday - 1),
      );
    }

    double pemasukanPeriode = 0;
    double pengeluaranPeriode = 0;

    for (final t in daftarTransaksi) {
      if (!t.tanggalTransaksi.isBefore(batasAwalPeriode) &&
          !t.tanggalTransaksi.isAfter(sekarang)) {
        if (t.jenisTransaksi == JenisTransaksi.pemasukan) {
          pemasukanPeriode += t.jumlahUang;
        } else {
          pengeluaranPeriode += t.jumlahUang;
        }
      }
    }

    return ModelEstimasiTarget.hitung(
      target: target,
      totalUangSaatIni: totalUangSaatIni,
      pemasukanPeriode: pemasukanPeriode,
      pengeluaranPeriode: pengeluaranPeriode,
    );
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
    final awalMingguIni = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day - (sekarang.weekday - 1),
    );
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
    final awalMingguIni = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day - (sekarang.weekday - 1),
    );
    final awalMingguSebelumnya = awalMingguIni.subtract(const Duration(days: 7));
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
