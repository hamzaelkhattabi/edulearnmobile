import 'package:flutter/foundation.dart';

// Correspond à une option de réponse pour une question
class QuizOptionModel {
  final String text;
  final bool isCorrect; // Pour la vérification côté client (optionnel) ou après soumission

  QuizOptionModel({required this.text, this.isCorrect = false});
}

// Correspond à une question dans un quiz
class QuizQuestionModel {
  final String id; // Ou int, selon votre backend
  final String questionText;
  final List<QuizOptionModel> options;
  final String? explanation; // Explication après avoir répondu
  final String? imagePath; // Image optionnelle pour la question

  // Pour suivre la réponse de l'utilisateur
  QuizOptionModel? selectedOption;

  QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    this.explanation,
    this.imagePath,
    this.selectedOption,
  });
}

// Informations générales sur un quiz, correspond à `UserQuizInfo` de quiz.ts
class QuizInfoModel {
  final int quizId;
  final int courseId;
  final String courseName;
  final String quizName;
  final double? score; // Score obtenu, peut être nul si pas encore tenté
  final bool? isPassed; // Si le quiz a été réussi, peut être nul
  final int totalQuestions; // Nombre total de questions dans ce quiz
  final String? description; // Description du quiz

  QuizInfoModel({
    required this.quizId,
    required this.courseId,
    required this.courseName,
    required this.quizName,
    this.score,
    this.isPassed,
    required this.totalQuestions,
    this.description,
  });

  // Factory constructor pour créer depuis un JSON (venant de l'API web)
  factory QuizInfoModel.fromWebJson(Map<String, dynamic> json) {
    return QuizInfoModel(
      quizId: json['quizId'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      quizName: json['quizName'],
      score: (json['score'] as num?)?.toDouble(),
      isPassed: json['isPassed'],
      totalQuestions: json['totalQuestions'],
      description: json['description'],
    );
  }
}

// Modèle pour un quiz en cours de tentative, incluant ses questions
class QuizAttemptModel extends QuizInfoModel {
  final List<QuizQuestionModel> questions;

  QuizAttemptModel({
    required super.quizId,
    required super.courseId,
    required super.courseName,
    required super.quizName,
    super.score,
    super.isPassed,
    required super.totalQuestions,
    super.description,
    required this.questions,
  });

  // Potentiellement un factory constructor pour charger les détails d'un quiz spécifique
  // depuis une API, incluant ses questions.
}