import 'package:final_tpm/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String gender = '';
  String country = '';
  String timezone = '';
  int age = 0;
  String currency = '';
  String bio = '';
  String coverImageUrl = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'not set';
      email = prefs.getString('email') ?? 'not set';
      gender = prefs.getString('gender') ?? 'not set';
      country = prefs.getString('country') ?? 'not set';
      timezone = prefs.getString('timezone') ?? 'not set';
      age = prefs.getInt('age') ?? 0;
      currency = prefs.getString('currency') ?? 'not set';
      coverImageUrl =
          prefs.getString('coverImageUrl') ?? 'assets/images/avatar.jpg';
      bio = prefs.getString('bio') ?? 'not set';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(coverImageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            InfoTile(title: 'Age', value: '$age'),
            InfoTile(title: 'Gender', value: gender),
            InfoTile(title: 'Location', value: country),
            InfoTile(title: 'Timezone', value: timezone),
            InfoTile(title: 'Currency', value: currency),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text(
              bio,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
