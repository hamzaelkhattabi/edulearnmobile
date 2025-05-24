// lib/models/quiz_models.dart

// Type de question pour plus de flexibilité future
enum QuestionType { singleChoice, multipleChoice, trueFalse }

class QuizOption {
  final String id; // Optionnel, pour identifier l'option
  final String text;
  bool isCorrect; // Utilisé pour vérifier la réponse

  QuizOption({required this.id, required this.text, this.isCorrect = false});
}

class QuizQuestion {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<QuizOption> options;
  final String? explanation; // Explication de la réponse correcte
  final String? imageAsset;  // Image optionnelle pour la question

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.type,
    required this.options,
    this.explanation,
    this.imageAsset,
  });
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final Duration? timeLimit; // Temps limite pour le quiz entier

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit,
  });
}