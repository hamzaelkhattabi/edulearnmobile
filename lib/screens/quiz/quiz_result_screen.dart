import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_models.dart'; // QuizAttemptModel, QuizQuestionModel, QuizOptionModel
import '../../models/certificate_model.dart'; // Pour la navigation potentielle vers un certificat
import '../../services/quiz_service.dart'; // Pour relancer un quiz
import '../../utils/app_colors.dart';
import 'quiz_attempt_screen.dart';
// import '../certificate/certificate_view_screen.dart'; // Si vous avez un certificat à afficher

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptModel quizResult; // Ce modèle contient maintenant les questions avec selectedOption et le score

  const QuizResultScreen({super.key, required this.quizResult});

  @override
  Widget build(BuildContext context) {
    final QuizService quizService = QuizService(); // Pour relancer le quiz

    int correctAnswers = 0;
    // Les bonnes réponses sont DANS chaque `question.options.firstWhere((o) => o.isCorrect)`.
    // `isCorrect` doit être présent dans `quizResult.questions[...].options[...]`
    for (var question in quizResult.questions) {
        if (question.selectedOption != null) {
          final correctOptionForQuestion = question.options.firstWhere((opt) => opt.isCorrect == true, orElse: () => QuizOptionModel(id:-1, text: "Dummy", isCorrect:false));
          if (question.selectedOption!.id == correctOptionForQuestion.id) {
            correctAnswers++;
          }
        }
    }

    // Le score et isPassed devraient être directement ceux de quizResult, fournis par l'API
    final score = quizResult.score ?? 0.0;
    final isPassed = quizResult.isPassed ?? false;

    return Scaffold(
      backgroundColor: eduLearnBackground,
      appBar: AppBar(
        // backgroundColor: eduLearnBackground,
        elevation: 0.5, // Petit effet
        automaticallyImplyLeading: false,
        title: Text("Résultats du Quiz"),
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
            if (isPassed)
              ElevatedButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text("Voir mon Certificat (si disponible)"),
                onPressed: () {
                  // TODO: Vérifier si un certificat est lié à ce quiz/cours ET si l'API a généré un
                  // UserCertificate. Si oui, charger et naviguer vers CertificateViewScreen.
                  // Cela impliquerait d'avoir l'ID du CertificatsUtilisateur depuis l'API
                  // suite à la réussite du quiz (peut-être dans la réponse de submitQuizAttempt)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Recherche de certificat à implémenter..."))
                  );
                  // Example (nécessite CertificateModel du certificat obtenu):
                  // CertificateModel cert = await _certificateService.findCertificateForQuiz(quizResult.quizId);
                  // if (cert != null) Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateViewScreen(certificate: cert)));
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
                onPressed: () async {
                  try {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rechargement du quiz...")));
                    // Recréer un QuizAttemptModel "frais" en allant chercher les questions de l'API
                    QuizAttemptModel newAttempt = await quizService.getQuizForAttempt(quizResult.quizId);
                    if (context.mounted) {
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizAttemptScreen(quizAttemptInput: newAttempt)));
                    }
                  } catch (e) {
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur au rechargement: $e"), backgroundColor: eduLearnError));
                     }
                  }
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
                Navigator.of(context).popUntil((route) {
                  // Pop jusqu'à ce qu'on trouve la route '/quiz_list' ou qu'on soit à la racine.
                  // Cela évite de pousser une nouvelle instance de QuizListScreen si elle est déjà dans la pile.
                  return route.settings.name == '/quiz_list' || route.isFirst;
                });
                // Si QuizListScreen n'était pas dans la pile (on est revenu à la racine sans la trouver)
                // et qu'on n'est pas déjà sur elle, on la push.
                // Cela peut arriver si on accède à un quiz via un lien direct ou une notification.
                // Pour l'instant, on assume qu'on pop juste. S'il faut toujours y aller:
                // Navigator.of(context).pushNamedAndRemoveUntil('/quiz_list', (route) => false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: eduLearnPrimary, side: const BorderSide(color: eduLearnPrimary),
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
    // Identique à votre code, pas besoin de changement majeur
     return Container( /* ... votre code ... */ );
  }

  Widget _buildScoreSummary(int correct, int total) {
    // Identique à votre code
     return Row( /* ... votre code ... */ );
  }

   Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    // Identique
     return Column( /* ... votre code ... */ );
  }


  Widget _buildAnswersReview() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quizResult.questions.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final question = quizResult.questions[index]; // Ceci est un QuizQuestionModel
        final selectedOptByUser = question.selectedOption; // L'option choisie par l'utilisateur

        // Trouver la bonne réponse parmi les options de la question
        // Assurez-vous que 'isCorrect' est disponible dans le modèle `question.options`
        final correctOptionDef = question.options.firstWhere(
          (opt) => opt.isCorrect == true, // isCorrect DOIT être non null ici
          orElse: () => QuizOptionModel(id:-1, text:"NO_CORRECT_DEF", isCorrect: false) // Fallback au cas où
        );

        Color getOptionColor(QuizOptionModel optionFromList) {
          bool isThisOptionSelectedByUser = selectedOptByUser?.id == optionFromList.id;
          bool isThisOptionTheCorrectOne = optionFromList.id == correctOptionDef.id; // Comparer les IDs

          if (isThisOptionSelectedByUser) {
            return isThisOptionTheCorrectOne ? eduLearnSuccess : eduLearnError;
          } else if (isThisOptionTheCorrectOne) {
            return eduLearnSuccess.withOpacity(0.7);
          }
          return eduLearnTextGrey;
        }

        IconData getOptionIcon(QuizOptionModel optionFromList) {
          bool isThisOptionSelectedByUser = selectedOptByUser?.id == optionFromList.id;
          bool isThisOptionTheCorrectOne = optionFromList.id == correctOptionDef.id;

          if (isThisOptionSelectedByUser) {
            return isThisOptionTheCorrectOne ? Icons.check_circle_rounded : Icons.cancel_rounded;
          } else if (isThisOptionTheCorrectOne) {
            // C'est la bonne réponse, mais l'utilisateur ne l'a pas choisie
            return Icons.radio_button_off_rounded; // ou Icons.check_box_outline_blank pour QCM multiple si besoin
          }
          return Icons.radio_button_off_rounded; // Option non choisie et non correcte
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
            // Afficher l'explication si l'utilisateur s'est trompé ET si une explication existe
            if (question.explanation != null && question.explanation!.isNotEmpty &&
                selectedOptByUser != null && selectedOptByUser.id != correctOptionDef.id) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: eduLearnInfo.withOpacity(0.1), // Utiliser une couleur pour "info"
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: eduLearnInfo.withOpacity(0.5))
                ),
                child: Text(
                  "Explication: ${question.explanation}",
                  style: GoogleFonts.poppins(fontSize: 13, color: eduLearnInfoDark), // Une couleur de texte appropriée
                ),
              )
            ]
          ],
        );
      },
    );
  }
}