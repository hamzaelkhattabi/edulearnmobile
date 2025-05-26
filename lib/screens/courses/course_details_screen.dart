import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart'; // Assurez-vous d'utiliser le LessonModel mis à jour
import '../../utils/app_colors.dart';
import '../../utils/api_constants.dart';
import './chapter_view_screen.dart'; // Devrait être lesson_view_screen.dart ou chapter_view_screen.dart
import '../../services/course_service.dart'; // Pour getCourseById pour charger les détails complets si nécessaire
import '../../services/enrollment_service.dart'; // Pour s'inscrire au cours
// Importer QuizListScreen ou un écran pour démarrer le quiz du cours
import '../quiz/quiz_list_screen.dart'; // Si le bouton mène à une liste générale de quiz pour ce cours

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel courseInput; // Le cours passé en argument
                                // peut être un résumé, on pourrait recharger les détails complets.
  const CourseDetailsScreen({super.key, required this.courseInput});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int? _currentEnrollmentId;
  bool _isFavorited = false; // TODO: A gérer avec une API
  bool _isLoadingDetails = false;
  bool _isEnrolled = false; // TODO: A vérifier via une API ou état global
  double _progress = 0.0;   // TODO: A récupérer via API si l'utilisateur est inscrit

  late CourseModel _course; // Cours actuel à afficher (peut être mis à jour)

  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();


  @override
  void initState() {
    super.initState();
    _course = widget.courseInput;
    // Optionnel: Recharger les détails complets du cours si `courseInput` est un résumé
    _fetchFullCourseDetails();
    // TODO: Vérifier si l'utilisateur est inscrit et sa progression
    // _checkEnrollmentStatus();
  }

  Future<void> _fetchFullCourseDetails() async {
    if (mounted) {
      setState(() { _isLoadingDetails = true; });
    }
    try {
      // Si le courseInput n'a pas de leçons détaillées, par exemple.
      // Note: si les leçons sont toujours incluses, cet appel peut ne pas être nécessaire.
      final fullCourse = await _courseService.getCourseById(_course.id);
      if (mounted) {
        setState(() {
          _course = fullCourse;
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading course details: ${e.toString()}"), backgroundColor: eduLearnError),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoadingDetails = false; });
      }
    }
  }
  
  // Future<void> _checkEnrollmentStatus() async {
  //   // Appel API pour vérifier si l'utilisateur est inscrit et obtenir la progression
  //   // Mettre à jour _isEnrolled et _progress
  // }

  Future<void> _enrollOrContinueCourse() async {
    if (!_isEnrolled) {
      try {
        await _enrollmentService.enrollToCourse(_course.id);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inscription réussie!"), backgroundColor: eduLearnSuccess),
          );
          setState(() { _isEnrolled = true; });
          // Naviguer vers la première leçon ou rester sur la page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst("Exception: ", "")), backgroundColor: eduLearnError),
          );
        }
      }
    } else {
      // Logique pour "Continuer le cours"
      // Peut-être naviguer vers la dernière leçon vue
      if (_course.lessons.isNotEmpty) {
        // Trouver la première leçon non complétée ou la première leçon
         LessonModel lessonToStart = _course.lessons.firstWhere((l) => !l.isLocked, orElse: () => _course.lessons.first);

         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChapterViewScreen( // ou LessonViewScreen
              course: _course,
              // Assurez-vous que `chapter` est bien `LessonModel`
              chapter: lessonToStart, // Utiliser lessonToStart qui est un LessonModel
              allChaptersInCourse: _course.lessons, // Utiliser `_course.lessons`
              currentChapterIndex: _course.lessons.indexOf(lessonToStart),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ce cours n'a pas encore de leçons."))
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Remplacez widget.course par _course pour utiliser les données potentiellement rechargées
    // et 'chapters' par 'lessons' pour correspondre à CourseModel.
    List<LessonModel> lessons = _course.lessons;


    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: eduLearnCardBg, shape: BoxShape.circle,
                boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3) ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20),
            ),
          ),
        ),
        title: const Text("Course Details"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                setState(() { _isFavorited = !_isFavorited; });
                // TODO: API call pour gérer les favoris
              },
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: eduLearnCardBg, shape: BoxShape.circle,
                  boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3) ]
                ),
                child: Icon(
                  _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: eduLearnPrimary, size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingDetails
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
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
                _buildSectionTitle("Course Description"),
                const SizedBox(height: 8),
                _buildCourseDescription(),
                const SizedBox(height: 24),
                _buildSectionTitle("Chapters (${lessons.length})"), // Utilisez lessons.length
                const SizedBox(height: 12),
                lessons.isEmpty
                    ? _buildEmptyState("No chapters available for this course yet.")
                    : _buildChaptersList(lessons), // Passez la liste des leçons
                const SizedBox(height: 24),
                 ElevatedButton(
                  onPressed: _enrollOrContinueCourse, // Logique d'inscription ou de continuation
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(_isEnrolled ? "Continue Learning" : "Enroll Now"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildCourseImage() {
    String imageUrl = _course.imageUrl;
    if (!imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
      imageUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
    }

    return Hero(
      tag: 'course_image_${_course.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        child: imageUrl.startsWith('assets/')
            ? Image.asset(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _imageErrorPlaceholder())
            : Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _imageErrorPlaceholder(),
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(height: 200, child: Center(child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                  )));
                },
              ),
      ),
    );
  }
  Widget _imageErrorPlaceholder() {
    return Container(
        height: 200, width: double.infinity, color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.school_outlined, color: Colors.grey, size: 50)),
    );
  }


  Widget _buildInstructorAndMetaInfo() {
     String instructorAvatarUrl = _course.instructorAvatar ?? 'assets/default_avatar.png';
     if (!instructorAvatarUrl.startsWith('http') && !instructorAvatarUrl.startsWith('assets/')) {
        instructorAvatarUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (instructorAvatarUrl.startsWith('/') ? instructorAvatarUrl : '/$instructorAvatarUrl') ;
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
             child: instructorAvatarUrl.startsWith('assets/')
              ? Image.asset(instructorAvatarUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 20))
              : Image.network(instructorAvatarUrl, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 20))
          )
        ),
        const SizedBox(width: 10),
        Text(
          _course.instructorName,
          style: GoogleFonts.poppins(color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const Spacer(),
        _buildMetaChip(Icons.timer_outlined, _course.durationTotal, eduLearnAccent.withOpacity(0.7)),
        const SizedBox(width: 8),
        _buildMetaChip(Icons.star_rounded, _course.rating.toStringAsFixed(1), Colors.orange.shade100.withOpacity(0.7), iconColor: Colors.orange.shade700, textColor: Colors.orange.shade800),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String text, Color bgColor, {Color iconColor = eduLearnPrimary, Color textColor = eduLearnTextBlack}) {
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
      _course.courseName,
      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: eduLearnTextBlack, height: 1.3),
    );
  }

  Widget _buildStatsChips() {
    return Row(
      children: [
        _buildMetaChip(Icons.people_outline_rounded, "${_course.studentCount} Students", eduLearnAccent.withOpacity(0.7)),
        const SizedBox(width: 10),
        _buildMetaChip(Icons.library_books_outlined, "${_course.lessonCount} Chapters", eduLearnAccent.withOpacity(0.7)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: eduLearnTextBlack),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt_outlined, size: 50, color: eduLearnTextGrey.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: eduLearnTextGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDescription() {
    return Text(
      _course.description ?? "No description available.",
      style: GoogleFonts.poppins(fontSize: 14, color: eduLearnTextGrey, height: 1.6),
    );
  }

  Widget _buildChaptersList(List<LessonModel> lessons) { // Prend LessonModel en argument
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final lesson = lessons[index]; // C'est un LessonModel
        String? lessonImageUrl = lesson.imagePath;
         if (lessonImageUrl != null && !lessonImageUrl.startsWith('http') && !lessonImageUrl.startsWith('assets/')) {
          lessonImageUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (lessonImageUrl.startsWith('/') ? lessonImageUrl : '/$lessonImageUrl');
        }

        return InkWell(
          onTap: () {
            // Mettre à jour l'état de la leçon à "isLocked=false" est une logique complexe
            // qui dépend de la progression. Pour l'instant, on se base sur le `isLocked` du modèle.
            // L'API de progression (`updateLessonProgress`) devrait mettre à jour cet état.
            if (!lesson.isLocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterViewScreen( // ou LessonViewScreen
                    course: _course,
                    chapter: lesson, // chapter est un LessonModel
                    allChaptersInCourse: lessons,
                    currentChapterIndex: index,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Ce chapitre est verrouillé. Terminez les précédents.", style: GoogleFonts.poppins()),
                  backgroundColor: eduLearnWarning,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: eduLearnCardBg,
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5) ]
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                   child: lessonImageUrl == null
                    ? _defaultChapterIcon(index)
                    : (lessonImageUrl.startsWith('assets/')
                        ? Image.asset(lessonImageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => _defaultChapterIcon(index))
                        : Image.network(lessonImageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => _defaultChapterIcon(index)))
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.durationDisplay, // Utilise le getter de LessonModel
                        style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextLightGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // L'état isPlaying est local à l'UI. isLocked devrait venir des données de progression.
                // isCompleted pourrait aussi être un indicateur.
                Icon(
                  lesson.isLocked ? Icons.lock_rounded
                      // : (lesson.isCompleted) ? Icons.check_circle_rounded // Ex: si complété
                      : (lesson.isPlaying) ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
                  color: lesson.isLocked ? eduLearnTextLightGrey : eduLearnPrimary,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _defaultChapterIcon(int index) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Icon(Icons.menu_book_rounded, color: Colors.primaries[index % Colors.primaries.length], size: 30),
    );
  }
}