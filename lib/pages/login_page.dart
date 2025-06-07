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
  bool _isPasswordVisible = false;

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
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo and App Name
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Z',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Zello',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Welcome Text
                const Text(
                  'Make The\nFirst Move',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: emailController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D3748),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 16,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF718096),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D3748),
                          ),
                          validator: (value) =>
                              value!.length < 6 ? "Min. 6 karakter" : null,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor:
                                const Color(0xFFFF6B6B).withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF718096),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF718096),
                            ),
                            children: [
                              TextSpan(text: "Belum punya akun? "),
                              TextSpan(
                                text: "Register",
                                style: TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
