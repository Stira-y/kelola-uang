import 'package:flutter/material.dart';
import '../model/model_target.dart';
import '../utilitas/format_uang.dart';

/// Lembar bawah untuk membuat atau mengubah Target Belanja
/// Disertai estimasi otomatis pencapaian berdasarkan pendapatan tetap
class LayarAturTarget extends StatefulWidget {
  final ModelTarget? targetSaatIni;
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
  late TextEditingController _pengontrolJumlahTarget;
  late TextEditingController _pengontrolPendapatanTetap;
  late TextEditingController _pengontrolKeterangan;

  TipePeriodeTarget _tipePeriodeDipilih = TipePeriodeTarget.mingguan;

  // Preset jumlah target cepat
  final List<double> _presetTarget = [200000, 300000, 500000, 1000000, 2000000];
  // Preset pendapatan cepat
  final List<double> _presetPendapatan = [20000, 50000, 100000, 250000, 500000];

  @override
  void initState() {
    super.initState();
    final t = widget.targetSaatIni;
    _pengontrolNama = TextEditingController(text: t?.namaTarget ?? 'Target Belanja');
    _pengontrolJumlahTarget = TextEditingController(
      text: t != null ? t.jumlahTarget.toStringAsFixed(0) : '500000',
    );
    _tipePeriodeDipilih = t?.tipePeriode ?? TipePeriodeTarget.mingguan;
    _pengontrolPendapatanTetap = TextEditingController(
      text: t != null ? t.pendapatanTetap.toStringAsFixed(0) : '50000',
    );
    _pengontrolKeterangan = TextEditingController(text: t?.keteranganTarget ?? '');
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolJumlahTarget.dispose();
    _pengontrolPendapatanTetap.dispose();
    _pengontrolKeterangan.dispose();
    super.dispose();
  }

  /// Menghitung estimasi awal untuk ditampilkan sebagai pratinjau langsung
  String _hitungPratinjauEstimasi() {
    final double? target = FormatUang.uraikanNominal(_pengontrolJumlahTarget.text.trim());
    final double? pendapatan = FormatUang.uraikanNominal(_pengontrolPendapatanTetap.text.trim());

    if (target == null || target <= 0 || pendapatan == null || pendapatan <= 0) {
      return 'Masukkan nominal target dan pendapatan yang valid (bisa ketik misal: 500k atau 500.000).';
    }

    double lajuMingguan = pendapatan;
    if (_tipePeriodeDipilih == TipePeriodeTarget.harian) {
      lajuMingguan = pendapatan * 7;
    } else if (_tipePeriodeDipilih == TipePeriodeTarget.bulanan) {
      lajuMingguan = pendapatan / 4.33;
    }

    final double minggu = target / lajuMingguan;
    final double bulan = minggu / 4.33;

    final String namaPeriode = _tipePeriodeDipilih == TipePeriodeTarget.harian
        ? 'hari'
        : (_tipePeriodeDipilih == TipePeriodeTarget.mingguan ? 'minggu' : 'bulan');

    return 'Dengan pendapatan ${FormatUang.keFormatTitik(pendapatan)}/$namaPeriode, kamu memerlukan sekitar ${minggu.toStringAsFixed(1)} minggu (~${bulan.toStringAsFixed(1)} bulan) untuk mencapai target ${FormatUang.keRupiah(target)}.';
  }

  void _simpan() {
    final String nama = _pengontrolNama.text.trim();
    final double? jumlahTarget = FormatUang.uraikanNominal(_pengontrolJumlahTarget.text.trim());
    final double? pendapatan = FormatUang.uraikanNominal(_pengontrolPendapatanTetap.text.trim());

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama target belanja tidak boleh kosong')),
      );
      return;
    }

    if (jumlahTarget == null || jumlahTarget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal target harus lebih dari 0')),
      );
      return;
    }

    if (pendapatan == null || pendapatan <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal pendapatan tetap harus lebih dari 0')),
      );
      return;
    }

    final targetBaru = ModelTarget(
      namaTarget: nama,
      jumlahTarget: jumlahTarget,
      tipePeriode: _tipePeriodeDipilih,
      pendapatanTetap: pendapatan,
      keteranganTarget: _pengontrolKeterangan.text.trim(),
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.targetSaatIni == null ? 'Buat Target Belanja' : 'Ubah Target Belanja',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Nama Target
            const Text(
              'Nama Target Belanja',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolNama,
              decoration: InputDecoration(
                hintText: 'Contoh: Beli Sepatu / Target 500k',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.flag_rounded, color: Colors.teal),
              ),
            ),

            const SizedBox(height: 14),

            // Jumlah Target
            const Text(
              'Nominal Target Belanja (Rp)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolJumlahTarget,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Contoh: 500000',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.monetization_on_rounded, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _presetTarget.map((nilai) {
                return ActionChip(
                  label: Text(FormatUang.keFormatSingkat(nilai)),
                  backgroundColor: Colors.teal.shade50,
                  labelStyle: const TextStyle(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.w600),
                  onPressed: () {
                    setState(() {
                      _pengontrolJumlahTarget.text = nilai.toStringAsFixed(0);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Frekuensi Pendapatan Tetap
            const Text(
              'Frekuensi Pendapatan Tetap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Harian')),
                    selected: _tipePeriodeDipilih == TipePeriodeTarget.harian,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: _tipePeriodeDipilih == TipePeriodeTarget.harian ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (terpilih) {
                      if (terpilih) setState(() => _tipePeriodeDipilih = TipePeriodeTarget.harian);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Mingguan')),
                    selected: _tipePeriodeDipilih == TipePeriodeTarget.mingguan,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: _tipePeriodeDipilih == TipePeriodeTarget.mingguan ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (terpilih) {
                      if (terpilih) setState(() => _tipePeriodeDipilih = TipePeriodeTarget.mingguan);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Bulanan')),
                    selected: _tipePeriodeDipilih == TipePeriodeTarget.bulanan,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: _tipePeriodeDipilih == TipePeriodeTarget.bulanan ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (terpilih) {
                      if (terpilih) setState(() => _tipePeriodeDipilih = TipePeriodeTarget.bulanan);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Nominal Pendapatan Tetap
            Text(
              'Nominal Pendapatan Tetap (${_tipePeriodeDipilih == TipePeriodeTarget.harian ? 'per Hari' : (_tipePeriodeDipilih == TipePeriodeTarget.mingguan ? 'per Minggu' : 'per Bulan')})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolPendapatanTetap,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Contoh: 50000',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.savings_rounded, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _presetPendapatan.map((nilai) {
                return ActionChip(
                  label: Text(FormatUang.keFormatSingkat(nilai)),
                  backgroundColor: Colors.teal.shade50,
                  labelStyle: const TextStyle(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.w600),
                  onPressed: () {
                    setState(() {
                      _pengontrolPendapatanTetap.text = nilai.toStringAsFixed(0);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Kotak Pratinjau Estimasi Otomatis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calculate_rounded, color: Colors.teal, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimasi Pencapaian Otomatis',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _hitungPratinjauEstimasi(),
                          style: TextStyle(fontSize: 12, color: Colors.teal.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Catatan
            const Text(
              'Catatan / Keterangan (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _pengontrolKeterangan,
              decoration: InputDecoration(
                hintText: 'Contoh: Alokasi uang saku setiap minggu',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.notes_rounded, color: Colors.teal),
              ),
            ),

            const SizedBox(height: 22),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Target Belanja', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
