import 'package:flutter/material.dart';
import '../../utils/app_colors.dart'; // Importation des couleurs
// Importer les modèles Level et Speciality si vous voulez les utiliser dans des dropdowns
// import '../../models/level_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  // Potentiellement des contrôleurs pour dob, level, speciality
  // LevelModel? _selectedLevel;
  // SpecialityModel? _selectedSpeciality;
  // List<LevelModel> _levels = []; // À charger depuis une API
  // List<SpecialityModel> _specialities = []; // À charger en fonction du niveau

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implémenter la logique d'enregistrement
      // Utiliser les données des contrôleurs:
      // String fullName = _fullNameController.text;
      // String userName = _userNameController.text;
      // String email = _emailController.text;
      // String password = _passwordController.text;
      // ... et potentiellement level, speciality, dob

      // Simuler une inscription réussie
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie ! Vous pouvez vous connecter.'), backgroundColor: eduLearnSuccess),
      );
      Navigator.pop(context); // Retour à l'écran de connexion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: eduLearnTextBlack),
        titleTextStyle: const TextStyle(color: eduLearnTextBlack, fontSize: 20, fontWeight: FontWeight.bold),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 120, // Plus petite illustration pour l'inscription
                  child: Image.asset(
                    'assets/register_illustration.png', // Créez ou trouvez un asset
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.person_add_alt_1_outlined, size: 80, color: eduLearnPrimary),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.badge_outlined, color: eduLearnPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your full name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle_outlined, color: eduLearnPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a username';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: eduLearnPrimary),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: eduLearnPrimary),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: eduLearnPrimary),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: eduLearnPrimary),
                     suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: eduLearnPrimary),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                // TODO: Ajouter des champs pour Date of Birth, Level, Speciality (avec DropdownButtonFormField)
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Already have an account? ", style: TextStyle(color: eduLearnTextGrey)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}