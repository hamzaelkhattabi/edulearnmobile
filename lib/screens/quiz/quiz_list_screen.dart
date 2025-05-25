import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_colors.dart';
import 'quiz_attempt_screen.dart'; // À créer

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  // Données factices - Remplacer par une vraie source de données (API)
  final List<QuizInfoModel> _userQuizzes = [
    QuizInfoModel(
      quizId: 101,
      courseId: 1,
      courseName: "Introduction à Python",
      quizName: "Quiz Chapitre 1: Les Bases",
      totalQuestions: 10,
      description: "Testez vos connaissances sur les variables et types de données.",
      score: 80,
      isPassed: true,
    ),
    QuizInfoModel(
      quizId: 102,
      courseId: 1,
      courseName: "Introduction à Python",
      quizName: "Quiz Chapitre 2: Structures de Contrôle",
      totalQuestions: 15,
      description: "Évaluez votre compréhension des boucles et conditions.",
      score: 55,
      isPassed: false,
    ),
    QuizInfoModel(
      quizId: 201,
      courseId: 2,
      courseName: "Design UI/UX Avancé",
      quizName: "Module 1: Principes du Design",
      totalQuestions: 20,
      description: "Quiz sur les fondamentaux du design et de l'expérience utilisateur.",
      // score et isPassed sont nuls car non tenté
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: eduLearnBackground,
      appBar: AppBar(
        backgroundColor: eduLearnBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Mes Quiz",
          style: GoogleFonts.poppins(
              color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _userQuizzes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 80, color: eduLearnTextGrey),
                  const SizedBox(height: 16),
                  Text("Aucun quiz disponible ou complété.",
                      style: GoogleFonts.poppins(fontSize: 18, color: eduLearnTextGrey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _userQuizzes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final quizInfo = _userQuizzes[index];
                return _buildQuizCard(context, quizInfo);
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
        onTap: () {
          // Simuler le chargement des questions pour ce quiz
          // Dans une vraie app, vous feriez un appel API ici pour getQuizByCourseId
          // ou pour obtenir les détails complets du quiz par quizInfo.quizId
          QuizAttemptModel quizToAttempt = QuizAttemptModel(
            quizId: quizInfo.quizId,
            courseId: quizInfo.courseId,
            courseName: quizInfo.courseName,
            quizName: quizInfo.quizName,
            totalQuestions: quizInfo.totalQuestions,
            description: quizInfo.description,
            questions: List.generate(quizInfo.totalQuestions, (i) => QuizQuestionModel(
              id: "q_${quizInfo.quizId}_$i",
              questionText: "Ceci est la question ${i + 1} pour ${quizInfo.quizName}. Quel est votre choix?",
              options: [
                QuizOptionModel(text: "Option A", isCorrect: i % 4 == 0),
                QuizOptionModel(text: "Option B", isCorrect: i % 4 == 1),
                QuizOptionModel(text: "Option C", isCorrect: i % 4 == 2),
                QuizOptionModel(text: "Option D", isCorrect: i % 4 == 3),
              ],
              explanation: "L'explication pour la question ${i + 1} serait ici."
            ))
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizAttemptScreen(quizAttempt: quizToAttempt),
            ),
          );
        },
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
              if (quizInfo.description != null) ...[
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
                  if (attempted)
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
                        "Commencer",
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