import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/course_model.dart'; // Contient ChapterModel et CourseModel
import '../../utils/app_colors.dart';

class ChapterViewScreen extends StatefulWidget {
  final CourseModel course;
  final ChapterModel chapter;
  final List<ChapterModel> allChaptersInCourse;
  final int currentChapterIndex;

  const ChapterViewScreen({
    super.key,
    required this.course,
    required this.chapter,
    required this.allChaptersInCourse,
    required this.currentChapterIndex,
  });

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  late ChapterModel _currentChapter;
  late int _currentChapterIdx;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _currentChapterIdx = widget.currentChapterIndex;
  }

  void _navigateToChapter(int index) {
    if (index >= 0 && index < widget.allChaptersInCourse.length) {
      ChapterModel nextChapter = widget.allChaptersInCourse[index];
      if (!nextChapter.isLocked) {
        setState(() {
          _currentChapter = nextChapter;
          _currentChapterIdx = index;
          // TODO: Mettre à jour l'état de lecture (isPlaying) dans le modèle parent ou via un provider
        });
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

  @override
  Widget build(BuildContext context) {
    final markdownContent = _currentChapter.fullContent; // Utilise la propriété fullContent

    return Scaffold(
      // backgroundColor: eduLearnBackground, // Thème global
      appBar: AppBar(
        backgroundColor: eduLearnCardBg, // Fond blanc pour cette AppBar spécifique
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
              _currentChapter.title,
              style: GoogleFonts.poppins(
                  color: eduLearnTextBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.course.courseName,
              style: GoogleFonts.poppins(
                  color: eduLearnTextGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: eduLearnPrimary),
            tooltip: "Marquer le chapitre",
            onPressed: () {
              // TODO: Logique pour marquer
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
                   if (_currentChapter.imagePath != null && _currentChapter.imagePath!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                        child: _currentChapter.imagePath!.startsWith('assets/')
                        ? Image.asset(
                            _currentChapter.imagePath!,
                            width: double.infinity, height: 180, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                          )
                        : Image.network(
                            _currentChapter.imagePath!,
                            width: double.infinity, height: 180, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                          )
                      ),
                    ),
                  MarkdownBody(
                    data: markdownContent,
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
                      codeblockPadding: const EdgeInsets.all(12),
                      listBullet: GoogleFonts.lato(fontSize: 16.5, color: eduLearnTextBlack, height: 1.6),
                      strong: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      em: GoogleFonts.lato(fontStyle: FontStyle.italic),
                    ),
                    imageBuilder: (Uri uri, String? title, String? alt) {
                      // Gérer les images dans le contenu Markdown
                      if (uri.scheme == 'assets') {
                        return Image.asset(uri.path, errorBuilder: (c,e,s) => const Text('[Image Error]'));
                      } else if (uri.isAbsolute) {
                         return Image.network(uri.toString(), errorBuilder: (c,e,s) => const Text('[Image Error]'));
                      }
                      return const SizedBox(child: Text('[Unsupported Image Source]'));
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
    bool canGoPrev = _currentChapterIdx > 0;
    bool canGoNext = _currentChapterIdx < widget.allChaptersInCourse.length - 1;

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
            onPressed: canGoPrev ? () => _navigateToChapter(_currentChapterIdx - 1) : null,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: canGoPrev ? eduLearnPrimary : Colors.grey),
            label: Text("Précédent", style: GoogleFonts.poppins(color: canGoPrev ? eduLearnPrimary : Colors.grey)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          ),
          ElevatedButton.icon( // Utiliser ElevatedButton pour le bouton principal d'action
            onPressed: canGoNext ? () => _navigateToChapter(_currentChapterIdx + 1) : null,
            label: Text("Suivant", style: GoogleFonts.poppins()), // Le style de couleur est géré par le thème
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            // Inverser pour que l'icône soit à droite n'est pas standard pour ElevatedButton.icon,
            // donc on garde l'icône à gauche ou on utilise un Row dans le child.
            // Pour mettre l'icône à droite avec ElevatedButton:
            // child: Row(mainAxisSize: MainAxisSize.min, children: [Text("Suivant"), SizedBox(width:4), Icon(...)])
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              // La couleur est gérée par le thème, mais on peut la forcer si besoin
              // backgroundColor: canGoNext ? eduLearnPrimary : Colors.grey.shade300,
              // foregroundColor: canGoNext ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}