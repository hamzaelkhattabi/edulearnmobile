// lib/screens/courses/chapter_view_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart'; // Potentiellement pour AuthProvider et enrollmentId

import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import '../../models/quiz_models.dart'; // Pour QuizInfoModel, QuizAttemptModel
import '../../providers/auth_provider.dart'; // Pour récupérer userId pour des actions futures
import '../../services/enrollment_service.dart';
import '../../services/quiz_service.dart';
import '../../utils/api_constants.dart';
import '../../utils/app_colors.dart';
import '../quiz/quiz_attempt_screen.dart';

class ChapterViewScreen extends StatefulWidget {
  final CourseModel course;
  final LessonModel chapter; // Renommé en `initialLesson` pour plus de clarté en interne
  final List<LessonModel> allChaptersInCourse; // Renommé en `allLessonsInCourse`
  final int currentChapterIndex; // Renommé en `initialLessonIndex`
  final int? enrollmentId; // Doit être passé pour les actions d'inscription/progression

  const ChapterViewScreen({
    super.key,
    required this.course,
    required this.chapter, // Ce sera la leçon initiale
    required this.allChaptersInCourse,
    required this.currentChapterIndex,
    this.enrollmentId,
  });

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  late LessonModel _currentLesson;
  late int _currentLessonIdx;

  final EnrollmentService _enrollmentService = EnrollmentService();
  final QuizService _quizService = QuizService();

