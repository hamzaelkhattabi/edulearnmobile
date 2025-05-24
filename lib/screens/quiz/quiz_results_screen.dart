import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/quiz_models.dart'; // Ajustez si nécessaire

// Couleurs
const Color primaryAppColor = Color(0xFFF45B69);
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const Color lightBackground = Color(0xFFF9FAFC);
const Color correctAnswerColor = Colors.green;
const Color wrongAnswerColor = Colors.red;


class QuizResultsScreen extends StatelessWidget {
  final Quiz quiz;
  final int userScore;
  final Map<String, List<String>> userAnswers; // questionId -> list of selected optionId(s)

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.userScore,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quiz.questions.length;
    final percentage = totalQuestions > 0 ? (userScore / totalQuestions * 100).round() : 0;
    bool passed = percentage >= 50; // Définissez votre critère de réussite

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de bouton retour automatique
        title: Text(
          "Résultats du Quiz",
          style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              quiz.title,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textDarkColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Affichage du score de manière visuelle (Cercle ou Barre de progression)
            _buildScoreIndicator(percentage, passed),
            const SizedBox(height: 16),
            Text(
              passed ? "Félicitations, vous avez réussi !" : "Dommage, essayez encore !",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: passed ? correctAnswerColor : primaryAppColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Votre score : $userScore / $totalQuestions ($percentage%)",
              style: GoogleFonts.poppins(fontSize: 16, color: textDarkColor),
            ),
            const SizedBox(height: 30),
            Text(
              "Révision des réponses :",
              style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: textDarkColor),
            ),
            const SizedBox(height: 16),
            _buildAnswersReview(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              label: Text("Retour à l'accueil", style: GoogleFonts.poppins(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAppColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                // Naviguer vers l'accueil ou la page des cours
                Navigator.of(context).popUntil((route) => route.isFirst); // Revient à la première route
                // Ou si vous avez des routes nommées:
                // Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
              },
            ),
             const SizedBox(height: 10),
             TextButton(
                onPressed: () {
                // Permettre de relancer le quiz.
                // Vous devrez peut-être recréer QuizScreen ou réinitialiser son état.
                // La façon la plus simple est de pop jusqu'à la page précédente (détails du cours ou liste de quiz)
                // et de permettre à l'utilisateur de relancer à partir de là.
                // Ou si QuizScreen est toujours dans la pile: Navigator.pop(context); et gérer la relance.
                 if(Navigator.canPop(context)){
                    Navigator.pop(context); // Retourne à l'écran précédent (probablement le quiz lui-même pour relancer)
                    // Potentiellement envoyer un signal pour relancer si QuizScreen n'est pas recréé.
                 } else {
                     // Logique pour démarrer un nouveau quiz de la liste si on ne peut pas pop.
                 }

                },
                child: Text(
                    "Relancer le Quiz",
                    style: GoogleFonts.poppins(color: primaryAppColor, fontWeight: FontWeight.w500),
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int percentage, bool passed) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(passed ? correctAnswerColor : primaryAppColor),
          ),
          Center(
            child: Text(
              "$percentage%",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: passed ? correctAnswerColor : primaryAppColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersReview() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quiz.questions.length,
      itemBuilder: (context, index) {
        final question = quiz.questions[index];
        final selectedIds = userAnswers[question.id] ?? [];
        final correctIds = question.options.where((o) => o.isCorrect).map((o) => o.id).toList();

        bool isQuestionCorrect;
        if(question.type == QuestionType.singleChoice) {
            isQuestionCorrect = selectedIds.isNotEmpty && correctIds.contains(selectedIds.first);
        } else {
            isQuestionCorrect = selectedIds.length == correctIds.length && selectedIds.every((id) => correctIds.contains(id));
        }


        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isQuestionCorrect ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                      color: isQuestionCorrect ? correctAnswerColor : wrongAnswerColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Q${index + 1}: ${question.questionText}",
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textDarkColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Votre réponse :", style: GoogleFonts.poppins(fontSize: 13, color: textGreyColor)),
                ...question.options.where((opt) => selectedIds.contains(opt.id)).map(
                  (opt) => Text("  - ${opt.text}", style: GoogleFonts.poppins(color: isQuestionCorrect && opt.isCorrect ? correctAnswerColor : (opt.isCorrect ? textDarkColor : wrongAnswerColor )))).toList(),
                if (selectedIds.isEmpty) Text("  - (Pas de réponse)", style: GoogleFonts.poppins(fontStyle: FontStyle.italic, color: textGreyColor)),
                const SizedBox(height: 6),
                if(!isQuestionCorrect) ...[
                    Text("Réponse correcte :", style: GoogleFonts.poppins(fontSize: 13, color: textGreyColor, fontWeight: FontWeight.bold)),
                    ...question.options.where((opt) => opt.isCorrect).map(
                    (opt) => Text("  - ${opt.text}", style: GoogleFonts.poppins(color: correctAnswerColor, fontWeight: FontWeight.w500))).toList(),
                    const SizedBox(height: 4),
                ],
                 if (question.explanation != null) ...[
                    ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text("Voir l'explication", style: GoogleFonts.poppins(fontSize: 13, color: primaryAppColor)),
                        children: [
                             Padding(
                               padding: const EdgeInsets.only(top:4.0),
                               child: Text(question.explanation!, style: GoogleFonts.poppins(color: textDarkColor.withOpacity(0.9))),
                             )
                        ],
                    )
                 ]
              ],
            ),
          ),
        );
      },
    );
  }
}