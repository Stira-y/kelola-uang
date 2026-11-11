import 'package:flutter/material.dart';
import '../model/model_target.dart';
import '../model/model_estimasi_target.dart';
import '../utilitas/format_uang.dart';

/// Komponen visual kartu Target Belanja dengan estimasi pencapaian dinamis
class KartuTaskTarget extends StatelessWidget {
  final ModelTarget? taskTarget;
  final ModelEstimasiTarget? estimasi;
  final VoidCallback saatDitekanBuatTarget;
  final VoidCallback saatDitekanUbahTarget;
  final VoidCallback saatDitekanHapusTarget;
  final VoidCallback saatDitekanHitungUlang;

  const KartuTaskTarget({
    super.key,
    required this.taskTarget,
    required this.estimasi,
    required this.saatDitekanBuatTarget,
    required this.saatDitekanUbahTarget,
    required this.saatDitekanHapusTarget,
    required this.saatDitekanHitungUlang,
  });

  @override
  Widget build(BuildContext context) {
    // 1. JIKA BELUM ADA TARGET: Tampilkan tombol untuk membuat target belanja
    if (taskTarget == null || estimasi == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.teal.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag_rounded, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Belanja',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Belum ada target yang disetel. Buat target untuk memantau waktu pencapaiannya.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: saatDitekanBuatTarget,
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text('Buat Target Belanja'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. JIKA TARGET SUDAH ADA: Tampilkan kartu detail & estimasi
    final target = taskTarget!;
    final est = estimasi!;

    final String namaPeriode = target.tipePeriode == TipePeriodeTarget.harian
        ? 'Hari'
        : (target.tipePeriode == TipePeriodeTarget.mingguan ? 'Minggu' : 'Bulan');

    final int angkaPersen = (est.persentasePencapaian * 100).toInt();

    Color warnaStatus = Colors.teal;
    if (est.apakahSudahTercapai) {
      warnaStatus = Colors.green;
    } else if (est.apakahArusKasNegatif) {
      warnaStatus = Colors.redAccent;
    } else if (est.lajuEfektifAktual < target.pendapatanTetap) {
      warnaStatus = Colors.orange.shade700;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flag_rounded, color: Colors.teal, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.namaTarget,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Target: ${FormatUang.keRupiah(target.jumlahTarget)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.teal),
                    tooltip: 'Ubah Target',
                    onPressed: saatDitekanUbahTarget,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                    tooltip: 'Hapus Target',
                    onPressed: saatDitekanHapusTarget,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Rasio Uang Saya / Target
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terkumpul / Target',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: FormatUang.keFormatSingkat(est.totalUangSaatIni),
                                style: TextStyle(
                                  color: est.apakahSudahTercapai ? Colors.green.shade700 : Colors.teal.shade800,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: ' / ',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              TextSpan(
                                text: FormatUang.keFormatSingkat(target.jumlahTarget),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: warnaStatus.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$angkaPersen%',
                        style: TextStyle(
                          color: warnaStatus,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: est.persentasePencapaian,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(warnaStatus),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Rincian Pendapatan Tetap & Estimasi Waktu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warnaStatus.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: warnaStatus.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pendapatan Tetap: ${FormatUang.keFormatSingkat(target.pendapatanTetap)}/$namaPeriode',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    InkWell(
                      onTap: saatDitekanHitungUlang,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 14, color: warnaStatus),
                            const SizedBox(width: 4),
                            Text(
                              'Hitung Ulang',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: warnaStatus,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Baris Info Estimasi
                if (est.apakahSudahTercapai) ...[
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Target telah tercapai! Dana kamu sudah mencukupi.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (est.apakahArusKasNegatif) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pengeluaran melebihi pendapatan di periode ini! Target tertunda hingga ada tabungan bersih.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(Icons.hourglass_bottom_rounded, size: 15, color: warnaStatus),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Sisa ${FormatUang.keRupiah(est.sisaKebutuhanUang)} • Perlu ~${est.estimasiMingguDinamis?.toStringAsFixed(1) ?? '0'} Minggu (~${est.estimasiBulanDinamis?.toStringAsFixed(1) ?? '0'} Bulan)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 6),
                Text(
                  est.statusPenjelasan,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
