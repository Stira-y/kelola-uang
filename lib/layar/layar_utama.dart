import 'package:flutter/material.dart';
import '../model/model_transaksi.dart';
import '../model/model_target.dart';
import '../layanan/layanan_penyimpanan.dart';
import '../komponen/kartu_task_target.dart';
import '../utilitas/format_uang.dart';
import 'layar_tambah_transaksi.dart';
import 'layar_riwayat.dart';
import 'layar_atur_target.dart';

/// Layar utama dashboard aplikasi Kelola Uang
class LayarUtama extends StatefulWidget {
  const LayarUtama({super.key});

  @override
  State<LayarUtama> createState() => _LayarUtamaState();
}

class _LayarUtamaState extends State<LayarUtama> {
  final LayananPenyimpanan _layananPenyimpanan = LayananPenyimpanan();

  List<ModelTransaksi> _daftarTransaksi = [];
  ModelTarget _taskTarget = ModelTarget(
    namaTarget: 'Batas Belanja',
    jumlahTarget: 500000.0,
    keteranganTarget: 'Batas alokasi belanja',
  );

  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  /// Memuat transaksi dan task target dari penyimpanan lokal
  Future<void> _muatData() async {
    setState(() {
      _sedangMemuat = true;
    });

    final transaksi = await _layananPenyimpanan.ambilSemuaTransaksi();
    final target = await _layananPenyimpanan.ambilTaskTarget();

    setState(() {
      _daftarTransaksi = transaksi;
      _taskTarget = target;
      _sedangMemuat = false;
    });
  }

  /// Menambahkan transaksi baru dan memperbarui tampilan
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

  /// Menghapus transaksi dan memperbarui tampilan
  Future<void> _hapusTransaksi(String idTransaksi) async {
    await _layananPenyimpanan.hapusTransaksi(idTransaksi);
    await _muatData();
  }

  /// Memuat data contoh simulasi
  Future<void> _aksiMuatDataContoh() async {
    await _layananPenyimpanan.pasangDataContoh();
    await _muatData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data simulasi berhasil dimuat!')),
    );
  }

  /// Menghapus semua catatan data
  Future<void> _aksiHapusSemuaData() async {
    await _layananPenyimpanan.hapusSemuaTransaksi();
    await _muatData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua catatan berhasil direset.')),
    );
  }

  /// Membuka form atur target anggaran
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
            setState(() {
              _taskTarget = targetBaru;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task Target berhasil diperbarui!')),
              );
            }
          },
        );
      },
    );
  }

  /// Membuka layar tambah transaksi
  void _bukaLayarTambahTransaksi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (konteks) => LayarTambahTransaksi(
          saatDisimpan: _tambahTransaksiBaru,
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
          daftarSemuaTransaksi: _daftarTransaksi,
          saatHapusTransaksi: _hapusTransaksi,
        ),
      ),
    ).then((_) => _muatData());
  }

  @override
  Widget build(BuildContext context) {
    // Perhitungan total keuangan
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
              if (nilai == 'muat_contoh') {
                _aksiMuatDataContoh();
              } else if (nilai == 'hapus_semua') {
                _aksiHapusSemuaData();
              }
            },
            itemBuilder: (konteks) => [
              const PopupMenuItem(
                value: 'muat_contoh',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Isi Data Simulasi'),
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

                    const SizedBox(height: 10),

                    // 2. KARTU TASK TARGET ANGGARAN (Uang Saya / Target, contoh: 350k / 500k)
                    KartuTaskTarget(
                      totalUangSaya: totalUangSaya,
                      taskTarget: _taskTarget,
                      saatDitekanAturTarget: _bukaModalAturTarget,
                    ),

                    // 3. MENU TOMBOL CEPAT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _bukaLayarTambahTransaksi,
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                              label: const Text('Catat Transaksi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _bukaLayarRiwayat,
                              icon: const Icon(Icons.date_range_rounded, size: 18),
                              label: const Text('Cek Riwayat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: const BorderSide(color: Colors.teal),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. DAFTAR CATATAN TERBARU
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
                                'Klik tombol "+ Catat Transaksi" untuk memulai pembukuan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _aksiMuatDataContoh,
                                icon: const Icon(Icons.auto_awesome, size: 16),
                                label: const Text('Isi Data Contoh Simulasi'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.teal,
                                  side: const BorderSide(color: Colors.teal),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                              trailing: Text(
                                '${adalahPemasukan ? '+' : '-'}${FormatUang.keRupiah(item.jumlahUang)}',
                                style: TextStyle(
                                  color: adalahPemasukan ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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

