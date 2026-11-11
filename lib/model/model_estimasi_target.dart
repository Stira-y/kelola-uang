import 'model_target.dart';

/// Hasil perhitungan estimasi pencapaian target belanja
class ModelEstimasiTarget {
  final double totalUangSaatIni;
  final double sisaKebutuhanUang;
  final double persentasePencapaian;
  final bool apakahSudahTercapai;

  // Laju tabungan rencana
  final double lajuRencanaPerPeriode;
  final double estimasiMingguRencana;
  final double estimasiBulanRencana;

  // Realisasi aktual berdasarkan pemasukan & pengeluaran
  final double pemasukanPeriodeBerjalan;
  final double pengeluaranPeriodeBerjalan;
  final double arusKasBersihPeriodeBerjalan;
  final double lajuEfektifAktual;

  // Estimasi dinamis setelah dipengaruhi pengeluaran/pemasukan nyata
  final double? estimasiHariDinamis;
  final double? estimasiMingguDinamis;
  final double? estimasiBulanDinamis;
  final String statusPenjelasan;
  final bool apakahArusKasNegatif;

  ModelEstimasiTarget({
    required this.totalUangSaatIni,
    required this.sisaKebutuhanUang,
    required this.persentasePencapaian,
    required this.apakahSudahTercapai,
    required this.lajuRencanaPerPeriode,
    required this.estimasiMingguRencana,
    required this.estimasiBulanRencana,
    required this.pemasukanPeriodeBerjalan,
    required this.pengeluaranPeriodeBerjalan,
    required this.arusKasBersihPeriodeBerjalan,
    required this.lajuEfektifAktual,
    required this.estimasiHariDinamis,
    required this.estimasiMingguDinamis,
    required this.estimasiBulanDinamis,
    required this.statusPenjelasan,
    required this.apakahArusKasNegatif,
  });

  /// Menghitung estimasi pencapaian secara otomatis
  factory ModelEstimasiTarget.hitung({
    required ModelTarget target,
    required double totalUangSaatIni,
    required double pemasukanPeriode,
    required double pengeluaranPeriode,
  }) {
    final double jumlahTarget = target.jumlahTarget;
    final double sisaKebutuhan = (jumlahTarget - totalUangSaatIni).clamp(0.0, double.infinity);
    final double persentase = jumlahTarget > 0
        ? (totalUangSaatIni / jumlahTarget).clamp(0.0, 1.0)
        : 0.0;
    final bool sudahTercapai = totalUangSaatIni >= jumlahTarget;

    // Hitung konversi laju per minggu & per bulan
    double lajuMingguanRencana = target.pendapatanTetap;
    if (target.tipePeriode == TipePeriodeTarget.harian) {
      lajuMingguanRencana = target.pendapatanTetap * 7;
    } else if (target.tipePeriode == TipePeriodeTarget.bulanan) {
      lajuMingguanRencana = target.pendapatanTetap / 4.33;
    }

    final double estimasiMingguRencana = lajuMingguanRencana > 0
        ? (jumlahTarget / lajuMingguanRencana)
        : 0.0;
    final double estimasiBulanRencana = estimasiMingguRencana / 4.33;

    // Realisasi arus kas periode berjalan
    final double arusKasBersih = pemasukanPeriode - pengeluaranPeriode;

    // Laju efektif: jika ada arus kas periode berjalan, gunakan laju efektif
    // atau gunakan rencana yang dikurangi pengeluaran periode berjalan
    double lajuEfektif = target.pendapatanTetap;
    if (pemasukanPeriode > 0 || pengeluaranPeriode > 0) {
      // Jika ada pemasukan nyata periode ini, gunakan arus kas bersih
      // jika pemasukan belum ada tapi ada pengeluaran, rencana dikurangi pengeluaran
      if (pemasukanPeriode > 0) {
        lajuEfektif = arusKasBersih;
      } else {
        lajuEfektif = target.pendapatanTetap - pengeluaranPeriode;
      }
    }

    // Konversi laju efektif ke mingguan
    double lajuEfektifMingguan = lajuEfektif;
    if (target.tipePeriode == TipePeriodeTarget.harian) {
      lajuEfektifMingguan = lajuEfektif * 7;
    } else if (target.tipePeriode == TipePeriodeTarget.bulanan) {
      lajuEfektifMingguan = lajuEfektif / 4.33;
    }

    double? estimasiMingguDinamis;
    double? estimasiBulanDinamis;
    double? estimasiHariDinamis;
    String status;
    bool arusKasNegatif = false;

    if (sudahTercapai) {
      status = 'Selamat! Target belanja kamu sudah tercapai!';
    } else if (lajuEfektifMingguan <= 0) {
      arusKasNegatif = true;
      status = 'Pengeluaran melebihi pendapatan di periode ini! Pencapaian target tertunda hingga ada tabungan bersih.';
    } else {
      estimasiMingguDinamis = sisaKebutuhan / lajuEfektifMingguan;
      estimasiBulanDinamis = estimasiMingguDinamis / 4.33;
      estimasiHariDinamis = estimasiMingguDinamis * 7;

      if (lajuEfektif < target.pendapatanTetap) {
        status = 'Estimasi disesuaikan: Butuh sekitar ${estimasiMingguDinamis.toStringAsFixed(1)} minggu (~${estimasiBulanDinamis.toStringAsFixed(1)} bulan) karena ada pengeluaran yang mengurangi pendapatan.';
      } else if (lajuEfektif > target.pendapatanTetap) {
        status = 'Hebat! Kamu menabung lebih banyak dari rencana. Target akan tercapai lebih cepat dalam ${estimasiMingguDinamis.toStringAsFixed(1)} minggu (~${estimasiBulanDinamis.toStringAsFixed(1)} bulan)!';
      } else {
        status = 'Sesuai rencana: Estimasi tercapai dalam ${estimasiMingguDinamis.toStringAsFixed(1)} minggu (~${estimasiBulanDinamis.toStringAsFixed(1)} bulan).';
      }
    }

    return ModelEstimasiTarget(
      totalUangSaatIni: totalUangSaatIni,
      sisaKebutuhanUang: sisaKebutuhan,
      persentasePencapaian: persentase,
      apakahSudahTercapai: sudahTercapai,
      lajuRencanaPerPeriode: target.pendapatanTetap,
      estimasiMingguRencana: estimasiMingguRencana,
      estimasiBulanRencana: estimasiBulanRencana,
      pemasukanPeriodeBerjalan: pemasukanPeriode,
      pengeluaranPeriodeBerjalan: pengeluaranPeriode,
      arusKasBersihPeriodeBerjalan: arusKasBersih,
      lajuEfektifAktual: lajuEfektif,
      estimasiHariDinamis: estimasiHariDinamis,
      estimasiMingguDinamis: estimasiMingguDinamis,
      estimasiBulanDinamis: estimasiBulanDinamis,
      statusPenjelasan: status,
      apakahArusKasNegatif: arusKasNegatif,
    );
  }
}

