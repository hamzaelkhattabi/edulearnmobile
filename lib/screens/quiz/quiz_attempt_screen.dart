import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_model.dart';
import '../../utils/app_colors.dart';
import 'quiz_result_screen.dart'; // À créer

class QuizAttemptScreen extends StatefulWidget {
  final QuizAttemptModel quizAttempt;

  const QuizAttemptScreen({super.key, required this.quizAttempt});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  Map<int, QuizOptionModel> _selectedAnswers = {}; // index de question -> option choisie

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Pré-remplir les réponses si le quiz a déjà été tenté (pour review mode par ex.)
    // Pour un nouvel essai, _selectedAnswers sera vide.
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quizAttempt.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitQuiz() {
    int correctAnswers = 0;
    widget.quizAttempt.questions.asMap().forEach((index, question) {
      if (_selectedAnswers[index] != null && _selectedAnswers[index]!.isCorrect) {
        correctAnswers++;
      }
    });

    double score = (correctAnswers / widget.quizAttempt.questions.length) * 100;
    bool isPassed = score >= 70; // Seuil de réussite (peut être configurable)

    // Mettre à jour le modèle QuizAttemptModel avec les résultats
    // Dans une vraie app, vous enverriez ces données au backend (submitPassedQuiz)
    final QuizAttemptModel completedQuiz = QuizAttemptModel(
      quizId: widget.quizAttempt.quizId,
      courseId: widget.quizAttempt.courseId,
      courseName: widget.quizAttempt.courseName,
      quizName: widget.quizAttempt.quizName,
      totalQuestions: widget.quizAttempt.totalQuestions,
      description: widget.quizAttempt.description,
      questions: widget.quizAttempt.questions.map((q) {
        // Attribuer la selectedOption pour chaque question pour l'écran de résultat
        final index = widget.quizAttempt.questions.indexOf(q);
        return QuizQuestionModel(
          id: q.id,
          questionText: q.questionText,
          options: q.options,
          explanation: q.explanation,
          imagePath: q.imagePath,
          selectedOption: _selectedAnswers[index]
        );
      }).toList(),
      score: score,
      isPassed: isPassed,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(quizResult: completedQuiz),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quizAttempt.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: eduLearnBackground,
      appBar: AppBar(
        backgroundColor: eduLearnCardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: eduLearnTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quizAttempt.quizName,
              style: GoogleFonts.poppins(
                  color: eduLearnTextBlack, fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Question ${_currentQuestionIndex + 1}/${widget.quizAttempt.questions.length}",
              style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _submitQuiz,
            child: Text(
              "Terminer",
              style: GoogleFonts.poppins(color: eduLearnPrimary, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quizAttempt.questions.length,
            backgroundColor: eduLearnAccent,
            valueColor: const AlwaysStoppedAnimation<Color>(eduLearnPrimary),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.quizAttempt.questions.length,
              physics: const NeverScrollableScrollPhysics(), // Contrôlé par boutons
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final question = widget.quizAttempt.questions[index];
                return _buildQuestionCard(question, index);
              },
            ),
          ),
          _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestionModel question, int questionIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              child: Image.asset( // Ou Image.network si URL
                question.imagePath!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  height: 180, color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.questionText,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w500, color: eduLearnTextBlack, height: 1.4),
          ),
          const SizedBox(height: 24),
          ...question.options.map((option) {
            bool isSelected = _selectedAnswers[questionIndex] == option;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedAnswers[questionIndex] = option;
                  });
                },
                borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? eduLearnPrimary.withOpacity(0.1) : eduLearnCardBg,
                    borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                    border: Border.all(
                      color: isSelected ? eduLearnPrimary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? eduLearnPrimary : eduLearnTextGrey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: eduLearnTextBlack,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    bool isLastQuestion = _currentQuestionIndex == widget.quizAttempt.questions.length - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: eduLearnCardBg,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))],
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: _currentQuestionIndex > 0 ? eduLearnPrimary : Colors.grey),
            label: Text("Précédent", style: GoogleFonts.poppins(color: _currentQuestionIndex > 0 ? eduLearnPrimary : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _selectedAnswers[_currentQuestionIndex] != null ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: eduLearnPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
            ),
            child: Text(isLastQuestion ? "Soumettre" : "Suivant"),
          ),
        ],
      ),
    );
  }
}