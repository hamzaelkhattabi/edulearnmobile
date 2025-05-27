// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../providers/auth_provider.dart'; // <<=== ASSUREZ-VOUS D'IMPORTER VOTRE AUTHPROVIDER

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text;
        final password = _passwordController.text;

        // Appel au service d'authentification
        final authData = await _authService.login(email, password);
        final UserModel user = authData['user'];
        final String token = authData['token'];

        if (mounted) {
          // Mettre à jour l'état global d'authentification via le Provider
          Provider.of<AuthProvider>(context, listen: false).loginSuccess(user, token);
          print("DEBUG: isAuthenticated = ${Provider.of<AuthProvider>(context, listen: false).isAuthenticated}");


          // Le SnackBar est optionnel ici, car l'écran va changer.
          // Vous pourriez vouloir afficher le message de bienvenue sur HomeScreen.
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text('Connexion réussie ! Bonjour ${user.prenom ?? user.nomUtilisateur}'),
          //       backgroundColor: eduLearnSuccess),
          // );

          // PAS DE NAVIGATION EXPLICITE ICI.
          // Le Consumer<AuthProvider> dans main.dart gérera la redirection vers HomeScreen
          // en réponse à la mise à jour de l'état d'authentification.
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().replaceFirst("Exception: ", "")), // Affiche le message d'erreur de l'API
                backgroundColor: eduLearnError),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc spécifique pour cet écran
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 180, // Ajustez si nécessaire
                child: Image.asset(
                  'assets/profile_avatar.png', // Assurez-vous que cet asset existe et est déclaré dans pubspec.yaml
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Affiche une icône en cas d'erreur de chargement de l'image
                    print("Erreur chargement image login: $error"); // Pour le débogage
                    return const Center(
                      child: Icon(Icons.school_outlined, size: 100, color: eduLearnPrimary),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: eduLearnTextBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter valid email & password to continue',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: eduLearnTextGrey,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration( // Le thème global d'InputDecoration s'appliquera
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined), // La couleur sera gérée par le thème prefixIconColor
                      ),
                      style: const TextStyle(color: eduLearnTextBlack),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            // La couleur de l'icône suffixe est généralement gérée par iconTheme ou est la couleur d'accentuation
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: eduLearnTextBlack),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                    // TODO: Implémenter la logique de mot de passe oublié (appel API, etc.)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password functionality not implemented.')),
                    );
                  },
                  // style: TextButton.styleFrom(padding: EdgeInsets.zero), // Pour enlever le padding si nécessaire
                  child: const Text(
                    'Forget password?',
                    // Le style est géré par TextButtonThemeData ou hérité,
                    // mais vous pouvez le surcharger si besoin :
                    // style: TextStyle(color: eduLearnPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: eduLearnPrimary))
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'), // Le style est géré par ElevatedButtonThemeData
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Haven't any account? ",
                    style: TextStyle(color: eduLearnTextGrey),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushNamed(context, '/register'); // Assurez-vous que cette route existe
                    },
                    child: const Text(
                      'Sign up',
                      // Le style est géré par TextButtonThemeData,
                      // ou vous pouvez forcer la couleur ici :
                      // style: TextStyle(color: eduLearnPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}