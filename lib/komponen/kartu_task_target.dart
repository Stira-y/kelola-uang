import 'package:flutter/material.dart';
import '../model/model_target.dart';
import '../utilitas/format_uang.dart';

/// Komponen visual kartu task target anggaran
/// Menampilkan perbandingan Uang Saya / Target (misalnya: 350k / 500k)
class KartuTaskTarget extends StatelessWidget {
  final double totalUangSaya;
  final ModelTarget taskTarget;
  final VoidCallback saatDitekanAturTarget;

  const KartuTaskTarget({
    super.key,
    required this.totalUangSaya,
    required this.taskTarget,
    required this.saatDitekanAturTarget,
  });

  @override
  Widget build(BuildContext context) {
    final double jumlahTarget = taskTarget.jumlahTarget;
    // Perhitungan rasio persentase
    final double persentase = jumlahTarget > 0
        ? (totalUangSaya / jumlahTarget).clamp(0.0, 1.0)
        : 0.0;
    final int angkaPersen = (persentase * 100).toInt();

    // Warna indikator kemajuan
    Color warnaProgres;
    String statusTeks;
    IconData ikonStatus;

    if (totalUangSaya >= jumlahTarget) {
      warnaProgres = Colors.green;
      statusTeks = 'Target Tercapai! Uang cukup';
      ikonStatus = Icons.check_circle_rounded;
    } else if (totalUangSaya >= jumlahTarget * 0.5) {
      warnaProgres = Colors.amber.shade700;
      statusTeks = 'Sedang Berjalan (${FormatUang.keRupiah(jumlahTarget - totalUangSaya)} lagi)';
      ikonStatus = Icons.timelapse_rounded;
    } else {
      warnaProgres = Colors.orangeAccent;
      statusTeks = 'Masih kurang ${FormatUang.keRupiah(jumlahTarget - totalUangSaya)}';
      ikonStatus = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskTarget.namaTarget,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Target: ${FormatUang.keFormatSingkat(jumlahTarget)} (${FormatUang.keRupiah(jumlahTarget)})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20, color: Colors.teal),
                tooltip: 'Ubah Target',
                onPressed: saatDitekanAturTarget,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Angka Perhitungan: Uang Saya / Target (Contoh: 350k / 500k)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perhitungan Rasio Task',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: FormatUang.keFormatSingkat(totalUangSaya),
                            style: TextStyle(
                              color: totalUangSaya >= jumlahTarget
                                  ? Colors.green.shade700
                                  : Colors.teal.shade700,
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text: ' / ',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          TextSpan(
                            text: FormatUang.keFormatSingkat(jumlahTarget),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: warnaProgres.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$angkaPersen%',
                    style: TextStyle(
                      color: warnaProgres,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bilah Kemajuan (Progress Bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: persentase,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(warnaProgres),
            ),
          ),

          const SizedBox(height: 8),

          // Status & Keterangan
          Row(
            children: [
              Icon(ikonStatus, size: 14, color: warnaProgres),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusTeks,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

