import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Optionnel, pour un meilleur style de police
import 'pages/home/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course App UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange, // Une couleur proche du rouge/orange de l'UI
        scaffoldBackgroundColor: const Color(0xFFFDFDFD), // Fond très clair
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme), // Police Poppins
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}