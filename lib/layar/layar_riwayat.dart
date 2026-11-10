import 'package:flutter/material.dart';
import '../model/model_transaksi.dart';
import '../layanan/layanan_penyimpanan.dart';
import '../utilitas/format_uang.dart';

/// Layar untuk melihat riwayat pengeluaran:
/// - Minggu Ini
/// - Minggu Sebelumnya
/// - Selama 1 Bulan (30 Hari)
class LayarRiwayat extends StatefulWidget {
  final List<ModelTransaksi> daftarSemuaTransaksi;
  final Function(String idTransaksi) saatHapusTransaksi;

  const LayarRiwayat({
    super.key,
    required this.daftarSemuaTransaksi,
    required this.saatHapusTransaksi,
  });

  @override
  State<LayarRiwayat> createState() => _LayarRiwayatState();
}

class _LayarRiwayatState extends State<LayarRiwayat> with SingleTickerProviderStateMixin {
  late TabController _pengontrolTab;
  final LayananPenyimpanan _layananPenyimpanan = LayananPenyimpanan();

  @override
  void initState() {
    super.initState();
    _pengontrolTab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pengontrolTab.dispose();
    super.dispose();
  }

  /// Menampilkan dialog konfirmasi hapus transaksi
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
              widget.saatHapusTransaksi(transaksi.idTransaksi);
              Navigator.pop(konteks);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Komponen tampilan kartu rangkuman total & komparasi
  Widget _bangunKartuRangkuman({
    required String judulPeriode,
    required double totalPengeluaran,
    double? totalMingguLalu,
  }) {
    String? perbandinganTeks;
    Color warnaPerbandingan = Colors.grey;

    if (totalMingguLalu != null) {
      final selisih = totalPengeluaran - totalMingguLalu;
      if (selisih > 0) {
        perbandinganTeks = '▲ Lebih boros ${FormatUang.keRupiah(selisih)} dari minggu lalu';
        warnaPerbandingan = Colors.red.shade700;
      } else if (selisih < 0) {
        perbandinganTeks = '▼ Lebih hemat ${FormatUang.keRupiah(selisih.abs())} dari minggu lalu';
        warnaPerbandingan = Colors.green.shade700;
      } else {
        perbandinganTeks = '= Pengeluaran sama persis dengan minggu lalu';
        warnaPerbandingan = Colors.blueGrey;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pengeluaran ($judulPeriode)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.analytics_rounded, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            FormatUang.keRupiah(totalPengeluaran),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (perbandinganTeks != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                perbandinganTeks,
                style: TextStyle(
                  color: warnaPerbandingan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Komponen daftar item transaksi pengeluaran
  Widget _bangunDaftarTransaksi(List<ModelTransaksi> daftar) {
    if (daftar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum ada pengeluaran di periode ini',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      itemCount: daftar.length,
      itemBuilder: (konteks, indeks) {
        final transaksi = daftar[indeks];
        final warnaKategori = FormatUang.ambilWarnaKategori(transaksi.kategoriTransaksi);
        final ikonKategori = FormatUang.ambilIkonKategori(transaksi.kategoriTransaksi);

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
              transaksi.judulTransaksi,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              '${FormatUang.keTanggalSingkat(transaksi.tanggalTransaksi)} • ${transaksi.kategoriTransaksi}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-${FormatUang.keRupiah(transaksi.jumlahUang)}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade400),
                  onPressed: () => _tampilkanDialogHapus(transaksi),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pengelompokan data pengeluaran berdasarkan periode
    final daftarMingguIni = _layananPenyimpanan.ambilPengeluaranMingguIni(widget.daftarSemuaTransaksi);
    final daftarMingguSebelumnya = _layananPenyimpanan.ambilPengeluaranMingguSebelumnya(widget.daftarSemuaTransaksi);
    final daftarSatuBulan = _layananPenyimpanan.ambilPengeluaranSatuBulan(widget.daftarSemuaTransaksi);

    final totalMingguIni = _layananPenyimpanan.hitungTotalPengeluaran(daftarMingguIni);
    final totalMingguSebelumnya = _layananPenyimpanan.hitungTotalPengeluaran(daftarMingguSebelumnya);
    final totalSatuBulan = _layananPenyimpanan.hitungTotalPengeluaran(daftarSatuBulan);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _pengontrolTab,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Minggu Ini'),
            Tab(text: 'Minggu Lalu'),
            Tab(text: '1 Bulan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _pengontrolTab,
        children: [
          // 1. Tab Minggu Ini
          Column(
            children: [
              _bangunKartuRangkuman(
                judulPeriode: 'Minggu Ini',
                totalPengeluaran: totalMingguIni,
                totalMingguLalu: totalMingguSebelumnya,
              ),
              Expanded(child: _bangunDaftarTransaksi(daftarMingguIni)),
            ],
          ),

          // 2. Tab Minggu Sebelumnya
          Column(
            children: [
              _bangunKartuRangkuman(
                judulPeriode: 'Minggu Sebelumnya',
                totalPengeluaran: totalMingguSebelumnya,
              ),
              Expanded(child: _bangunDaftarTransaksi(daftarMingguSebelumnya)),
            ],
          ),

          // 3. Tab Selama 1 Bulan (30 Hari)
          Column(
            children: [
              _bangunKartuRangkuman(
                judulPeriode: '1 Bulan Terakhir',
                totalPengeluaran: totalSatuBulan,
              ),
              Expanded(child: _bangunDaftarTransaksi(daftarSatuBulan)),
            ],
          ),
        ],
      ),
    );
  }
}

