import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_colors.dart';
import 'quiz_attempt_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptModel quizResult;

  const QuizResultScreen({super.key, required this.quizResult});

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    for (var q_idx = 0; q_idx < quizResult.questions.length; q_idx++) {
      final question = quizResult.questions[q_idx];
      if (question.selectedOption != null && question.selectedOption!.isCorrect) {
        correctAnswers++;
      }
    }
    // Le score devrait déjà être dans quizResult.score, mais on peut le recalculer pour être sûr
    final score = quizResult.score ?? (correctAnswers / quizResult.questions.length) * 100;
    final isPassed = quizResult.isPassed ?? score >= 70;


    return Scaffold(
      backgroundColor: eduLearnBackground,
      appBar: AppBar(
        backgroundColor: eduLearnBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de bouton retour par défaut
        title: Text(
          "Résultats du Quiz",
          style: GoogleFonts.poppins(
              color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultHeader(score, isPassed, context),
            const SizedBox(height: 24),
            _buildScoreSummary(correctAnswers, quizResult.questions.length),
            const SizedBox(height: 24),
            if (isPassed) // Optionnellement, lien vers le certificat si applicable
              ElevatedButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text("Voir mon Certificat (si applicable)"),
                onPressed: () {
                  // TODO: Naviguer vers l'écran du certificat si un est généré
                  // Cela pourrait nécessiter de vérifier si un certificat est lié à ce quizId
                  // et de le passer à CertificateViewScreen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fonctionnalité de certificat à implémenter."))
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: eduLearnSuccess, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
                ),
              ),
            if (!isPassed)
              ElevatedButton.icon(
                icon: const Icon(Icons.replay_outlined),
                label: const Text("Réessayer le Quiz"),
                onPressed: () {
                  // Recréer un QuizAttemptModel "frais" pour une nouvelle tentative
                  QuizAttemptModel newAttempt = QuizAttemptModel(
                    quizId: quizResult.quizId,
                    courseId: quizResult.courseId,
                    courseName: quizResult.courseName,
                    quizName: quizResult.quizName,
                    totalQuestions: quizResult.totalQuestions,
                    description: quizResult.description,
                    questions: quizResult.questions.map((q) => QuizQuestionModel( // Réinitialiser selectedOption
                      id: q.id,
                      questionText: q.questionText,
                      options: q.options,
                      explanation: q.explanation,
                      imagePath: q.imagePath,
                      selectedOption: null // Important: réinitialiser
                    )).toList()
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizAttemptScreen(quizAttempt: newAttempt)));
                },
                 style: ElevatedButton.styleFrom(
                    backgroundColor: eduLearnWarning, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton(
              child: const Text("Retour à la liste des quiz"),
              onPressed: () {
                // Pop jusqu'à la racine ou à l'écran des quiz
                Navigator.of(context).popUntil((route) => route.settings.name == '/quiz_list' || route.isFirst);
                // Si QuizListScreen n'est pas dans la pile, on peut la push
                // if (!Navigator.of(context).canPop() || Navigator.of(context).widget.toString() != 'QuizListScreen') {
                //   Navigator.pushReplacementNamed(context, '/quiz_list');
                // }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: eduLearnPrimary,
                side: const BorderSide(color: eduLearnPrimary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Revue des Réponses:",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
            ),
            const SizedBox(height: 12),
            _buildAnswersReview(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(double score, bool isPassed, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPassed ? eduLearnSuccess.withOpacity(0.1) : eduLearnError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        border: Border.all(color: isPassed ? eduLearnSuccess : eduLearnError, width: 1.5)
      ),
      child: Column(
        children: [
          Icon(
            isPassed ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
            color: isPassed ? eduLearnSuccess : eduLearnError,
            size: 70,
          ),
          const SizedBox(height: 16),
          Text(
            isPassed ? "Félicitations !" : "Dommage, essayez encore !",
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold, color: isPassed ? eduLearnSuccess : eduLearnError),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Votre score: ${score.toStringAsFixed(0)}%",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w500, color: eduLearnTextBlack),
          ),
          const SizedBox(height: 4),
          Text(
            quizResult.quizName,
            style: GoogleFonts.poppins(fontSize: 15, color: eduLearnTextGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(int correct, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("Total Questions", total.toString(), Icons.help_outline_rounded, Colors.blueGrey),
        _buildStatItem("Correctes", correct.toString(), Icons.check_rounded, eduLearnSuccess),
        _buildStatItem("Incorrectes", (total - correct).toString(), Icons.close_rounded, eduLearnError),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: eduLearnTextBlack)),
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: eduLearnTextGrey)),
      ],
    );
  }

  Widget _buildAnswersReview() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quizResult.questions.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final question = quizResult.questions[index];
        final selectedOpt = question.selectedOption;
        final correctOpt = question.options.firstWhere((opt) => opt.isCorrect);

        Color getOptionColor(QuizOptionModel option) {
          if (selectedOpt == option) { // Option choisie par l'utilisateur
            return option.isCorrect ? eduLearnSuccess : eduLearnError;
          } else if (option.isCorrect) { // Bonne réponse non choisie
            return eduLearnSuccess.withOpacity(0.7);
          }
          return eduLearnTextGrey; // Option neutre
        }

         IconData getOptionIcon(QuizOptionModel option) {
          if (selectedOpt == option) {
            return option.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
          } else if (option.isCorrect) {
            return Icons.radio_button_off_rounded; // Bonne réponse mais pas sélectionnée
          }
          return Icons.radio_button_off_rounded;
        }


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${index + 1}: ${question.questionText}",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: eduLearnTextBlack),
            ),
            const SizedBox(height: 10),
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
                child: Row(
                  children: [
                    Icon(getOptionIcon(option), color: getOptionColor(option), size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(option.text, style: GoogleFonts.poppins(color: getOptionColor(option)))),
                  ],
                ),
              );
            }).toList(),
            if (question.explanation != null && selectedOpt != correctOpt) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: eduLearnWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  "Explication: ${question.explanation}",
                  style: GoogleFonts.poppins(fontSize: 13, color: eduLearnWarning),
                ),
              )
            ]
          ],
        );
      },
    );
  }
}