  bool _isLoadingLessonContent = false; // Pour un chargement de contenu différé si besoin
  bool _isProcessingAction = false; // Pour les boutons Suivant/Terminer/Quiz

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.chapter;
    _currentLessonIdx = widget.currentChapterIndex;
    // Si le contenu n'est pas chargé avec la leçon (rare avec du markdown court),
    // _loadLessonContentIfNeeded();
    _markLessonAsStartedOrViewed();
  }

  Future<void> _loadLessonContentIfNeeded() async {
    // Exemple si vous chargez le contenu à la demande via une API dédiée à GET /api/lessons/:id
    if (_currentLesson.content == null || _currentLesson.content!.isEmpty) {
      if (mounted) setState(() { _isLoadingLessonContent = true; _isProcessingAction = true;});
      try {
        // Supposons un LessonService ou une méthode dans CourseService
        // final LessonModel detailedLesson = await _lessonService.getLessonDetails(_currentLesson.id);
        // if (mounted) {
        //   setState(() {
        //     _currentLesson = _currentLesson.copyWith(content: detailedLesson.content);
        //   });
        // }
         await Future.delayed(const Duration(seconds: 1)); // Simuler chargement
         if (mounted && _currentLesson.content == null) {
             // Cas où même après tentative, le contenu est vide. Utiliser un placeholder
             setState(() {
                 _currentLesson = _currentLesson.copyWith(content: "# Contenu Indisponible\n\nLe contenu de cette leçon n'a pu être chargé.");
             });
         }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de chargement du contenu: ${e.toString()}"), backgroundColor: eduLearnError),
          );
          // Mettre un contenu d'erreur par défaut
          setState(() {
             _currentLesson = _currentLesson.copyWith(content: "# Erreur\n\nImpossible de charger le contenu de cette leçon.");
          });
        }
      } finally {
        if (mounted) setState(() { _isLoadingLessonContent = false; _isProcessingAction = false; });
      }
    }
  }


  void _navigateToLesson(int index) {
    if (_isProcessingAction) return; // Empêcher la navigation multiple
    if (index >= 0 && index < widget.allChaptersInCourse.length) {
      LessonModel nextLesson = widget.allChaptersInCourse[index];
      // TODO: La logique 'isLocked' devrait idéalement venir de l'état de progression de l'utilisateur
      // stocké globalement ou re-fetché. Pour la démo, on le gère localement.
      if (!nextLesson.isLocked) {
        setState(() {
          _currentLesson = nextLesson;
          _currentLessonIdx = index;
          _isLoadingLessonContent = _currentLesson.content == null || _currentLesson.content!.isEmpty;
        });
        if(_isLoadingLessonContent) _loadLessonContentIfNeeded();
        _markLessonAsStartedOrViewed();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ce chapitre est verrouillé.", style: GoogleFonts.poppins()), backgroundColor: eduLearnWarning),
        );
      }
    }
  }

  Future<void> _markLessonAsCompleted() async {
    if (widget.enrollmentId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inscription requise pour marquer la progression.")));
      return;
    }
    if (_isProcessingAction) return;
    setState(() { _isProcessingAction = true; });

    try {
      await _enrollmentService.updateLessonProgress(widget.enrollmentId!, _currentLesson.id, true);
      if (mounted) {
        setState(() {
          _currentLesson = _currentLesson.copyWith(isCompleted: true); // Mettre à jour l'état local
          // Débloquer la prochaine leçon localement (l'état réel viendra de l'API lors du prochain chargement)
          if (_currentLessonIdx + 1 < widget.allChaptersInCourse.length) {
            widget.allChaptersInCourse[_currentLessonIdx + 1].isLocked = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'${_currentLesson.title}' marquée comme terminée !"), backgroundColor: eduLearnSuccess),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur progression: ${e.toString()}"), backgroundColor: eduLearnError),
        );
      }
    } finally {
      if (mounted) setState(() { _isProcessingAction = false; });
    }
  }
  
  void _markLessonAsStartedOrViewed() {
    // Logique si besoin d'envoyer à l'API que la leçon est vue/commencée
    if (mounted) {
      // setState(() {
      //   // Mettre à jour un état local 'isPlaying' si utile pour l'UI
      //   _currentLesson = _currentLesson.copyWith(isPlaying: true);
      // });
    }
    print("Leçon '${_currentLesson.title}' vue/commencée.");
  }

  Future<void> _attemptLessonQuiz(QuizInfoModel quizInfo) async {
    if (widget.enrollmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être inscrit pour passer le quiz."), backgroundColor: eduLearnWarning),
      );
      return;
    }
    if (_isProcessingAction) return;
    setState(() { _isProcessingAction = true; });

    try {
      QuizAttemptModel quizToAttempt = await _quizService.getQuizForAttempt(quizInfo.quizId);
      if (mounted) {
        final result = await Navigator.push<bool>( // Attendre un bool pour savoir si le quiz a été réussi
          context,
          MaterialPageRoute(
            builder: (context) => QuizAttemptScreen(quizAttemptInput: quizToAttempt),
          ),
        );
        // 'result' sera la valeur retournée par Navigator.pop(context, resultValue) de QuizResultScreen
        // Si QuizResultScreen pop avec le statut de réussite, on peut marquer la leçon
        if (result == true) { //  Supposant que QuizResultScreen renvoie `true` si le quiz est réussi
            await _markLessonAsCompleted();
        } else if (result == false) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quiz échoué. Réessayez !"), backgroundColor: eduLearnWarning));
        }
        // else : quiz annulé, pas d'action spécifique.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement quiz: ${e.toString()}"), backgroundColor: eduLearnError),
        );
      }
    } finally {
      if (mounted) setState(() { _isProcessingAction = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final markdownContentToDisplay = _isLoadingLessonContent
        ? "# Chargement du contenu..."
        : (_currentLesson.fullContent); // Utilise le getter `fullContent`

    // Vérifier si cette leçon a un quiz associé
    // On prendra le premier quiz de la liste s'il y en a plusieurs
    final QuizInfoModel? lessonQuiz = _currentLesson.quizzes.isNotEmpty ? _currentLesson.quizzes.first : null;
    
    bool canGoNextLesson = _currentLessonIdx < widget.allChaptersInCourse.length - 1;
    bool isLastLessonInCourse = !canGoNextLesson;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: eduLearnCardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: eduLearnTextBlack),
          onPressed: _isProcessingAction ? null : () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentLesson.title,
              style: GoogleFonts.poppins(color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.course.courseName,
              style: GoogleFonts.poppins(color: eduLearnTextGrey, fontWeight: FontWeight.w400, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              // TODO: Gérer l'état de `isBookmarked` dynamiquement
              false ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
              color: eduLearnPrimary
            ),
            tooltip: "Marquer le chapitre",
            onPressed: _isProcessingAction ? null : () {
              // TODO: Logique API pour marquer/démarquer + mise à jour UI
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingLessonContent
              ? const Center(child: CircularProgressIndicator(color: eduLearnPrimary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentLesson.imagePath != null && _currentLesson.imagePath!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(kDefaultBorderRadius), // Assurez-vous que kDefaultBorderRadius est défini globalement ou dans app_colors
                            child: _currentLesson.imagePath!.startsWith('assets/')
                                ? Image.asset(
                                    _currentLesson.imagePath!,
                                    width: double.infinity, height: 180, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                                  )
                                : Image.network(
                                    _currentLesson.imagePath!.startsWith('http')
                                        ? _currentLesson.imagePath!
                                        : ApiConstants.baseUrl.replaceAll("/api","") + (_currentLesson.imagePath!.startsWith('/') ? _currentLesson.imagePath! : "/${_currentLesson.imagePath!}"),
                                    width: double.infinity, height: 180, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                                     loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(height: 180, child: Center(child: CircularProgressIndicator( value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, strokeWidth: 2.0)));
                                    },
                                  )
                          ),
                        ),
                      MarkdownBody(
                        data: markdownContentToDisplay,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: GoogleFonts.lato(fontSize: 16.5, color: eduLearnTextBlack, height: 1.6),
                          h1: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: eduLearnTextBlack, height: 1.4),
                          h2: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: eduLearnTextBlack, height: 1.4),
                          h3: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: eduLearnTextBlack, height: 1.4),
                          code: GoogleFonts.robotoMono(backgroundColor: Colors.grey.shade200, color: Colors.grey.shade800, fontSize: 14.5),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        imageBuilder: (Uri uri, String? title, String? alt) {
                          // ... (votre imageBuilder existant, qui semble correct)
                           String imageUrl = uri.toString();
                           if (uri.scheme == 'assets') {
                             return Image.asset(uri.path, errorBuilder: (c,e,s) => const Text('[Image Error]'));
                           } else if (uri.isAbsolute) {
                              return Image.network(imageUrl, errorBuilder: (c,e,s) => const Text('[Image Error]'));
                           } else {
                             final fullUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
                             return Image.network(fullUrl, errorBuilder: (c,e,s) => const Text('[API Image Error]'));
                           }
                        },
                      ),
                    ],
                  ),
                ),
          ),
          // Afficher les contrôles de navigation seulement si le contenu est chargé
          if (!_isLoadingLessonContent) _buildNavigationControls(lessonQuiz),
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

  Widget _buildNavigationControls(QuizInfoModel? quizForThisLesson) {
    bool canGoPrev = _currentLessonIdx > 0;
    bool canGoNextNonQuiz = _currentLessonIdx < widget.allChaptersInCourse.length - 1 && quizForThisLesson == null && !_currentLesson.isCompleted;
    bool isLastLessonInCourse = _currentLessonIdx == widget.allChaptersInCourse.length - 1;

    List<Widget> buttons = [];

    // Bouton Précédent
    if (canGoPrev) {
      buttons.add(
        TextButton.icon(
          onPressed: _isProcessingAction ? null : () => _navigateToLesson(_currentLessonIdx - 1),
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: eduLearnPrimary),
          label: Text("Précédent", style: GoogleFonts.poppins(color: eduLearnPrimary)),
        )
      );
    } else {
      buttons.add(const SizedBox(width: 100)); // Placeholder pour l'alignement
    }

    // Bouton central/droit
    if (_isProcessingAction && !_isLoadingLessonContent) {
        buttons.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
        ));
    } else if (quizForThisLesson != null) { // S'il y a un quiz pour cette leçon
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _attemptLessonQuiz(quizForThisLesson),
          icon: const Icon(Icons.quiz_outlined, size: 18),
          label: const Text("Passer le Quiz"),
          style: ElevatedButton.styleFrom(backgroundColor: eduLearnPrimary, foregroundColor: Colors.white),
        )
      );
    } else if (canGoNextNonQuiz) { // Pas de quiz, pas la dernière leçon, pas encore complétée -> Suivant
       buttons.add(
        ElevatedButton.icon(
          onPressed: () => _navigateToLesson(_currentLessonIdx + 1),
          label: const Text("Suivant"),
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        )
      );
    } else if (!_currentLesson.isCompleted && widget.enrollmentId != null) { // Ni quiz, ni "Suivant" possible, mais leçon non complétée et inscrit -> Marquer
        buttons.add(
          ElevatedButton.icon(
            onPressed: _markLessonAsCompleted,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(isLastLessonInCourse ? "Terminer le Cours" : "Terminer Leçon"),
            style: ElevatedButton.styleFrom(backgroundColor: eduLearnSuccess),
          )
        );
    } else if (_currentLesson.isCompleted && canGoNextNonQuiz) { // Déjà complété, pas de quiz, il y a une suite
         buttons.add(
            ElevatedButton.icon(
              onPressed: () {
                    if (_currentLesson.quizzes.isNotEmpty) { // <<< AJOUTER CETTE VÉRIFICATION
                      _attemptLessonQuiz(_currentLesson.quizzes.first);
                    } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Aucun quiz défini pour cette leçon."))
                        );
                    }
                  },
              label: const Text("Suivant"),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            )
          );
    }
     else { // Cas par défaut (ex: dernière leçon déjà complétée)
        buttons.add(const SizedBox(width: 100)); // Placeholder
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: eduLearnCardBg,
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2)) ],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons,
      ),
    );
  }
}

// Assurez-vous que kDefaultBorderRadius est accessible (ex: via un fichier app_constants.dart ou app_colors.dart)
// const double kDefaultBorderRadius = 12.0;