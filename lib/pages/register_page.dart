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
  final PageController _pageController = PageController();
  int currentStep = 0;
  final int totalSteps = 6;

  // Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final bioController = TextEditingController();
  final imageUrlController = TextEditingController();

  String selectedGender = 'Male';
  String selectedCountry = 'Indonesia';
  bool _isPasswordVisible = false;
  bool _isRegistering = false;

  final genderOptions = ['Male', 'Female', 'Other'];

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
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (currentStep < totalSteps - 1) {
        setState(() => currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _register();
      }
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        if (usernameController.text.trim().isEmpty) {
          _showError("Name is required");
          return false;
        }
        return true;
      case 1:
        if (emailController.text.trim().isEmpty) {
          _showError("Email is required");
          return false;
        }
        return true;
      case 2:
        if (passwordController.text.length < 6) {
          _showError("Password must be at least 6 characters");
          return false;
        }
        return true;
      case 3:
        if (ageController.text.trim().isEmpty || int.tryParse(ageController.text) == null) {
          _showError("Valid age is required");
          return false;
        }
        return true;
      case 4:
        if (imageUrlController.text.trim().isEmpty) {
          _showError("Profile image URL is required");
          return false;
        }
        return true;
      case 5:
        return true; // Bio is optional
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() => _isRegistering = true);
    
    try {
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
        password: HashHelper.hashPassword(passwordController.text),
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
          SnackBar(
            content: const Text('Registered successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        _showError('Registration failed!');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: $e');
    }
    
    setState(() => _isRegistering = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (currentStep > 0)
                    GestureDetector(
                      onTap: _previousStep,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2D3748),
                          size: 20,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${currentStep + 1} of $totalSteps',
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: currentStep > 0 ? 40 : 0),
                ],
              ),
            ),
            
            // Progress Indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentStep + 1) / totalSteps,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNameStep(),
                  _buildEmailStep(),
                  _buildPasswordStep(),
                  _buildAgeStep(),
                  _buildImageStep(),
                  _buildBioStep(),
                ],
              ),
            ),
            
            // Continue Button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: const Color(0xFFFF6B6B).withOpacity(0.6),
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          currentStep == totalSteps - 1 ? "Create Account" : "Continue",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget inputField,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Title matching login page style
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Input field
            inputField,
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 16,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines > 1 ? 20 : 0,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: const InputDecoration(
          labelText: "Gender",
          labelStyle: TextStyle(
            color: Color(0xFF718096),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D3748),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF718096),
        ),
        items: genderOptions
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedGender = value!),
      ),
    );
  }

  Widget _buildNameStep() {
    return _buildStepContainer(
      title: "What's your\nfirst name?",
      subtitle: "You won't be able to change this later.",
      inputField: _buildInputField(
        controller: usernameController,
        hintText: "Name",
      ),
    );
  }

  Widget _buildEmailStep() {
    return _buildStepContainer(
      title: "What's your\nemail?",
      subtitle: "We'll use this to keep your account secure.",
      inputField: _buildInputField(
        controller: emailController,
        hintText: "Email",
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPasswordStep() {
    return _buildStepContainer(
      title: "Create a\npassword",
      subtitle: "Must be at least 6 characters long.",
      inputField: _buildInputField(
        controller: passwordController,
        hintText: "Password",
        obscureText: !_isPasswordVisible,
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
    );
  }

  Widget _buildAgeStep() {
    return _buildStepContainer(
      title: "How old\nare you?",
      subtitle: "This helps us show you age-appropriate matches.",
      inputField: _buildInputField(
        controller: ageController,
        hintText: "Age",
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildImageStep() {
    return _buildStepContainer(
      title: "Add your best\nphoto",
      subtitle: "Share a photo URL that represents you well.",
      inputField: _buildInputField(
        controller: imageUrlController,
        hintText: "Profile Image URL",
      ),
    );
  }

  Widget _buildBioStep() {
    return _buildStepContainer(
      title: "Tell us about\nyourself",
      subtitle: "Write a short bio and select your gender.",
      inputField: Column(
        children: [
          _buildInputField(
            controller: bioController,
            hintText: "Bio (optional)",
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(),
        ],
      ),
    );
  }
}