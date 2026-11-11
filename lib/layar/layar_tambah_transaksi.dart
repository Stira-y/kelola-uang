import 'package:flutter/material.dart';
import '../model/model_transaksi.dart';
import '../utilitas/format_uang.dart';

/// Layar untuk menambah atau mengubah catatan transaksi (Pemasukan / Pengeluaran)
class LayarTambahTransaksi extends StatefulWidget {
  final ModelTransaksi? transaksiUntukDiedit;
  final JenisTransaksi jenisTransaksiAwal;
  final Function(ModelTransaksi transaksi) saatDisimpan;

  const LayarTambahTransaksi({
    super.key,
    this.transaksiUntukDiedit,
    this.jenisTransaksiAwal = JenisTransaksi.pengeluaran,
    required this.saatDisimpan,
  });

  @override
  State<LayarTambahTransaksi> createState() => _LayarTambahTransaksiState();
}

class _LayarTambahTransaksiState extends State<LayarTambahTransaksi> {
  final _formKunci = GlobalKey<FormState>();
  late TextEditingController _pengontrolJudul;
  late TextEditingController _pengontrolJumlah;
  late TextEditingController _pengontrolCatatan;

  late JenisTransaksi _jenisDipilih;
  late DateTime _tanggalDipilih;
  late String _kategoriDipilih;

  final List<String> _daftarKategoriPengeluaran = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Kesehatan',
    'Pendidikan',
    'Lain-lain',
  ];

  final List<String> _daftarKategoriPemasukan = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Penjualan',
    'Uang Saku',
    'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.transaksiUntukDiedit;
    if (edit != null) {
      _pengontrolJudul = TextEditingController(text: edit.judulTransaksi);
      _pengontrolJumlah = TextEditingController(text: edit.jumlahUang.toStringAsFixed(0));
      _pengontrolCatatan = TextEditingController(text: edit.catatanTambahan);
      _jenisDipilih = edit.jenisTransaksi;
      _tanggalDipilih = edit.tanggalTransaksi;
      _kategoriDipilih = edit.kategoriTransaksi;
    } else {
      _pengontrolJudul = TextEditingController();
      _pengontrolJumlah = TextEditingController();
      _pengontrolCatatan = TextEditingController();
      _jenisDipilih = widget.jenisTransaksiAwal;
      _tanggalDipilih = DateTime.now();
      _kategoriDipilih = _jenisDipilih == JenisTransaksi.pengeluaran
          ? _daftarKategoriPengeluaran.first
          : _daftarKategoriPemasukan.first;
    }
  }

  @override
  void dispose() {
    _pengontrolJudul.dispose();
    _pengontrolJumlah.dispose();
    _pengontrolCatatan.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext konteks) async {
    final DateTime? hasilTanggal = await showDatePicker(
      context: konteks,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (hasilTanggal != null) {
      setState(() {
        _tanggalDipilih = hasilTanggal;
      });
    }
  }

  void _simpanTransaksi() {
    if (_formKunci.currentState!.validate()) {
      final double jumlah = double.parse(_pengontrolJumlah.text.trim());
      final edit = widget.transaksiUntukDiedit;

      final transaksiHasil = ModelTransaksi(
        idTransaksi: edit != null ? edit.idTransaksi : DateTime.now().millisecondsSinceEpoch.toString(),
        judulTransaksi: _pengontrolJudul.text.trim(),
        jumlahUang: jumlah,
        jenisTransaksi: _jenisDipilih,
        kategoriTransaksi: _kategoriDipilih,
        tanggalTransaksi: _tanggalDipilih,
        catatanTambahan: _pengontrolCatatan.text.trim(),
      );

      widget.saatDisimpan(transaksiHasil);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adalahModeEdit = widget.transaksiUntukDiedit != null;
    final daftarKategoriAktif = _jenisDipilih == JenisTransaksi.pengeluaran
        ? _daftarKategoriPengeluaran
        : _daftarKategoriPemasukan;

    // Pastikan kategori yang terpilih valid di daftar kategori saat ini
    if (!daftarKategoriAktif.contains(_kategoriDipilih)) {
      _kategoriDipilih = daftarKategoriAktif.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          adalahModeEdit ? 'Ubah Catatan Transaksi' : (_jenisDipilih == JenisTransaksi.pemasukan ? 'Tambah Pemasukan' : 'Tambah Pengeluaran'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKunci,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pilihan Tab Jenis Transaksi
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _jenisDipilih = JenisTransaksi.pengeluaran;
                              _kategoriDipilih = _daftarKategoriPengeluaran.first;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _jenisDipilih == JenisTransaksi.pengeluaran ? Colors.redAccent : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  color: _jenisDipilih == JenisTransaksi.pengeluaran ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _jenisDipilih = JenisTransaksi.pemasukan;
                              _kategoriDipilih = _daftarKategoriPemasukan.first;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _jenisDipilih == JenisTransaksi.pemasukan ? Colors.green : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Pemasukan',
                                style: TextStyle(
                                  color: _jenisDipilih == JenisTransaksi.pemasukan ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Input Jumlah Uang
                const Text(
                  'Jumlah Uang (Rp)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pengontrolJumlah,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.money_rounded, color: Colors.teal),
                    hintText: 'Contoh: 50000',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.isEmpty) {
                      return 'Harap masukkan nominal uang';
                    }
                    if (double.tryParse(nilai) == null || double.parse(nilai) <= 0) {
                      return 'Nominal uang harus lebih dari 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Input Judul Transaksi
                const Text(
                  'Judul / Nama Catatan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pengontrolJudul,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.edit_note_rounded, color: Colors.teal),
                    hintText: 'Contoh: Sarapan Pagi / Uang Saku',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Harap isi judul catatan';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Pilihan Kategori
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: daftarKategoriAktif.map((kategori) {
                    final bool aktif = _kategoriDipilih == kategori;
                    final ikon = FormatUang.ambilIkonKategori(kategori);
                    final warna = FormatUang.ambilWarnaKategori(kategori);

                    return ChoiceChip(
                      avatar: Icon(
                        ikon,
                        size: 16,
                        color: aktif ? Colors.white : warna,
                      ),
                      label: Text(kategori),
                      selected: aktif,
                      selectedColor: warna,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : Colors.black87,
                        fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (terpilih) {
                        if (terpilih) {
                          setState(() {
                            _kategoriDipilih = kategori;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Pemilih Tanggal
                const Text(
                  'Tanggal Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pilihTanggal(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Colors.teal, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              FormatUang.keTanggalLengkap(_tanggalDipilih),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Catatan Tambahan
                const Text(
                  'Catatan Tambahan (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pengontrolCatatan,
                  maxLines: 2,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.notes_rounded, color: Colors.teal),
                    hintText: 'Tulis keterangan tambahan jika ada...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _simpanTransaksi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      adalahModeEdit ? 'Simpan Perubahan' : 'Simpan Catatan',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
