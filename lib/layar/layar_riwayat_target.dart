import 'package:flutter/material.dart';
import '../model/model_target_tercapai.dart';
import '../layanan/layanan_penyimpanan.dart';
import '../utilitas/format_uang.dart';

/// Lembar tampilan daftar target belanja yang telah berhasil dicapai
class LayarRiwayatTarget extends StatefulWidget {
  final VoidCallback? saatDataBerubah;

  const LayarRiwayatTarget({super.key, this.saatDataBerubah});

  @override
  State<LayarRiwayatTarget> createState() => _LayarRiwayatTargetState();
}

class _LayarRiwayatTargetState extends State<LayarRiwayatTarget> {
  final LayananPenyimpanan _layananPenyimpanan = LayananPenyimpanan();
  List<ModelTargetTercapai> _daftarTercapai = [];
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final data = await _layananPenyimpanan.ambilSemuaTargetTercapai();
    if (mounted) {
      setState(() {
        _daftarTercapai = data;
        _sedangMemuat = false;
      });
    }
  }

  Future<void> _hapusTarget(String idTarget) async {
    await _layananPenyimpanan.hapusRiwayatTargetTercapai(idTarget);
    await _muatData();
    widget.saatDataBerubah?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat target berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.teal, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Riwayat Target Belanja',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          if (_sedangMemuat)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.teal)))
          else if (_daftarTercapai.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      'Belum ada target yang disimpan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketika target belanja kamu terpenuhi, kamu bisa menyimpannya ke daftar ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _daftarTercapai.length,
                itemBuilder: (konteks, indeks) {
                  final item = _daftarTercapai[indeks];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.namaTarget,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nominal: ${FormatUang.keRupiah(item.jumlahTarget)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tercapai pada: ${FormatUang.keTanggalLengkap(item.tanggalTercapai)}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                          tooltip: 'Hapus Riwayat',
                          onPressed: () => _hapusTarget(item.idTarget),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

