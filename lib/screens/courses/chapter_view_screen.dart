import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/course_model.dart'; // Contient CourseModel
import '../../models/lesson_model.dart'; // Nouveau modèle de Leçon (anciennement ChapterModel)
import '../../utils/app_colors.dart';
import '../../utils/api_constants.dart'; // Pour construire les URL d'images du markdown
import '../../services/enrollment_service.dart'; // Pour marquer la leçon comme complétée

class ChapterViewScreen extends StatefulWidget { // Devrait être LessonViewScreen pour correspondre à LessonModel
  final CourseModel course;
  final LessonModel chapter; // `chapter` est maintenant un `LessonModel`
  final List<LessonModel> allChaptersInCourse;
  final int currentChapterIndex;
  final int? enrollmentId; // ID de l'inscription de l'utilisateur au cours, nécessaire pour marquer la progression

  const ChapterViewScreen({
    super.key,
    required this.course,
    required this.chapter,
    required this.allChaptersInCourse,
    required this.currentChapterIndex,
    this.enrollmentId, // Le passer si l'utilisateur est inscrit
  });

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  late LessonModel _currentLesson;
  late int _currentLessonIdx;
  final EnrollmentService _enrollmentService = EnrollmentService();
  bool _isLoadingLessonContent = false; // Si le contenu est chargé séparément

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.chapter;
    _currentLessonIdx = widget.currentChapterIndex;
    // Si le contenu de la leçon n'est pas inclus initialement (par ex. dans la liste des leçons)
    // vous pourriez le charger ici. Pour l'instant, on suppose qu'il est dans _currentLesson.content
    // _loadLessonContent();
    _markLessonAsStartedOrViewed(); // Peut-être marquer comme 'en cours' si pertinent
  }
  
  // Exemple: si vous vouliez charger le contenu à la demande
  // Future<void> _loadLessonContent() async {
  //   if (_currentLesson.content == null || _currentLesson.content!.isEmpty) {
  //     setState(() { _isLoadingLessonContent = true; });
  //     try {
  //       // Supposons une méthode dans CourseService ou LessonService
  //       // final lessonDetails = await _courseService.getLessonDetails(_currentLesson.id);
  //       // if (mounted) {
  //       //   setState(() {
  //       //     _currentLesson = _currentLesson.copyWith(content: lessonDetails.content); // supposez une méthode copyWith
  //       //     _isLoadingLessonContent = false;
  //       //   });
  //       // }
  //     } catch (e) { /* ... */ }
  //   }
  // }

  void _navigateToLesson(int index) {
    if (index >= 0 && index < widget.allChaptersInCourse.length) {
      LessonModel nextLesson = widget.allChaptersInCourse[index];
      if (!nextLesson.isLocked) { // 'isLocked' devrait être géré par la logique de progression
        setState(() {
          _currentLesson = nextLesson;
          _currentLessonIdx = index;
          // TODO: Mettre à jour l'état de lecture (_currentLesson.isPlaying)
          // _loadLessonContent(); // Recharger le contenu si nécessaire
        });
         _markLessonAsStartedOrViewed();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ce chapitre est verrouillé.", style: GoogleFonts.poppins()),
            backgroundColor: eduLearnWarning,
            duration: const Duration(seconds: 2)
          ),
        );
      }
    }
  }

  Future<void> _markLessonAsCompleted() async {
    if (widget.enrollmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible de marquer comme complété: Non inscrit ou erreur.")));
        return;
    }
    try {
        await _enrollmentService.updateLessonProgress(widget.enrollmentId!, _currentLesson.id, true);
        // Mettre à jour l'UI si nécessaire (par exemple, changer l'icône, débloquer la suivante)
        // Cela peut impliquer de re-fetcher l'état de progression du cours.
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${_currentLesson.title} marqué comme terminé !"), backgroundColor: eduLearnSuccess),
        );
        // Débloquer la prochaine leçon localement ou attendre une mise à jour de l'API
        if (_currentLessonIdx + 1 < widget.allChaptersInCourse.length) {
          widget.allChaptersInCourse[_currentLessonIdx + 1].isLocked = false; // Simplification UI
        }
        setState(() {}); // Rafraîchir l'UI
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: ${e.toString()}"), backgroundColor: eduLearnError),
        );
    }
  }
  
  void _markLessonAsStartedOrViewed() {
    // Ici, vous pourriez appeler une API si vous suivez le "visionnage" ou "démarrage" d'une leçon
    // Par exemple, pour mettre à jour `isPlaying` ou un champ `last_viewed_at`.
    // Pour l'instant, c'est une action locale.
    if (mounted) {
      setState(() {
        // Mettre à jour `_currentLesson.isPlaying = true;` et le reste à false si besoin
        // Cela doit être géré par un état plus global si la lecture persiste en dehors de l'écran
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utilisez _currentLesson.content car c'est la source du markdown maintenant
    final markdownContent = _currentLesson.content ?? '# ${_currentLesson.title}\n\nContenu indisponible.';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: eduLearnCardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: eduLearnTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentLesson.title,
              style: GoogleFonts.poppins(
                  color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.course.courseName,
              style: GoogleFonts.poppins(
                  color: eduLearnTextGrey, fontWeight: FontWeight.w400, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: eduLearnPrimary), // TODO: Gérer l'état marqué/non marqué
            tooltip: "Marquer le chapitre",
            onPressed: () {
              // TODO: Logique pour marquer (API call + update UI)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingLessonContent
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (_currentLesson.imagePath != null && _currentLesson.imagePath!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                        child: _currentLesson.imagePath!.startsWith('assets/')
                        ? Image.asset(
                            _currentLesson.imagePath!,
                            width: double.infinity, height: 180, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                          )
                        : Image.network( // Supposons que l'API renvoie une URL complète ou gérable
                            _currentLesson.imagePath!.startsWith('http')
                                ? _currentLesson.imagePath!
                                : ApiConstants.baseUrl.replaceAll("/api","") + _currentLesson.imagePath!, // Ajuster si ce n'est pas le cas
                            width: double.infinity, height: 180, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                          )
                      ),
                    ),
                  MarkdownBody(
                    data: markdownContent,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      // Vos styles ...
                      p: GoogleFonts.lato(fontSize: 16.5, color: eduLearnTextBlack, height: 1.6),
                    ),
                    imageBuilder: (Uri uri, String? title, String? alt) {
                      String imageUrl = uri.toString();
                      if (uri.scheme == 'assets') { // chemin type assets/images/pic.png
                        return Image.asset(uri.path, errorBuilder: (c,e,s) => const Text('[Image Error]'));
                      } else if (uri.isAbsolute) { // URL complète http://...
                         return Image.network(imageUrl, errorBuilder: (c,e,s) => const Text('[Image Error]'));
                      } else { // chemin relatif type /uploads/image.png ou image.png
                        // Il faut préfixer avec la baseUrl du serveur si c'est un chemin relatif venant du markdown de l'API
                        final fullUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
                        return Image.network(fullUrl, errorBuilder: (c,e,s) => const Text('[API Image Error]'));
                      }
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

  Widget _imagePlaceholder() {
    return Container(
      height: 180, width: double.infinity, color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 50)),
    );
  }

  Widget _buildNavigationControls() {
    bool canGoPrev = _currentLessonIdx > 0;
    // Peut aller au suivant si ce n'est pas la dernière ou si la leçon actuelle est complétée et débloque la suivante
    bool canGoNext = _currentLessonIdx < widget.allChaptersInCourse.length - 1;
    // Optionnel : Bouton "Terminer la leçon" si c'est la dernière du module ou si on veut la marquer comme telle explicitement
    bool isLastLessonOfCourse = _currentLessonIdx == widget.allChaptersInCourse.length - 1;


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: eduLearnCardBg,
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2)) ],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: canGoPrev ? () => _navigateToLesson(_currentLessonIdx - 1) : null,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: canGoPrev ? eduLearnPrimary : Colors.grey),
            label: Text("Précédent", style: GoogleFonts.poppins(color: canGoPrev ? eduLearnPrimary : Colors.grey)),
          ),

          if (!isLastLessonOfCourse || !canGoNext ) // Si pas la dernière OU si la dernière n'est pas encore accessible
             ElevatedButton.icon(
              onPressed: canGoNext ? () => _navigateToLesson(_currentLessonIdx + 1) : null,
              label: Text(isLastLessonOfCourse ? "Terminer Cours" : "Suivant", style: GoogleFonts.poppins()),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              style: ElevatedButton.styleFrom(
                 backgroundColor: (isLastLessonOfCourse && widget.enrollmentId != null) ? eduLearnSuccess : (canGoNext ? eduLearnPrimary : Colors.grey.shade300),
              ),
            ),
           if (widget.enrollmentId != null && !isLastLessonOfCourse ) // Affiche le bouton Marquer comme complété à la place de "Suivant" si pas déjà complété
            ElevatedButton.icon(
              onPressed: _markLessonAsCompleted,
              icon: const Icon(Icons.check_circle_outline, size:18),
              label: const Text("Terminer Leçon"),
               style: ElevatedButton.styleFrom(backgroundColor: eduLearnSuccess)
            ),
            // if (widget.enrollmentId != null && isLastLessonOfCourse)
            //  ElevatedButton.icon(
            //   onPressed: () async {
            //       await _markLessonAsCompleted();
            //       // Peut-être naviguer vers l'écran de résultats du cours ou de quiz final.
            //       Navigator.of(context).popUntil((route) => route.settings.name == '/course_details' || route.isFirst); // Retour aux détails du cours
            //   },
            //   icon: const Icon(Icons.flag_circle_outlined, size:18),
            //   label: const Text("Terminer le Cours"),
            //    style: ElevatedButton.styleFrom(backgroundColor: eduLearnSuccess),
            // ),
        ],
      ),
    );
  }
}