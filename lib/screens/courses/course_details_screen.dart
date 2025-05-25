import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/course_model.dart';
import '../../utils/app_colors.dart';
import './chapter_view_screen.dart'; // Renommé et adapté

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isFavorited = false;

  // Les chapitres viennent maintenant de widget.course.chapters
  // List<ChapterModel> get chapters => widget.course.chapters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: eduLearnBackground, // Thème global
      appBar: AppBar(
        // backgroundColor: eduLearnBackground, // Thème global
        // elevation: 0, // Thème global
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: eduLearnCardBg, // Fond pour le bouton
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)
                ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20),
            ),
          ),
        ),
        title: Text("Course Details"), // Le thème global gère le style
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
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                  color: eduLearnCardBg,
                  shape: BoxShape.circle,
                   boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)
                  ]
                ),
                child: Icon(
                  _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: eduLearnPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0), // Moins de padding en haut
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
            _buildSectionTitle("Course Description"), // Changé de "Course Details"
            const SizedBox(height: 8),
            _buildCourseDescription(),
            const SizedBox(height: 24),
            _buildSectionTitle("Chapters (${widget.course.chapters.length})"), // Changé de "Lessons"
            const SizedBox(height: 12),
            widget.course.chapters.isEmpty
                ? _buildEmptyState("No chapters available for this course yet.")
                : _buildChaptersList(), // Renommé
            const SizedBox(height: 24),
             ElevatedButton( // Style via thème
              onPressed: () { /* TODO: Logique pour s'inscrire/continuer */ },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Pleine largeur
              ),
              child: Text("Enroll Course - \$${widget.course.price.toStringAsFixed(2)}"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseImage() {
    return Hero( // Pour une transition animée potentielle
      tag: 'course_image_${widget.course.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        child: Image.asset(
          widget.course.imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.school_outlined, color: Colors.grey, size: 50)),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructorAndMetaInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(widget.course.instructorAvatar),
          onBackgroundImageError: (e, s) {},
          child: Image.asset(widget.course.instructorAvatar, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 20)),
        ),
        const SizedBox(width: 10),
        Text(
          widget.course.instructorName,
          style: GoogleFonts.poppins(color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const Spacer(),
        _buildMetaChip(Icons.timer_outlined, widget.course.durationTotal, eduLearnAccent.withOpacity(0.7)),
        const SizedBox(width: 8),
        _buildMetaChip(Icons.star_rounded, "${widget.course.rating}", Colors.orange.shade100.withOpacity(0.7), iconColor: Colors.orange.shade700, textColor: Colors.orange.shade800),
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
      widget.course.courseName,
      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: eduLearnTextBlack, height: 1.3),
    );
  }

  Widget _buildStatsChips() {
    return Row(
      children: [
        _buildMetaChip(Icons.people_outline_rounded, "${widget.course.studentCount} Students", eduLearnAccent.withOpacity(0.7)),
        const SizedBox(width: 10),
        _buildMetaChip(Icons.library_books_outlined, "${widget.course.lessonCount} Chapters", eduLearnAccent.withOpacity(0.7)),
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
      widget.course.description,
      style: GoogleFonts.poppins(fontSize: 14, color: eduLearnTextGrey, height: 1.6),
    );
  }

  Widget _buildChaptersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.course.chapters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chapter = widget.course.chapters[index];
        return InkWell(
          onTap: () {
            if (!chapter.isLocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterViewScreen(
                    course: widget.course,
                    chapter: chapter,
                    allChaptersInCourse: widget.course.chapters,
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
                  child: chapter.imagePath != null && chapter.imagePath!.startsWith('assets/')
                  ? Image.asset( // Image locale pour le chapitre
                      chapter.imagePath!,
                      width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => _defaultChapterIcon(index)
                    )
                  : (chapter.imagePath != null
                      ? Image.network( // Image réseau pour le chapitre
                          chapter.imagePath!,
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => _defaultChapterIcon(index)
                        )
                      : _defaultChapterIcon(index) // Placeholder si pas d'image
                    )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter.durationDisplay, // Champ de `ChapterModel`
                        style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextLightGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  chapter.isLocked ? Icons.lock_rounded
                      : (chapter.isPlaying) ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
                  color: chapter.isLocked ? eduLearnTextLightGrey : eduLearnPrimary,
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