import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Pour afficher du contenu Markdown
// Assurez-vous que share_plus est dans pubspec.yaml si vous l'utilisez

// Importez votre modèle de leçon et de cours
import '../../../models/lesson_model.dart'; // Ajustez le chemin
import '../../../models/course_model.dart';  // Ajustez le chemin

// Couleurs (vous pouvez les centraliser)
const Color primaryAppColor = Color(0xFFF45B69);
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;

class LessonViewScreen extends StatefulWidget {
  final CourseModel course; // Le cours auquel la leçon appartient
  final Lesson lesson;
  final List<Lesson> allLessonsInCourse; // Pour la navigation Suivant/Précédent
  final int currentLessonIndex;

  const LessonViewScreen({
    super.key,
    required this.course,
    required this.lesson,
    required this.allLessonsInCourse,
    required this.currentLessonIndex,
  });

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  late Lesson _currentLesson;
  late int _currentLessonIdx;

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.lesson;
    _currentLessonIdx = widget.currentLessonIndex;
  }

  void _navigateToLesson(int index) {
    if (index >= 0 && index < widget.allLessonsInCourse.length) {
      Lesson nextLesson = widget.allLessonsInCourse[index];
      if (!nextLesson.isLocked) { // Vérifiez si la leçon n'est pas verrouillée
        setState(() {
          _currentLesson = nextLesson;
          _currentLessonIdx = index;
        });
        // Idéalement, le widget parent (CourseDetailsScreen) gérerait la mise à jour
        // de 'isPlaying' et de la persistance de la progression.
        // Pour cet exemple, on change juste la leçon affichée.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cette leçon est verrouillée."), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parseur simple pour remplacer <img src="path"> par Image.asset
    // Pour une solution robuste, envisagez d'utiliser flutter_html ou un meilleur parseur markdown.
    final markdownContent = _currentLesson.content.replaceAllMapped(
        RegExp(r'<img src="([^"]+)"[^>]*>'), (match) {
      // Ce remplacement est TRES basique et ne fonctionnera que pour <img src="asset/path.png">
      // Il ne gère pas les URLs web ou d'autres attributs.
      // Pour cet exemple, on assume que c'est un placeholder et que l'image sera affichée autrement ou pas du tout dans le markdown direct.
      // Une meilleure approche serait d'utiliser `Markdown` et son `imageBuilder`.
      return ''; // On retire la balise pour la gestion manuelle
    });


    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textDarkColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentLesson.title,
              style: GoogleFonts.poppins(
                  color: textDarkColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.course.title, // Titre du cours
              style: GoogleFonts.poppins(
                  color: textGreyColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: primaryAppColor),
            tooltip: "Marquer la leçon",
            onPressed: () {
              // Logique pour marquer
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (_currentLesson.imageUrls != null && _currentLesson.imageUrls!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset( // Suppose la première image de la liste pour la bannière de la leçon
                          _currentLesson.imageUrls!.first,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) => Container(
                            height: 180, width: double.infinity, color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 50)),
                          ),
                        ),
                      ),
                    ),
                  MarkdownBody(
                    data: markdownContent, // Contenu parsé
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.lato(fontSize: 16.5, color: textDarkColor, height: 1.6),
                      h1: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: textDarkColor, height: 1.4),
                      h2: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: textDarkColor, height: 1.4),
                      h3: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDarkColor, height: 1.4),
                      code: GoogleFonts.robotoMono(backgroundColor: Colors.grey.shade200, color: Colors.grey.shade800, fontSize: 14.5),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      listBullet: GoogleFonts.lato(fontSize: 16.5, color: textDarkColor, height: 1.6),
                      strong: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      em: GoogleFonts.lato(fontStyle: FontStyle.italic),
                    ),
                    // Gérer le cas où <img src> était dans le markdown pour les images INLINE
                    // C'est un exemple basique
                    imageBuilder: (Uri uri, String? title, String? alt) {
                      if (uri.scheme == 'assets') { // Si vous avez une convention pour les assets
                        return Image.asset(uri.path, errorBuilder: (c,e,s) => const Text('Erreur image'));
                      } else if (uri.isAbsolute) { // Pour les images web
                         return Image.network(uri.toString(), errorBuilder: (c,e,s) => const Text('Erreur image'));
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    bool canGoPrev = _currentLessonIdx > 0;
    bool canGoNext = _currentLessonIdx < widget.allLessonsInCourse.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -2))
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: canGoPrev ? () => _navigateToLesson(_currentLessonIdx - 1) : null,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: canGoPrev ? primaryAppColor : Colors.grey),
            label: Text("Précédent", style: GoogleFonts.poppins(color: canGoPrev ? primaryAppColor : Colors.grey)),
          ),
          TextButton.icon(
            onPressed: canGoNext ? () => _navigateToLesson(_currentLessonIdx + 1) : null,
            label: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: canGoNext ? primaryAppColor : Colors.grey),
            icon: Text("Suivant", style: GoogleFonts.poppins(color: canGoNext ? primaryAppColor : Colors.grey)),
            // Inverser pour que l'icône soit à droite
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }
}