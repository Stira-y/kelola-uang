import 'package:flutter/material.dart';
import '../model/model_target.dart';
import '../utilitas/format_uang.dart';

/// Tampilan lembar bawah (bottom sheet) untuk mengubah task target anggaran
class LayarAturTarget extends StatefulWidget {
  final ModelTarget targetSaatIni;
  final Function(ModelTarget targetBaru) saatDisimpan;

  const LayarAturTarget({
    super.key,
    required this.targetSaatIni,
    required this.saatDisimpan,
  });

  @override
  State<LayarAturTarget> createState() => _LayarAturTargetState();
}

class _LayarAturTargetState extends State<LayarAturTarget> {
  late TextEditingController _pengontrolNama;
  late TextEditingController _pengontrolJumlah;
  late TextEditingController _pengontrolKeterangan;

  // Pilihan cepat jumlah target
  final List<double> _pilihanCepat = [
    200000,
    300000,
    500000,
    1000000,
    2000000,
  ];

  @override
  void initState() {
    super.initState();
    _pengontrolNama = TextEditingController(text: widget.targetSaatIni.namaTarget);
    _pengontrolJumlah = TextEditingController(
      text: widget.targetSaatIni.jumlahTarget.toStringAsFixed(0),
    );
    _pengontrolKeterangan = TextEditingController(
      text: widget.targetSaatIni.keteranganTarget,
    );
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolJumlah.dispose();
    _pengontrolKeterangan.dispose();
    super.dispose();
  }

  void _simpanPengaturanTarget() {
    final String nama = _pengontrolNama.text.trim();
    final double? jumlah = double.tryParse(_pengontrolJumlah.text.trim());
    final String keterangan = _pengontrolKeterangan.text.trim();

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama target tidak boleh kosong')),
      );
      return;
    }

    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah target yang valid')),
      );
      return;
    }

    final targetBaru = ModelTarget(
      namaTarget: nama,
      jumlahTarget: jumlah,
      keteranganTarget: keterangan,
    );

    widget.saatDisimpan(targetBaru);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Atur Task Target Anggaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Nama Target
            const Text(
              'Nama Task Target',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolNama,
              decoration: InputDecoration(
                hintText: 'Contoh: Batas Belanja Mingguan / Target 500k',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.flag_outlined, color: Colors.teal),
              ),
            ),

            const SizedBox(height: 16),

            // Jumlah Target
            const Text(
              'Jumlah Target (Rp)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolJumlah,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '500000',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.teal),
              ),
            ),

            const SizedBox(height: 10),

            // Pilihan Cepat Jumlah
            Wrap(
              spacing: 8,
              children: _pilihanCepat.map((nilai) {
                return ActionChip(
                  label: Text(FormatUang.keFormatSingkat(nilai)),
                  backgroundColor: Colors.teal.shade50,
                  labelStyle: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  onPressed: () {
                    setState(() {
                      _pengontrolJumlah.text = nilai.toStringAsFixed(0);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Keterangan
            const Text(
              'Catatan Tambahan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolKeterangan,
              decoration: InputDecoration(
                hintText: 'Contoh: Agar tidak boros di akhir bulan',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.notes_rounded, color: Colors.teal),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _simpanPengaturanTarget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Target',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

