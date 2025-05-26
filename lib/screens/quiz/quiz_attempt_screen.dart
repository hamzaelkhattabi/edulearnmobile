import 'dart:convert'; // For jsonEncode in QuizService
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_models.dart';
import '../../utils/app_colors.dart';
import '../../services/quiz_service.dart';
import '../../utils/api_constants.dart';
import 'quiz_result_screen.dart';

class QuizAttemptScreen extends StatefulWidget {
  final QuizAttemptModel quizAttemptInput; // Reçu avec les questions

  const QuizAttemptScreen({super.key, required this.quizAttemptInput});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  // Map<questionId, optionId> pour les réponses QCM
  Map<int, int> _selectedOptionAnswers = {};
  // Map<questionId, String> pour les réponses textuelles (si vous les implémentez)
  // Map<int, String> _textAnswers = {};

  bool _isSubmitting = false;
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Initialiser _selectedOptionAnswers si des réponses ont été sauvegardées (pour "reprendre un quiz")
    // Pour l'instant, on commence un nouveau quiz à chaque fois.
    if (widget.quizAttemptInput.questions.isEmpty) { // <<< VÉRIFICATION IMPORTANTE
      print("ERREUR QuizAttemptScreen: Le quiz reçu n'a AUCUNE question !");
      // Gérer ce cas : afficher un message, pop la route ?
      // Pour l'instant, on va laisser le build planter pour voir l'erreur, mais c'est ici le problème.
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quizAttemptInput.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _confirmSubmitQuiz(); // Demander confirmation avant de soumettre
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

  void _confirmSubmitQuiz() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer le Quiz?'),
        content: const Text('Êtes-vous sûr de vouloir soumettre vos réponses?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Annuler'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Soumettre'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitQuiz();
            },
          ),
        ],
      ),
    );
  }


  Future<void> _submitQuiz() async {
    setState(() { _isSubmitting = true; });

    List<Map<String, dynamic>> userAnswersPayload = [];
    _selectedOptionAnswers.forEach((questionId, optionId) {
      userAnswersPayload.add({'question_id': questionId, 'option_id': optionId});
    });
    // Ajouter les réponses textuelles si implémenté

    try {
      // `submitQuizAttempt` renvoie la réponse brute du backend
      // qui contient les détails de la tentative, score, etc.
      final submissionResult = await _quizService.submitQuizAttempt(
          widget.quizAttemptInput.quizId, userAnswersPayload);
      
      // L'API backend dans TentativesQuiz Controller renvoie:
      // { attempt (TentativesQuiz), score, totalPossibleScore, scorePourcentage, passed }
      // Nous devons utiliser 'attempt' et 'quiz (de widget.quizAttemptInput)' pour construire le QuizAttemptModel pour QuizResultScreen
      // ou modifier `QuizAttemptModel.fromAttemptJson` pour prendre la réponse directe de `submitQuizAttempt`.

      // Simplifions: On va reconstruire un `QuizAttemptModel` pour l'écran de résultat.
      // Pour cela, nous aurions besoin des détails complets des questions AVEC les bonnes réponses
      // et les réponses de l'utilisateur. L'objet `submissionResult['attempt']['reponses_utilisateur']` contient les réponses de l'utilisateur.
      // Il faudrait aussi les définitions complètes des questions (avec `isCorrect`)

      // Pour un affichage correct dans QuizResultScreen, on a besoin des questions initiales
      // avec les `selectedOption` mis à jour.
       List<QuizQuestionModel> questionsWithUserSelections = widget.quizAttemptInput.questions.map((q) {
          QuizOptionModel? selectedOpt;
          if (_selectedOptionAnswers.containsKey(q.id)) {
            selectedOpt = q.options.firstWhere(
              (opt) => opt.id == _selectedOptionAnswers[q.id],
              orElse: () => QuizOptionModel(id: -1, text: '', isCorrect: false),
            );
            if (selectedOpt.id == -1) {
              selectedOpt = null;
            }
          }
          return QuizQuestionModel( // Créer une nouvelle instance ou utiliser copyWith
            id: q.id,
            questionText: q.questionText,
            typeQuestion: q.typeQuestion,
            order: q.order,
            options: q.options.map((opt) => QuizOptionModel(id: opt.id, text: opt.text, isCorrect: opt.isCorrect)).toList(), // S'assurer que isCorrect est bien là
            explanation: q.explanation, // Si disponible
            imagePath: q.imagePath,
            selectedOption: selectedOpt,
          );
        }).toList();


      final QuizAttemptModel completedQuizResult = QuizAttemptModel(
        quizId: widget.quizAttemptInput.quizId,
        attemptId: submissionResult['attempt']['id'], // ID de la tentative
        courseId: widget.quizAttemptInput.courseId,
        courseName: widget.quizAttemptInput.courseName,
        quizName: widget.quizAttemptInput.quizName,
        totalQuestions: questionsWithUserSelections.length,
        description: widget.quizAttemptInput.description,
        questions: questionsWithUserSelections, // questions initiales avec la sélection de l'utilisateur
        score: (submissionResult['scorePourcentage'] as num?)?.toDouble(),
        isPassed: submissionResult['passed'] as bool?,
        attemptDate: DateTime.parse(submissionResult['attempt']['date_tentative'])
      );
      
      if(mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(quizResult: completedQuizResult),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de soumission: ${e.toString()}"), backgroundColor: eduLearnError),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // final currentQuestion = widget.quizAttemptInput.questions[_currentQuestionIndex];
    if (widget.quizAttemptInput.questions.isEmpty) { // Sécurité supplémentaire
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizAttemptInput.quizName)),
        body: Center(
          child: Text(
            "Ce quiz ne contient actuellement aucune question.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final currentQuestion = widget.quizAttemptInput.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: eduLearnBackground,
      appBar: AppBar(
        backgroundColor: eduLearnCardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: eduLearnTextBlack),
          onPressed: () {
            // Confirmation avant de quitter si des réponses ont été faites
            if(_selectedOptionAnswers.isNotEmpty) {
                 showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                        title: const Text('Quitter le Quiz?'),
                        content: const Text('Votre progression ne sera pas sauvegardée.'),
                        actions: <Widget>[
                        TextButton(
                            child: const Text('Rester'),
                            onPressed: () { Navigator.of(ctx).pop(); },
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: eduLearnError),
                            child: const Text('Quitter'),
                            onPressed: () {
                                Navigator.of(ctx).pop(); // Ferme le dialog
                                Navigator.of(context).pop(); // Ferme l'écran du quiz
                            },
                        ),
                        ],
                    ),
                );
            } else {
                Navigator.of(context).pop();
            }
          }
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quizAttemptInput.quizName,
              style: GoogleFonts.poppins(
                  color: eduLearnTextBlack, fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Question ${_currentQuestionIndex + 1}/${widget.quizAttemptInput.questions.length}",
              style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
            ),
          ],
        ),
        actions: [
          if (!_isSubmitting)
            TextButton(
              onPressed: _confirmSubmitQuiz,
              child: Text(
                "Terminer",
                style: GoogleFonts.poppins(color: eduLearnPrimary, fontWeight: FontWeight.w600),
              ),
            )
          else Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(eduLearnPrimary))),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quizAttemptInput.questions.length,
            backgroundColor: eduLearnAccent.withOpacity(0.5),
            valueColor: const AlwaysStoppedAnimation<Color>(eduLearnPrimary),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.quizAttemptInput.questions.length,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final question = widget.quizAttemptInput.questions[index];
                return _buildQuestionCard(question);
              },
            ),
          ),
          _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestionModel question) {
    String? questionImagePath = question.imagePath;
    if (questionImagePath != null && !questionImagePath.startsWith('http') && !questionImagePath.startsWith('assets/')) {
        questionImagePath = ApiConstants.baseUrl.replaceAll("/api", "") + (questionImagePath.startsWith('/') ? questionImagePath : '/$questionImagePath');
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (questionImagePath != null && questionImagePath.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              child: questionImagePath.startsWith('assets/')
                  ? Image.asset( questionImagePath, height: 180, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _imageErrorPlaceholder())
                  : Image.network( questionImagePath, height: 180, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _imageErrorPlaceholder()),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            question.questionText,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w500, color: eduLearnTextBlack, height: 1.4),
          ),
          const SizedBox(height: 24),
          if (question.typeQuestion == 'QCM' || question.typeQuestion == 'VRAI_FAUX')
            ...question.options.map((option) {
              bool isSelected = _selectedOptionAnswers[question.id] == option.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: _isSubmitting ? null : () {
                    setState(() {
                      _selectedOptionAnswers[question.id] = option.id;
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
          // TODO: Ajouter un widget pour REPONSE_COURTE si nécessaire
          // if (question.typeQuestion == 'REPONSE_COURTE') ... [],
        ],
      ),
    );
  }

  Widget _imageErrorPlaceholder(){
     return Container(
      height: 180, color: Colors.grey.shade200,  width: double.infinity,
      child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey)),
    );
  }


  Widget _buildNavigationControls() {
    bool isLastQuestion = _currentQuestionIndex == widget.quizAttemptInput.questions.length - 1;
    bool currentQuestionAnswered = _selectedOptionAnswers.containsKey(widget.quizAttemptInput.questions[_currentQuestionIndex].id);
    // Ou une vérification plus complexe si différents types de questions

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
            onPressed: (_currentQuestionIndex > 0 && !_isSubmitting) ? _previousQuestion : null,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: _currentQuestionIndex > 0 ? eduLearnPrimary : Colors.grey),
            label: Text("Précédent", style: GoogleFonts.poppins(color: _currentQuestionIndex > 0 ? eduLearnPrimary : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: (currentQuestionAnswered && !_isSubmitting) ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              // backgroundColor handled by theme, but can be conditional:
              // backgroundColor: (currentQuestionAnswered && !_isSubmitting) ? eduLearnPrimary : Colors.grey.shade300,
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