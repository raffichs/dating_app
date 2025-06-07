import 'package:final_tpm/core/currency_helper.dart';
import 'package:final_tpm/core/loc_helper.dart';
import 'package:final_tpm/services/timezone_service.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../core/hash_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final bioController = TextEditingController();
  final imageUrlController = TextEditingController();

  String selectedGender = 'Male';
  String selectedTimezone = 'WIB';
  String selectedCountry = 'Indonesia';
  String selectedCurrency = 'not set';
  String? currentLocation = '';

  final genderOptions = ['Male', 'Female', 'Other'];
  // final timezoneOptions = ['WIB', 'WITA', 'WIT', 'London'];
  // final currencyOptions = ['IDR', 'USD', 'EUR', 'JPY'];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    String location = await getCurrentLocationString();
    setState(() {
      selectedCountry = location; 
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
    bioController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final position = await getCurrentLatLng();
      final timezone = await TimezoneService.fetchTimezone(
            position.latitude,
            position.longitude,
          ) ??
          'UTC';
      final currency = await getUserCurrency();
      
      final newUser = UserModel(
        username: usernameController.text,
        email: emailController.text,
        password: HashHelper.hashPassword(
            passwordController.text), // nanti bisa di-encrypt
        gender: selectedGender,
        age: int.parse(ageController.text),
        timezone: timezone,
        country: selectedCountry,
        coverImageUrl: imageUrlController.text,
        currency: currency,
        bio: bioController.text,
        lat: position.latitude,
        lng: position.longitude,
      );

      bool success = await UserService.registerUser(newUser);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully!')),
        );
        Navigator.pop(context); // balik ke login
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
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
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: imageUrlController,
                decoration:
                    const InputDecoration(labelText: "Profile Image URL"),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 2,
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genderOptions
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => selectedGender = value!),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              // DropdownButtonFormField<String>(
              //   value: selectedTimezone,
              //   items: timezoneOptions
              //       .map((zone) =>
              //           DropdownMenuItem(value: zone, child: Text(zone)))
              //       .toList(),
              //   onChanged: (value) => setState(() => selectedTimezone = value!),
              //   decoration: const InputDecoration(labelText: "Timezone"),
              // ),
              // DropdownButtonFormField<String>(
              //   value: selectedCurrency,
              //   items: currencyOptions
              //       .map((currency) => DropdownMenuItem(
              //           value: currency, child: Text(currency)))
              //       .toList(),
              //   onChanged: (value) => setState(() => selectedCurrency = value!),
              //   decoration: const InputDecoration(labelText: "Currency"),
              // ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
