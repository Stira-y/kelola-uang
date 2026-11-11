import 'package:flutter/material.dart';
import '../model/model_transaksi.dart';
import '../model/model_target.dart';
import '../model/model_target_tercapai.dart';
import '../model/model_estimasi_target.dart';
import '../layanan/layanan_penyimpanan.dart';
import '../komponen/kartu_task_target.dart';
import '../utilitas/format_uang.dart';
import 'layar_tambah_transaksi.dart';
import 'layar_riwayat.dart';
import 'layar_atur_target.dart';
import 'layar_riwayat_target.dart';

/// Layar utama dashboard aplikasi Kelola Uang
class LayarUtama extends StatefulWidget {
  const LayarUtama({super.key});

  @override
  State<LayarUtama> createState() => _LayarUtamaState();
}

class _LayarUtamaState extends State<LayarUtama> {
  final LayananPenyimpanan _layananPenyimpanan = LayananPenyimpanan();

  List<ModelTransaksi> _daftarTransaksi = [];
  ModelTarget? _taskTarget;
  ModelEstimasiTarget? _estimasiTarget;
  int _jumlahTargetTercapai = 0;

  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  /// Memuat transaksi dan target belanja dari penyimpanan lokal, lalu menghitung estimasi secara otomatis
  Future<void> _muatData() async {
    final transaksi = await _layananPenyimpanan.ambilSemuaTransaksi();
    final target = await _layananPenyimpanan.ambilTaskTarget();
    final riwayatTercapai = await _layananPenyimpanan.ambilSemuaTargetTercapai();

    ModelEstimasiTarget? estimasi;
    if (target != null) {
      estimasi = _layananPenyimpanan.hitungEstimasiTarget(
        target: target,
        daftarTransaksi: transaksi,
      );
    }

    if (mounted) {
      setState(() {
        _daftarTransaksi = transaksi;
        _taskTarget = target;
        _estimasiTarget = estimasi;
        _jumlahTargetTercapai = riwayatTercapai.length;
        _sedangMemuat = false;
      });
    }
  }

