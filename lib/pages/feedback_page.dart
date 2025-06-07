import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kesan & Pesan"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              "📝 Kesan:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Selama mengikuti mata kuliah Teknologi dan Pemrograman Mobile, saya merasa pembelajaran sangat relevan dengan perkembangan teknologi saat ini. Praktik menggunakan Flutter sangat membantu saya memahami pengembangan aplikasi mobile secara langsung.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              "📩 Pesan:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Semoga ke depannya materi bisa lebih terstruktur dan diberikan referensi project nyata sebagai studi kasus. Terima kasih untuk ilmu dan bimbingannya selama ini, Pak/Bu 🙏",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
