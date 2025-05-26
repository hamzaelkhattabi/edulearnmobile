// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Pour le formatage des dates en FR

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/notification/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/quiz/quiz_list_screen.dart';
import 'screens/courses/course_details_screen.dart';
import 'screens/courses/chapter_view_screen.dart'; // ou lesson_view_screen.dart

import 'models/course_model.dart'; // Pour onGenerateRoute
import 'models/lesson_model.dart'; // Pour onGenerateRoute

import 'utils/app_colors.dart'; // Vos couleurs
import 'utils/api_constants.dart'; // Vos constantes (KDefaultBorderRadius y est défini implicitement par usage)


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important si vous faites des appels asynchrones avant runApp
  await initializeDateFormatting('fr_FR', null); // Initialiser les locales pour intl

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Vous pouvez ajouter d'autres providers globaux ici si nécessaire
        // Exemple: Provider(create: (_) => CourseService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = Theme.of(context).textTheme;

    // Votre ThemeData défini
    final ThemeData eduLearnTheme = ThemeData(
      primaryColor: eduLearnPrimary,
      scaffoldBackgroundColor: eduLearnBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: eduLearnPrimary,
        primary: eduLearnPrimary,
        secondary: eduLearnAccent,
        error: eduLearnError,
        background: eduLearnBackground,
        // Assurez-vous d'avoir des couleurs pour les messages d'information/warning si utilisé
        // info: eduLearnInfo (ex: Colors.blue),
        // onInfo: Colors.white,
        // warning: eduLearnWarning (ex: Colors.orange),
        // onWarning: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.poppins(textStyle: baseTextTheme.displayLarge, fontWeight: FontWeight.bold),
        // Définissez d'autres styles globaux pour la cohérence
        titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: eduLearnTextBlack), // Pour titres importants
        titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: eduLearnTextBlack), // Pour sous-titres
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: eduLearnTextBlack),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: eduLearnTextGrey),
        labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white), // Pour texte sur ElevatedButton
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: eduLearnBackground, // Ou eduLearnCardBg si vous préférez les AppBar blanches
        elevation: 0, // Ou 0.5 si vous voulez une petite ombre
        iconTheme: const IconThemeData(color: eduLearnTextBlack),
        titleTextStyle: GoogleFonts.poppins(
            color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18),
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: eduLearnAccent.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Ajusté padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius), // kDefaultBorderRadius doit être défini
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: BorderSide(color: eduLearnPrimary.withOpacity(0.3)), // Un peu plus visible
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: const BorderSide(color: eduLearnPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder( // Style pour l'erreur
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: const BorderSide(color: eduLearnError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder( // Style pour l'erreur avec focus
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          borderSide: const BorderSide(color: eduLearnError, width: 2.0),
        ),
        labelStyle: const TextStyle(color: eduLearnTextGrey),
        hintStyle: const TextStyle(color: eduLearnTextLightGrey),
        prefixIconColor: eduLearnPrimary, // Couleur par défaut pour les icônes préfixées
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
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15) // Taille de police par défaut
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: eduLearnAccent.withOpacity(0.7),
        labelStyle: const TextStyle(color: eduLearnPrimary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: eduLearnPrimary.withOpacity(0.3), width: 0.8) // Bordure un peu plus visible
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Plus de padding vertical
        selectedColor: eduLearnPrimary.withOpacity(0.2), // Pour la sélection des ChoiceChip
      ),
      cardTheme: CardThemeData( // Thème global pour les cartes
        elevation: 2.0,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
        color: eduLearnCardBg, // Couleur de fond par défaut pour les cartes
      ),
      // Vous pouvez ajouter kDefaultBorderRadius ici si vous le voulez accessible via Theme.of(context)
      // extensions: <ThemeExtension<dynamic>>[
      //   const MyThemeExtensions(defaultBorderRadius: 12.0),
      // ],
    );

    return MaterialApp(
      title: 'EduLearn App',
      debugShowCheckedModeBanner: false,
      theme: eduLearnTheme, // Appliquer le thème défini
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, child) {
          // Si l'auto-login n'a pas encore été tenté, montrer un écran de chargement.
          // tryAutoLogin est appelé dans FutureBuilder pour s'assurer qu'il est appelé une seule fois.
          if (!auth.isAuthAttempted) {
            return FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (context, snapshot) {
                // Pendant que tryAutoLogin s'exécute (appel API pour getMe peut prendre du temps)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: eduLearnBackground,
                    body: Center(child: CircularProgressIndicator(color: eduLearnPrimary)),
                  );
                }
                // Une fois que tryAutoLogin est terminé, l'état de `auth` aura été mis à jour.
                // On peut alors vérifier `auth.isAuthenticated`.
                // Cette partie sera atteinte une fois après que tryAutoLogin soit complet.
                //print("FutureBuilder pour tryAutoLogin terminé. Auth state: ${auth.isAuthenticated}");
                return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
              },
            );
          } else {
            // Si tryAutoLogin a déjà été tenté (ex: après login/logout manuel),
            // on utilise directement l'état actuel d'authentification.
            //print("isAuthAttempted est true. Auth state: ${auth.isAuthenticated}");
            return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), // Assurez-vous qu'il existe
        '/home': (context) => const HomeScreen(), // Nommer explicitement pour la clarté
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/quiz_list': (context) => const QuizListScreen(), // Par défaut, liste tous les quiz
        // Note: '/course_details' et '/chapter_view' sont mieux gérés via onGenerateRoute
        // pour passer des arguments complexes proprement.
      },
      onGenerateRoute: (settings) {
        print("onGenerateRoute: Navigating to ${settings.name}");
        if (settings.name == '/course_details') {
          final args = settings.arguments;
          if (args is CourseModel) {
            return MaterialPageRoute(
              builder: (context) => CourseDetailsScreen(courseInput: args),
              settings: settings, // Important pour la navigation de retour
            );
          } else if (args is int) { // Si vous passez seulement l'ID
             // Dans ce cas, CourseDetailsScreen devra fetcher le cours lui-même
             // return MaterialPageRoute(builder: (context) => CourseDetailsScreen(courseId: args), settings: settings);
             print("Error: /course_details attendait CourseModel mais a reçu un int. Gérer ce cas.");
          }
          // Erreur: argument incorrect pour /course_details
          return _errorRoute(settings.name);
        }

        if (settings.name == '/chapter_view' || settings.name == '/lesson_view') {
           final args = settings.arguments;
           if (args is Map<String, dynamic>) { // Attendre une Map pour les arguments
             final course = args['course'] as CourseModel?;
             final chapter = args['chapter'] as LessonModel?; // 'chapter' est un LessonModel
             final allChapters = args['allChaptersInCourse'] as List<LessonModel>?;
             final currentIndex = args['currentChapterIndex'] as int?;
             final enrollmentId = args['enrollmentId'] as int?;


             if (course != null && chapter != null && allChapters != null && currentIndex != null) {
               return MaterialPageRoute(
                 builder: (context) => ChapterViewScreen( // ou LessonViewScreen
                   course: course,
                   chapter: chapter,
                   allChaptersInCourse: allChapters,
                   currentChapterIndex: currentIndex,
                   enrollmentId: enrollmentId,
                 ),
                 settings: settings,
               );
             }
           }
           // Erreur: arguments incorrects pour /chapter_view
           return _errorRoute(settings.name);
        }

        if (settings.name == '/quiz_list_for_course') {
           final courseId = settings.arguments as int?;
           return MaterialPageRoute(
             builder: (context) => QuizListScreen(courseId: courseId),
             settings: settings,
           );
        }

        // Gérer d'autres routes dynamiques ici...

        // Si aucune route ne correspond
        print("onGenerateRoute: Route '${settings.name}' non gérée.");
        return _errorRoute(settings.name);
      },
    );
  }

  // Helper pour une page d'erreur de route
  static MaterialPageRoute _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Route non trouvée ou arguments invalides pour: ${routeName ?? 'Unknown'}'),
        ),
      ),
    );
  }
}

// Définition pour le thème si vous souhaitez accéder via Theme.of(context).extension<MyThemeExtensions>()
// @immutable
// class MyThemeExtensions extends ThemeExtension<MyThemeExtensions> {
//   const MyThemeExtensions({
//     required this.defaultBorderRadius,
//   });

//   final double defaultBorderRadius;

//   @override
//   MyThemeExtensions copyWith({double? defaultBorderRadius}) {
//     return MyThemeExtensions(
//       defaultBorderRadius: defaultBorderRadius ?? this.defaultBorderRadius,
//     );
//   }

//   @override
//   MyThemeExtensions lerp(ThemeExtension<MyThemeExtensions>? other, double t) {
//     if (other is! MyThemeExtensions) {
//       return this;
//     }
//     return MyThemeExtensions(
//       defaultBorderRadius: lerpDouble(defaultBorderRadius, other.defaultBorderRadius, t)!,
//     );
//   }
// }
// double kDefaultBorderRadius = 12.0; // Vous pouvez le garder comme constante globale aussi