  /// Menambahkan transaksi baru (CREATE)
  Future<void> _tambahTransaksiBaru(ModelTransaksi transaksiBaru) async {
    await _layananPenyimpanan.tambahTransaksi(transaksiBaru);
    await _muatData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${transaksiBaru.judulTransaksi}" berhasil ditambahkan'),
          backgroundColor: Colors.teal.shade700,
        ),
      );
    }
  }

  /// Mengubah transaksi yang sudah ada (UPDATE)
  Future<void> _perbaruiTransaksi(ModelTransaksi transaksiDiperbarui) async {
    await _layananPenyimpanan.perbaruiTransaksi(transaksiDiperbarui);
    await _muatData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${transaksiDiperbarui.judulTransaksi}" berhasil diperbarui'),
          backgroundColor: Colors.teal.shade700,
        ),
      );
    }
  }

  /// Menghapus transaksi seketika (DELETE)
  Future<void> _hapusTransaksi(ModelTransaksi transaksi) async {
    await _layananPenyimpanan.hapusTransaksi(transaksi.idTransaksi);
    await _muatData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${transaksi.judulTransaksi}" berhasil dihapus'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Dialog konfirmasi hapus catatan di layar utama
  void _tampilkanDialogHapus(ModelTransaksi transaksi) {
    showDialog(
      context: context,
      builder: (konteks) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus catatan "${transaksi.judulTransaksi}" sejumlah ${FormatUang.keRupiah(transaksi.jumlahUang)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(konteks),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(konteks);
              _hapusTransaksi(transaksi);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Membuka form atur / buat target belanja
  void _bukaModalAturTarget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (konteks) {
        return LayarAturTarget(
          targetSaatIni: _taskTarget,
          saatDisimpan: (targetBaru) async {
            await _layananPenyimpanan.simpanTaskTarget(targetBaru);
            await _muatData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Target Belanja berhasil disimpan!')),
              );
            }
          },
        );
      },
    );
  }

  /// Menghapus target belanja
  void _konfirmasiHapusTarget() {
    showDialog(
      context: context,
      builder: (konteks) => AlertDialog(
        title: const Text('Hapus Target Belanja?'),
        content: const Text(
          'Target belanja dan estimasi waktu pencapaiannya akan dihapus dari beranda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(konteks),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(konteks);
              await _layananPenyimpanan.hapusTaskTarget();
              await _muatData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Target Belanja telah dihapus')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Membuka layar tambah pemasukan atau pengeluaran
  void _bukaLayarTambahTransaksi(JenisTransaksi jenisAwal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (konteks) => LayarTambahTransaksi(
          jenisTransaksiAwal: jenisAwal,
          saatDisimpan: _tambahTransaksiBaru,
        ),
      ),
    );
  }

  /// Membuka layar ubah transaksi
  void _bukaLayarUbahTransaksi(ModelTransaksi transaksi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (konteks) => LayarTambahTransaksi(
          transaksiUntukDiedit: transaksi,
          saatDisimpan: _perbaruiTransaksi,
        ),
      ),
    );
  }

  /// Membuka layar riwayat pengeluaran
  void _bukaLayarRiwayat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (konteks) => LayarRiwayat(
          saatDataBerubah: _muatData,
        ),
      ),
    ).then((_) => _muatData());
  }

  /// Menyimpan target belanja yang telah terpenuhi beserta tanggalnya
  Future<void> _simpanTargetTercapai() async {
    if (_taskTarget == null) return;
    final sekarang = DateTime.now();
    final targetSelesai = ModelTargetTercapai(
      idTarget: sekarang.millisecondsSinceEpoch.toString(),
      namaTarget: _taskTarget!.namaTarget,
      jumlahTarget: _taskTarget!.jumlahTarget,
      tanggalDibuat: _taskTarget!.tanggalDibuat,
      tanggalTercapai: sekarang,
      keterangan: 'Tercapai dengan saldo ${FormatUang.keRupiah(_estimasiTarget?.totalUangSaatIni ?? _taskTarget!.jumlahTarget)}',
    );

    await _layananPenyimpanan.simpanTargetTercapai(targetSelesai);
    await _muatData();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (konteks) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Target Tercapai!'),
          ],
        ),
        content: Text(
          'Selamat! Target "${targetSelesai.namaTarget}" (${FormatUang.keRupiah(targetSelesai.jumlahTarget)}) telah berhasil disimpan pada ${FormatUang.keTanggalLengkap(sekarang)}.\n\nTarget aktif telah diarsipkan dan kamu sekarang bisa membuat target belanja baru!',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(konteks),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Membuka lembar riwayat target yang pernah tercapai
  void _bukaLayarRiwayatTarget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (konteks) => LayarRiwayatTarget(
        saatDataBerubah: _muatData,
      ),
    );
  }

  /// Mereset semua transaksi
  Future<void> _aksiResetSemuaData() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (konteks) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text('Semua catatan transaksi keuangan akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(konteks, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(konteks, true),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (konfirmasi == true) {
      await _layananPenyimpanan.hapusSemuaTransaksi();
      await _muatData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua catatan berhasil direset.')),
      );
    }
  }

  /// Menghitung ulang pencapaian target secara manual saat tombol ditekan
  Future<void> _hitungUlangPencapaianTarget() async {
    await _muatData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estimasi pencapaian target berhasil dihitung ulang!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalUangSaya = _layananPenyimpanan.hitungTotalUangSaya(_daftarTransaksi);

    double totalPemasukan = 0;
    double totalPengeluaran = 0;
    for (final item in _daftarTransaksi) {
      if (item.jenisTransaksi == JenisTransaksi.pemasukan) {
        totalPemasukan += item.jumlahUang;
      } else {
        totalPengeluaran += item.jumlahUang;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Uang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            Text(
              FormatUang.keTanggalLengkap(DateTime.now()),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.teal),
            tooltip: 'Riwayat Pengeluaran',
            onPressed: _bukaLayarRiwayat,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (nilai) {
              if (nilai == 'target_tercapai') {
                _bukaLayarRiwayatTarget();
              } else if (nilai == 'hapus_semua') {
                _aksiResetSemuaData();
              }
            },
            itemBuilder: (konteks) => [
              PopupMenuItem(
                value: 'target_tercapai',
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text('Target Tercapai ($_jumlahTargetTercapai)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'hapus_semua',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Reset Semua Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _sedangMemuat
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : RefreshIndicator(
              onRefresh: _muatData,
              color: Colors.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // 1. KARTU SALDO DOMPET "UANG SAYA"
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade800, Colors.teal.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Saldo (Uang Saya)',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Catatan Virtual',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            FormatUang.keRupiah(totalUangSaya),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Rincian Pemasukan & Pengeluaran Ringkas
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 18),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Pemasukan',
                                              style: TextStyle(color: Colors.white70, fontSize: 10),
                                            ),
                                            Text(
                                              FormatUang.keFormatSingkat(totalPemasukan),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Pengeluaran',
                                              style: TextStyle(color: Colors.white70, fontSize: 10),
                                            ),
                                            Text(
                                              FormatUang.keFormatSingkat(totalPengeluaran),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 2. KARTU TARGET BELANJA & ESTIMASI PENCAPAIAN
                    KartuTaskTarget(
                      taskTarget: _taskTarget,
                      estimasi: _estimasiTarget,
                      jumlahTargetTercapai: _jumlahTargetTercapai,
                      saatDitekanBuatTarget: _bukaModalAturTarget,
                      saatDitekanUbahTarget: _bukaModalAturTarget,
                      saatDitekanHapusTarget: _konfirmasiHapusTarget,
                      saatDitekanHitungUlang: _hitungUlangPencapaianTarget,
                      saatDitekanSimpanTargetTercapai: _simpanTargetTercapai,
                      saatDitekanLihatRiwayatTarget: _bukaLayarRiwayatTarget,
                    ),

                    // 3. DUA TOMBOL CATAT TRANSAKSI (TAMBAH PEMASUKAN & TAMBAH PENGELUARAN) + CEK RIWAYAT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Tombol Tambah Pemasukan
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _bukaLayarTambahTransaksi(JenisTransaksi.pemasukan),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                  label: const Text('Pemasukan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Tombol Tambah Pengeluaran
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _bukaLayarTambahTransaksi(JenisTransaksi.pengeluaran),
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                                  label: const Text('Pengeluaran'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent.shade400,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Tombol Cek Riwayat
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _bukaLayarRiwayat,
                              icon: const Icon(Icons.date_range_rounded, size: 18),
                              label: const Text('Cek Riwayat (Minggu Ini, Lalu & 1 Bulan)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal.shade800,
                                side: BorderSide(color: Colors.teal.shade400),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 4. DAFTAR TRANSAKSI TERKINI DENGAN FULL CRUD (BISA DIEDIT DAN DIHAPUS)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaksi Terkini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (_daftarTransaksi.isNotEmpty)
                            TextButton(
                              onPressed: _bukaLayarRiwayat,
                              child: const Text('Lihat Semua'),
                            ),
                        ],
                      ),
                    ),

                    if (_daftarTransaksi.isEmpty)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada catatan keuangan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gunakan tombol "+ Pemasukan" atau "- Pengeluaran" di atas untuk mulai mencatat keuanganmu.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _daftarTransaksi.length > 5 ? 5 : _daftarTransaksi.length,
                        itemBuilder: (konteks, indeks) {
                          final item = _daftarTransaksi[indeks];
                          final adalahPemasukan = item.jenisTransaksi == JenisTransaksi.pemasukan;
                          final warnaKategori = FormatUang.ambilWarnaKategori(item.kategoriTransaksi);
                          final ikonKategori = FormatUang.ambilIkonKategori(item.kategoriTransaksi);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: warnaKategori.withValues(alpha: 0.12),
                                child: Icon(ikonKategori, color: warnaKategori, size: 22),
                              ),
                              title: Text(
                                item.judulTransaksi,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                '${FormatUang.keTanggalSingkat(item.tanggalTransaksi)} • ${item.kategoriTransaksi}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${adalahPemasukan ? '+' : '-'}${FormatUang.keRupiah(item.jumlahUang)}',
                                    style: TextStyle(
                                      color: adalahPemasukan ? Colors.green : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.teal),
                                    tooltip: 'Ubah',
                                    onPressed: () => _bukaLayarUbahTransaksi(item),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                                    tooltip: 'Hapus',
                                    onPressed: () => _tampilkanDialogHapus(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
