import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/notification/notifications_screen.dart';  
import 'screens/profile/profile_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course App Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Vous pouvez définir un thème de base ici, qui sera hérité
        // ou utilisé par les écrans s'ils n'ont pas leur propre thème.
        // Par exemple, le thème de la page de connexion :
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue.shade500),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600, // Couleur pour login/register
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue.shade600,
          ),
        ),
        // Si vous utilisez Google Fonts pour tout le texte :
        // textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),

      // Définir la route initiale
      initialRoute: '/login', // L'application commencera par l'écran de connexion

      // Définir toutes les routes nommées de votre application
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/': (context) => const HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        // Vous pouvez ajouter d'autres routes ici au fur et à mesure
        // Par exemple: '/course_details': (context) => CourseDetailsScreen(),
      },
    );
  }
}