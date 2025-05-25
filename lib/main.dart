import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart'; // Assurez-vous que ce fichier existe
import 'screens/home/home_screen.dart';
import 'screens/notification/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/quiz/quiz_list_screen.dart'; // Nouvelle importation
import 'utils/app_colors.dart'; // Importation des couleurs

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'EduLearn App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: eduLearnPrimary,
        scaffoldBackgroundColor: eduLearnBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: eduLearnPrimary,
          primary: eduLearnPrimary,
          secondary: eduLearnAccent,
          error: eduLearnError,
          background: eduLearnBackground,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
          displayLarge: GoogleFonts.poppins(textStyle: baseTextTheme.displayLarge, fontWeight: FontWeight.bold),
          // Ajustez d'autres styles si nécessaire
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: eduLearnBackground,
          elevation: 0,
          iconTheme: const IconThemeData(color: eduLearnTextBlack),
          titleTextStyle: GoogleFonts.poppins(
              color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: eduLearnAccent.withOpacity(0.5), // Un peu plus transparent
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            borderSide: BorderSide.none, // Pas de bordure par défaut si filled
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            borderSide: BorderSide(color: eduLearnPrimary.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            borderSide: const BorderSide(color: eduLearnPrimary, width: 1.5),
          ),
          labelStyle: const TextStyle(color: eduLearnTextGrey),
          hintStyle: const TextStyle(color: eduLearnTextLightGrey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: eduLearnPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            ),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: eduLearnPrimary,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500)
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: eduLearnAccent,
          labelStyle: const TextStyle(color: eduLearnPrimary, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: eduLearnPrimary.withOpacity(0.3), width: 0.5)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        )
      ),
      initialRoute: '/login', // Route initiale
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), // À créer ou utiliser le tien
        '/': (context) => HomeScreen(), // Route principale après login
        '/profile': (context) => ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/quiz_list': (context) => const QuizListScreen(), // Route pour la liste des quiz
        // '/course_details': (context) => CourseDetailsScreen(course: DUMMY_COURSE), // Gérer le passage d'argument
        // '/chapter_view': (context) => ChapterViewScreen(...), // Gérer le passage d'argument
      },
      // onGenerateRoute: (settings) { // Pour passer des arguments aux routes nommées dynamiquement
      //   if (settings.name == '/course_details') {
      //     final args = settings.arguments as CourseModel; // Example
      //     return MaterialPageRoute(builder: (context) => CourseDetailsScreen(course: args));
      //   }
      //   // Handle other routes
      //   return null; // Let routes handle it or return an error page
      // },
    );
  }
}