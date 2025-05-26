import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_models.dart'; // Contient QuizInfoModel et QuizAttemptModel
import '../../utils/app_colors.dart';
import '../../services/quiz_service.dart';
import 'quiz_attempt_screen.dart';

class QuizListScreen extends StatefulWidget {
  final int? courseId; // Optionnel, si on affiche les quiz d'un cours spécifique

  const QuizListScreen({super.key, this.courseId});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final QuizService _quizService = QuizService();
  Future<List<QuizInfoModel>>? _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    setState(() {
      _quizzesFuture = _quizService.getUserQuizzes(courseId: widget.courseId);
    });
  }

  Future<void> _navigateToQuizAttempt(QuizInfoModel quizInfo) async {
    try {
      // Afficher un indicateur de chargement pendant que les questions du quiz sont récupérées
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chargement du quiz..."), duration: Duration(seconds: 1))
      );

      // Obtenir les détails complets du quiz (avec questions) pour la tentative
      QuizAttemptModel quizToAttempt = await _quizService.getQuizForAttempt(quizInfo.quizId);

      if (mounted) { // Vérifier si le widget est toujours monté
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizAttemptScreen(quizAttemptInput: quizToAttempt),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du quiz: ${e.toString()}"), backgroundColor: eduLearnError),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: eduLearnBackground,
      appBar: AppBar(
        // backgroundColor: eduLearnBackground, // Utilise le thème global
        // elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.courseId != null ? "Quiz du Cours" : "Mes Quiz",
          // style: GoogleFonts.poppins(color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18), // Theme gère
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QuizInfoModel>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Erreur: ${snapshot.error}",
                    style: GoogleFonts.poppins(color: eduLearnTextGrey)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 80, color: eduLearnTextGrey),
                  const SizedBox(height: 16),
                  Text("Aucun quiz disponible.",
                      style: GoogleFonts.poppins(fontSize: 18, color: eduLearnTextGrey)),
                ],
              ),
            );
          }

          final quizzes = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: quizzes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quizInfo = quizzes[index];
              return _buildQuizCard(context, quizInfo);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizInfoModel quizInfo) {
    bool attempted = quizInfo.score != null;
    return Card(
      elevation: 2.0,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
      color: eduLearnCardBg,
      child: InkWell(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        onTap: () => _navigateToQuizAttempt(quizInfo),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quizInfo.quizName,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
              ),
              const SizedBox(height: 4),
              Text(
                "Cours: ${quizInfo.courseName}",
                style: GoogleFonts.poppins(fontSize: 13, color: eduLearnTextGrey),
              ),
              if (quizInfo.description != null && quizInfo.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quizInfo.description!,
                  style: GoogleFonts.poppins(fontSize: 13, color: eduLearnTextLightGrey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${quizInfo.totalQuestions} Questions",
                    style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
                  ),
                  if (attempted && quizInfo.isPassed != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: quizInfo.isPassed! ? eduLearnSuccess.withOpacity(0.1) : eduLearnError.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        quizInfo.isPassed! ? "Réussi (${quizInfo.score!.toInt()}%)" : "Échoué (${quizInfo.score!.toInt()}%)",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: quizInfo.isPassed! ? eduLearnSuccess : eduLearnError,
                        ),
                      ),
                    )
                  else
                    Container(
                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: eduLearnPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      child: Text(
                        attempted ? "Refaire" : "Commencer", // Si déjà tenté mais isPassed est null (cas étrange), ou "Refaire"
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500, color: eduLearnPrimary),
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}