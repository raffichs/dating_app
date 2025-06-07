import 'package:final_tpm/core/hash_helper.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../screens/main_screen.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      List<UserModel> users = await UserService.fetchAllUsers();
      final email = emailController.text.trim();
      final hashedInput = HashHelper.hashPassword(passwordController.text);

      final user = users.firstWhere(
        (u) => u.email == email && u.password == hashedInput,
        orElse: () => UserModel.empty(),
      );

      if (user.id != null) {
        // Login sukses, navigasi ke MainScreen
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', user.id!);
        prefs.setString('username', user.username);
        prefs.setString('email', user.email);
        prefs.setString('gender', user.gender);
        prefs.setInt('age', user.age);
        prefs.setString('country', user.country);
        prefs.setString('timezone', user.timezone);
        prefs.setString('currency', user.currency);
        prefs.setString('coverImageUrl', user.coverImageUrl);
        prefs.setString('bio', user.bio);
        prefs.setDouble('lat', user.lat);
        prefs.setDouble('lng', user.lng);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        _showError("Email atau password salah");
      }
    } catch (e) {
      _showError("Gagal login: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: "Email / Username"),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "Min. 6 karakter" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text("Belum punya akun? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
