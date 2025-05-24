import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Pour le minuteur

// Importez vos modèles
import '../../../models/quiz_models.dart';
import './quiz_results_screen.dart'; // Nous créerons cet écran ensuite

// Couleurs (vous pouvez les centraliser)
const Color primaryAppColor = Color(0xFFF45B69);
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;
const Color correctAnswerColor = Colors.green;
const Color wrongAnswerColor = Colors.red;
const Color neutralOptionColor = Color(0xFFECEFF1); // Gris clair pour les options non sélectionnées

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<String, List<String>> _selectedAnswers = {}; // questionId -> list of selected optionId(s)
  Timer? _timer;
  int _timeRemainingInSeconds = 0;

  bool _showAnswer = false; // Pour afficher la correction après la réponse
  String? _feedbackMessage;  // Feedback "Correct!" ou "Incorrect!"

  @override
  void initState() {
    super.initState();
    if (widget.quiz.timeLimit != null) {
      _timeRemainingInSeconds = widget.quiz.timeLimit!.inSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingInSeconds > 0) {
        setState(() {
          _timeRemainingInSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitQuiz(); // Soumettre automatiquement si le temps est écoulé
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onOptionSelected(String questionId, QuizOption option, bool isSelected) {
    if (_showAnswer) return; // Ne pas permettre de changer de réponse après validation

    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    setState(() {
      if (currentQuestion.type == QuestionType.singleChoice) {
        if (isSelected) {
          _selectedAnswers[questionId] = [option.id];
        } else {
           _selectedAnswers.remove(questionId); // Ou ne rien faire si on ne peut pas déselectionner
        }
      } else if (currentQuestion.type == QuestionType.multipleChoice) {
        if (_selectedAnswers[questionId] == null) {
          _selectedAnswers[questionId] = [];
        }
        if (isSelected) {
          _selectedAnswers[questionId]!.add(option.id);
        } else {
          _selectedAnswers[questionId]!.remove(option.id);
        }
      }
    });
  }

  void _validateCurrentAnswer() {
    if (_showAnswer) return; // Déjà validé

    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    List<String> correctOptionIds = currentQuestion.options
        .where((opt) => opt.isCorrect)
        .map((opt) => opt.id)
        .toList();
    List<String> selectedOptionIds = _selectedAnswers[currentQuestion.id] ?? [];

    bool isCorrect;
    if (currentQuestion.type == QuestionType.singleChoice) {
      isCorrect = selectedOptionIds.isNotEmpty && correctOptionIds.contains(selectedOptionIds.first);
    } else { // MultipleChoice (simplifié : toutes les correctes et aucune incorrecte)
      isCorrect = selectedOptionIds.length == correctOptionIds.length &&
                  selectedOptionIds.every((id) => correctOptionIds.contains(id));
    }

    setState(() {
      _showAnswer = true;
      _feedbackMessage = isCorrect ? "Correct !" : "Incorrect.";
    });

    // Optionnel : Aller à la suivante automatiquement après un délai
    // Future.delayed(Duration(seconds: 2), () {
    //   _nextQuestion();
    // });
  }


  void _nextQuestion() {
    setState(() {
      _showAnswer = false; // Réinitialiser pour la nouvelle question
      _feedbackMessage = null;
      if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Fin du quiz
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    _timer?.cancel(); // Arrêter le minuteur
    // Calculer le score final (ceci est une version simplifiée)
    int score = 0;
    widget.quiz.questions.asMap().forEach((index, question) {
      List<String> correctOptionIds = question.options
          .where((opt) => opt.isCorrect)
          .map((opt) => opt.id)
          .toList();
      List<String> selectedUserOptions = _selectedAnswers[question.id] ?? [];

      if (question.type == QuestionType.singleChoice) {
        if (selectedUserOptions.isNotEmpty && correctOptionIds.contains(selectedUserOptions.first)) {
          score++;
        }
      } else if (question.type == QuestionType.multipleChoice) {
         // Pour choix multiples, toutes les réponses correctes doivent être sélectionnées et aucune incorrecte
        bool allCorrectSelected = correctOptionIds.every((id) => selectedUserOptions.contains(id));
        bool noIncorrectSelected = selectedUserOptions.every((id) => correctOptionIds.contains(id)); // ou !question.options.firstWhere((o) => o.id == id).isCorrect
        if (selectedUserOptions.length == correctOptionIds.length && allCorrectSelected && noIncorrectSelected) {
             score++;
        }
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          quiz: widget.quiz,
          userScore: score,
          userAnswers: _selectedAnswers,
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    final List<String> currentSelectedOptionIds = _selectedAnswers[currentQuestion.id] ?? [];

    return WillPopScope(
      onWillPop: () async {
        // Demander confirmation avant de quitter
        bool? leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le Quiz ?'),
            content: const Text('Votre progression sera perdue. Êtes-vous sûr ?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Non')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Oui')),
            ],
          ),
        );
        return leave ?? false;
      },
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: cardBackgroundColor,
          elevation: 0.5,
          title: Text(widget.quiz.title, style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600)),
          actions: [
            if (widget.quiz.timeLimit != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    _formatDuration(_timeRemainingInSeconds),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _timeRemainingInSeconds < 60 ? Colors.redAccent : primaryAppColor),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Indicateur de Progression
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}",
                    style: GoogleFonts.poppins(fontSize: 14, color: textGreyColor),
                  ),
                   LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(primaryAppColor),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentQuestion.imageAsset != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            currentQuestion.imageAsset!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (c,e,s) => Container(height:180, child: Center(child: Text("Image non chargée")))
                          ),
                        ),
                      ),
                    Text(
                      currentQuestion.questionText,
                      style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w600, color: textDarkColor, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    ...currentQuestion.options.map((option) {
                      bool isSelected = currentSelectedOptionIds.contains(option.id);
                      Color? tileColor;
                      Color? borderColor;

                      if (_showAnswer) {
                        if (option.isCorrect) {
                          tileColor = correctAnswerColor.withOpacity(0.15);
                          borderColor = correctAnswerColor;
                        } else if (isSelected && !option.isCorrect) {
                          tileColor = wrongAnswerColor.withOpacity(0.15);
                          borderColor = wrongAnswerColor;
                        }
                      } else {
                         if(isSelected) {
                           tileColor = primaryAppColor.withOpacity(0.1);
                           borderColor = primaryAppColor;
                         }
                      }

                      return Card(
                        elevation: 0, // Ou une petite élévation si vous préférez
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: borderColor ?? Colors.grey.shade300,
                            width: _showAnswer && (option.isCorrect || isSelected) ? 1.5 : 1,
                          ),
                        ),
                        color: tileColor ?? cardBackgroundColor,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(option.text, style: GoogleFonts.poppins(color: textDarkColor, fontSize: 15)),
                          onTap: () => _onOptionSelected(currentQuestion.id, option, !isSelected),
                          leading: currentQuestion.type == QuestionType.singleChoice
                              ? Radio<String>(
                                  value: option.id,
                                  groupValue: currentSelectedOptionIds.isNotEmpty ? currentSelectedOptionIds.first : null,
                                  onChanged: _showAnswer ? null : (String? value) {
                                    if (value != null) _onOptionSelected(currentQuestion.id, option, true);
                                  },
                                  activeColor: primaryAppColor,
                                )
                              : Checkbox(
                                  value: isSelected,
                                  onChanged: _showAnswer ? null : (bool? value) {
                                    if (value != null) _onOptionSelected(currentQuestion.id, option, value);
                                  },
                                  activeColor: primaryAppColor,
                                   side: BorderSide(color: borderColor ?? textGreyColor.withOpacity(0.5)),
                                ),
                        ),
                      );
                    }).toList(),

                    if (_showAnswer && currentQuestion.explanation != null)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueGrey.shade200)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text("Explication :", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textDarkColor)),
                             const SizedBox(height: 4),
                             Text(currentQuestion.explanation!, style: GoogleFonts.poppins(color: textDarkColor.withOpacity(0.8), height: 1.5)),
                          ],
                        ),
                      ),

                  ],
                ),
              ),
            ),
            // Pied de page avec les boutons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Logique pour soumettre directement si souhaité, ou pour revenir en arrière (avec confirmation)
                         Navigator.of(context).maybePop(); // Tente de revenir en arrière, géré par WillPopScope
                      },
                       style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryAppColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                         foregroundColor: primaryAppColor,
                      ),
                      child: const Text("Quitter"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_showAnswer)
                          ? _nextQuestion
                          : (currentSelectedOptionIds.isEmpty ? null : _validateCurrentAnswer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAppColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                         disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                          _showAnswer
                            ? (_currentQuestionIndex == widget.quiz.questions.length - 1 ? "Voir Résultats" : "Suivant")
                            : "Valider",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}