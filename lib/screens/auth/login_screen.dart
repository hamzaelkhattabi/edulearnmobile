import 'package:flutter/material.dart';
import '../../utils/app_colors.dart'; // Importation des couleurs

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Vérification simple des identifiants
      // TODO: Remplacer par une vraie logique d'authentification
      if (username == 'hamza@gmail.com' && password == 'hamza123') {
        Navigator.pushReplacementNamed(context, '/'); // Naviguer vers HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie !'), backgroundColor: eduLearnSuccess),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identifiants incorrects'), backgroundColor: eduLearnError),
        );
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
                height: 180,
                child: Image.asset(
                  'assets/login_illustration.png', // Assurez-vous que cet asset existe
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
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
                'Enter valid user name & password to continue',
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'User name (email)',
                        prefixIcon: const Icon(Icons.person_outline, color: eduLearnPrimary),
                        // Utilise le thème global pour le style
                      ),
                      style: const TextStyle(color: eduLearnTextBlack),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your user name';
                        }
                        if (!value.contains('@')) {
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
                        prefixIcon: const Icon(Icons.lock_outline, color: eduLearnPrimary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: eduLearnPrimary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        // Utilise le thème global pour le style
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
                  onPressed: () {
                    // TODO: Logique mot de passe oublié
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password functionality not implemented.')),
                    );
                  },
                  child: const Text(
                    'Forget password?',
                    style: TextStyle(color: eduLearnPrimary), // Style direct pour ce TextButton spécifique
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // Style via ElevatedButtonTheme
                onPressed: _login,
                child: const Text('Login'),
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
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Sign up',
                      // Style via TextButtonTheme, mais peut être surchargé
                      // style: TextStyle(color: eduLearnPrimary),
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