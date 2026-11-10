import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'layar/layar_utama.dart';

void main() async {
  // Pastikan binding Flutter telah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal dan waktu untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const AplikasiKelolaUang());
}

/// Widget utama aplikasi
class AplikasiKelolaUang extends StatelessWidget {
  const AplikasiKelolaUang({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelola Uang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.tealAccent.shade700,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const LayarUtama(),
    );
  }
}
