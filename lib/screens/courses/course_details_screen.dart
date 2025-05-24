import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Assurez-vous d'importer vos modèles
import '../../models/lesson_model.dart'; // Tel que vous l'avez dans votre code
import '../../models/course_model.dart';// ... (au début du fichier) // Si vous passez le modèle Course
import './lesson_view_screen.dart'; // Importez la nouvelle page // Importez le modèle de cours

// ... (vos constantes de couleur existantes) ...
const Color primaryAppColor = Color(0xFFF45B69);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const Color textLightGreyColor = Color(0xFF9CA3AF);
const Color chipBackgroundColor = Color(0xFFFCE7E9);
const double kDefaultBorderRadius = 15.0;


class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course; // MODIFICATION ICI : Accepter un objet CourseModel

  const CourseDetailsScreen({super.key, required this.course}); // MODIFICATION ICI

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isFavorited = false;

  // Données factices pour les leçons, pourraient venir de widget.course.lessons
    // Dans _CourseDetailsScreenState
  // Dans CourseDetailsScreen, la liste `lessons`
// Dans _CourseDetailsScreenState de course_details_screen.dart
  final List<Lesson> lessons = [
  Lesson(
    id: "lesson_101",
    title: "Intro to Python",
    duration: "Lecture: 15 Mins", // Adapter la durée si besoin
    thumbnailAsset: "assets/lesson_thumb_1.png",
    isPlaying: true,
    content: """
# Introduction à Python

Bienvenue dans ce premier chapitre sur Python !

Python est un langage de programmation **interprété**, **multi-paradigme** et **multi-plateformes**. 
Il favorise la programmation impérative structurée, fonctionnelle et orientée objet.

## Pourquoi Python ?

*   **Simplicité et Lisibilité :** Sa syntaxe est claire et proche du langage naturel.
*   **Grande Communauté :** Beaucoup de ressources, bibliothèques et d'entraide.
*   **Polyvalence :** Web, science des données, scripting, intelligence artificielle, etc.

Dans ce module, nous allons couvrir les bases indispensables pour bien démarrer.
Nous parlerons de l'installation, des variables, des types de données et des opérateurs.

Voici une image d'exemple :
<img src="assets/lesson_image_example.png" alt="Exemple Image"> 
    """, // Vous pourriez aussi avoir un markdown plus structuré ici ou HTML simplifié
    imageUrls: ["assets/lesson_image_example.png"] // Si vous voulez charger l'image via un tag spécial
  ),
  Lesson(
    id: "lesson_102",
    title: "Variables and Data Types",
    duration: "Lecture: 20 Mins",
    thumbnailAsset: "assets/lesson_thumb_2.png",
    isLocked: false,
    content: """
# Variables et Types de Données en Python

Une **variable** est un nom symbolique associé à une valeur et dont la valeur associée peut être changée. 
En Python, il n'est pas nécessaire de déclarer explicitement le type d'une variable. Le type est inféré à partir de la valeur assignée.

## Types de données principaux :
*   **Nombres :**
    *   `int` (entiers) : `x = 5`
    *   `float` (nombres à virgule flottante) : `y = 3.14`
    *   `complex` (nombres complexes) : `z = 1 + 2j`
*   **Chaînes de caractères (`str`) :**
    `message = "Bonjour, monde !"`
*   **Booléens (`bool`) :**
    `is_active = True`
    `is_greater = False`
*   **Listes (`list`) :** Collection ordonnée et modifiable.
    `fruits = ["pomme", "banane", "cerise"]`
*   **Tuples (`tuple`) :** Collection ordonnée et non modifiable.
    `coordonnees = (10, 20)`
*   **Dictionnaires (`dict`) :** Collection non ordonnée de paires clé-valeur.
    `personne = {"nom": "Dupont", "age": 30}`

Nous explorerons chacun de ces types en détail.
    """,
  ),
  // ... autres leçons avec du contenu
];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        // ... (appBar existante) ...
        backgroundColor: lightBackground,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  )
                ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: textDarkColor, size: 20),
            ),
          ),
        ),
        title: Text(
          "Course Details",
          style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isFavorited = !_isFavorited;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  shape: BoxShape.circle,
                   boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    )
                  ]
                ),
                child: Icon(
                  _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: primaryAppColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseImage(),
            const SizedBox(height: 16),
            _buildInstructorAndMetaInfo(),
            const SizedBox(height: 16),
            _buildCourseTitle(),
            const SizedBox(height: 12),
            _buildStatsChips(),
            const SizedBox(height: 24),
            _buildSectionTitle("Course Details"),
            const SizedBox(height: 8),
            _buildCourseDescription(),
            const SizedBox(height: 24),
            _buildSectionTitle("Lessons"),
            const SizedBox(height: 12),
            _buildLessonsList(),
            const SizedBox(height: 24),
             ElevatedButton(
              onPressed: () { /* Logique pour s'inscrire/continuer */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAppColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                ),
              ),
              child: Text(
                "Enroll Course - \$${widget.course.price}", // Utiliser le prix du cours
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      child: Image.asset(
        widget.course.imageUrl, // MODIFICATION ICI
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
        ),
      ),
    );
  }

  Widget _buildInstructorAndMetaInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(widget.course.instructorAvatar), // MODIFICATION ICI
          onBackgroundImageError: (e, s) {},
          child: Image.asset(widget.course.instructorAvatar, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 20)),
        ),
        const SizedBox(width: 10),
        Text(
          widget.course.instructorName, // MODIFICATION ICI
          style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const Spacer(),
        _buildMetaChip(Icons.timer_outlined, widget.course.duration, chipBackgroundColor), // MODIFICATION ICI
        const SizedBox(width: 8),
        _buildMetaChip(Icons.star_rounded, "${widget.course.rating}", Colors.orange.shade100.withOpacity(0.7), iconColor: Colors.orange.shade700, textColor: Colors.orange.shade800), // MODIFICATION ICI
      ],
    );
  }

  // _buildMetaChip reste identique
  Widget _buildMetaChip(IconData icon, String text, Color bgColor, {Color iconColor = primaryAppColor, Color textColor = textDarkColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Text(
      widget.course.title, // MODIFICATION ICI
      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textDarkColor, height: 1.3),
    );
  }

  Widget _buildStatsChips() {
    return Row(
      children: [
        _buildMetaChip(Icons.people_outline_rounded, "${widget.course.studentCount} Students", chipBackgroundColor.withOpacity(0.7)), // MODIFICATION
        const SizedBox(width: 10),
        _buildMetaChip(Icons.library_books_outlined, "${widget.course.lessonCount} Lessons", chipBackgroundColor.withOpacity(0.7)), // MODIFICATION
      ],
    );
  }

  // _buildSectionTitle reste identique
   Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textDarkColor),
    );
  }


  Widget _buildCourseDescription() {
    return Text(
      widget.course.description, // MODIFICATION ICI
      style: GoogleFonts.poppins(fontSize: 14, color: textGreyColor, height: 1.5),
    );
  }

  // Dans la classe _CourseDetailsScreenState, assurez-vous d'avoir accès à votre objet `course` actuel.
  // Par exemple, s'il est passé via le widget : widget.course

  // Au début de course_details_screen.dart
 // Ajustez le chemin vers le fichier lesson_view_screen.dart que vous venez de créer

  Widget _buildLessonsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length, // 'lessons' est votre liste de Lesson
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return InkWell( // Rendre la rangée cliquable
          onTap: () {
            if (!lesson.isLocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonViewScreen(
                    course: widget.course, // Assurez-vous que 'widget.course' est l'objet CourseModel actuel
                    lesson: lesson,
                    allLessonsInCourse: lessons, // Passer la liste complète des leçons
                    currentLessonIndex: index,   // Passer l'index de la leçon actuelle
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cette leçon est verrouillée. Terminez les précédentes."), duration: Duration(seconds: 2),),
              );
            }
          },
          child: Container(
            // ... (votre style de carte de leçon existant) ...
             padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5, ) ]
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    lesson.thumbnailAsset,
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(
                      width: 60, height: 60, color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.3),
                      child: Icon(Icons.play_circle_fill_rounded, color: Colors.primaries[index % Colors.primaries.length], size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textDarkColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.duration,
                        style: GoogleFonts.poppins(fontSize: 12, color: textLightGreyColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  lesson.isLocked ? Icons.lock_rounded
                      : (lesson.isPlaying /*|| lesson.id == widget.course.currentPlayingLessonId*/) ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded, // Change l'icône en fonction de l'état
                  color: lesson.isLocked ? textLightGreyColor : primaryAppColor,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }}