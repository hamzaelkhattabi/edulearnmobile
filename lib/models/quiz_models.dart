// lib/models/quiz_models.dart

// Pour afficher une liste de quiz (QuizListScreen)
class QuizInfoModel {
  final int quizId; // Quiz.id
  final int? courseId; // Quiz.cours_id
  final String courseName; // Course.titre (via jointure)
  final String quizName; // Quiz.titre
  final int totalQuestions; // Calculé (nombre de QuestionsQuiz)
  final String? description; // Quiz.description
  double? score; // TentativesQuiz.score_obtenu (la dernière ou la meilleure)
  bool? isPassed; // Calculé à partir du score et Quiz.seuil_reussite_pourcentage

  QuizInfoModel({
    required this.quizId,
    this.courseId,
    required this.courseName,
    required this.quizName,
    required this.totalQuestions,
    this.description,
    this.score,
    this.isPassed,
  });

  // Sera rempli par le service en combinant les infos de Quiz et TentativesQuiz
  factory QuizInfoModel.fromJson(Map<String, dynamic> json) {
    // Ceci est une simplification. Votre API devra fournir ces données agrégées.
    // Si l'API renvoie directement la structure de la table Quiz et potentiellement une tentative associée :
    return QuizInfoModel(
      quizId: json['id'], // depuis la table Quiz
      courseId: json['cours_id'],
      courseName: json['Cour']?['titre'] ?? json['Lecon']?['Cour']?['titre'] ?? 'Cours Inconnu', // Nom du cours via jointure
      quizName: json['titre'],
      totalQuestions: (json['QuizQuestions'] as List?)?.length ?? json['total_questions_count'] ?? 0, // Si API renvoie le compte ou les questions
      description: json['description'],
      // score et isPassed seraient mis à jour à partir des données de tentatives si disponibles
      score: (json['latest_attempt']?['score_obtenu'] as num?)?.toDouble(),
      isPassed: json['latest_attempt'] != null && json['seuil_reussite_pourcentage'] != null
        ? ((json['latest_attempt']['score_obtenu'] as num? ?? 0.0) >= (json['seuil_reussite_pourcentage'] as num? ?? 101.0))
        : null,
    );
  }
}

class QuizOptionModel {
  final int id; // OptionsReponse.id (important pour l'envoi de la réponse)
  final String text; // OptionsReponse.texte_option
  final bool? isCorrect; // OptionsReponse.est_correcte (NE PAS envoyer au client pour un quiz en cours)

  QuizOptionModel({
    required this.id,
    required this.text,
    this.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json, {bool hideCorrectness = false}) {
    return QuizOptionModel(
      id: json['id'],
      text: json['texte_option'],
      isCorrect: hideCorrectness ? null : json['est_correcte'],
    );
  }
}

class QuizQuestionModel {
  final int id; // QuestionsQuiz.id
  final String questionText; // QuestionsQuiz.texte_question
  final String typeQuestion; // QuestionsQuiz.type_question (QCM, VRAI_FAUX, ...)
  final int order; // QuestionsQuiz.ordre
  final String? imagePath; // Si une image est associée à la question
  final List<QuizOptionModel> options;
  final String? explanation; // Explication après réponse (pas dans votre BDD actuelle)

  QuizOptionModel? selectedOption; // Pour QuizAttemptScreen & QuizResultScreen

  QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.typeQuestion,
    required this.order,
    this.imagePath,
    this.options = const [],
    this.explanation,
    this.selectedOption,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json, {bool hideCorrectness = false}) {
    var optionsList = <QuizOptionModel>[];
    if (json['ResponseOptions'] != null) {
      optionsList = (json['ResponseOptions'] as List)
          .map((o) => QuizOptionModel.fromJson(o, hideCorrectness: hideCorrectness))
          .toList();
    }
    return QuizQuestionModel(
      id: json['id'],
      questionText: json['texte_question'],
      typeQuestion: json['type_question'],
      order: json['ordre'],
      imagePath: json['image_url_question'], // A ajouter si besoin
      options: optionsList,
      explanation: json['explication_reponse'], // A ajouter si besoin
    );
  }
}

// Pour prendre un quiz (QuizAttemptScreen) et voir les résultats (QuizResultScreen)
class QuizAttemptModel {
  final int quizId;
  final int? courseId;
  final String? courseName;
  final String quizName;
  final String? description;
  final int totalQuestions;
  final List<QuizQuestionModel> questions;
  final double? score; // score_obtenu
  final bool? isPassed; // calculé
  final DateTime? attemptDate; // date_tentative
  final int? attemptId; // TentativesQuiz.id

  QuizAttemptModel({
    required this.quizId,
    this.courseId,
    this.courseName,
    required this.quizName,
    this.description,
    required this.totalQuestions,
    required this.questions,
    this.score,
    this.isPassed,
    this.attemptDate,
    this.attemptId,
  });

  // Utilisé pour démarrer une tentative (pas de score, isPassed, attemptDate)
  // et pour afficher les résultats (tous les champs remplis)
  factory QuizAttemptModel.fromQuizJson(Map<String, dynamic> json, {bool forTakingQuiz = true}) {
     // "forTakingQuiz = true" signifie que les bonnes réponses ne sont pas révélées dans les options
    var questionsList = <QuizQuestionModel>[];
    if (json['QuizQuestions'] != null) {
      questionsList = (json['QuizQuestions'] as List)
          .map((q) => QuizQuestionModel.fromJson(q, hideCorrectness: forTakingQuiz))
          .toList();
    }
    return QuizAttemptModel(
      quizId: json['id'],
      courseId: json['cours_id'],
      courseName: json['Cour']?['titre'] ?? json['Lecon']?['Cour']?['titre'] ?? 'Cours Inconnu',
      quizName: json['titre'],
      description: json['description'],
      totalQuestions: questionsList.length,
      questions: questionsList,
      // Les champs score, isPassed, attemptDate seront remplis par `fromAttemptJson` ou après soumission.
    );
  }

  // Utilisé pour afficher une tentative existante avec ses réponses et son score
  factory QuizAttemptModel.fromAttemptJson(Map<String, dynamic> attemptJson, Map<String, dynamic> quizJson) {
    var questionsList = <QuizQuestionModel>[];
    if (quizJson['QuizQuestions'] != null) {
       questionsList = (quizJson['QuizQuestions'] as List).map((qJson) {
        final questionModel = QuizQuestionModel.fromJson(qJson, hideCorrectness: false); // On montre les bonnes réponses pour la revue

        // Trouver la réponse de l'utilisateur pour cette question dans attemptJson['reponses_utilisateur']
        // Format supposé de reponses_utilisateur: [{ "question_id": X, "option_id": Y}, ...]
        final userAnswers = attemptJson['reponses_utilisateur'] as List<dynamic>?;
        final userAnswerForThisQuestion = userAnswers?.firstWhere(
            (ans) => ans['question_id'] == questionModel.id,
            orElse: () => null,
        );

        if (userAnswerForThisQuestion != null && userAnswerForThisQuestion['option_id'] != null) {
          questionModel.selectedOption = questionModel.options.firstWhere(
              (opt) => opt.id == userAnswerForThisQuestion['option_id'],
              orElse: () => throw Exception('Option not found for question ${questionModel.id}')
          );
        }
        return questionModel;
      }).toList();
    }

    return QuizAttemptModel(
      attemptId: attemptJson['id'],
      quizId: attemptJson['quiz_id'],
      courseId: quizJson['cours_id'], // Ou prendre de quizJson['Lecon']['cours_id']
      courseName: quizJson['Cour']?['titre'] ?? quizJson['Lecon']?['Cour']?['titre'] ?? 'Cours Inconnu',
      quizName: quizJson['titre'],
      description: quizJson['description'],
      totalQuestions: questionsList.length,
      questions: questionsList,
      score: (attemptJson['score_obtenu'] as num?)?.toDouble(),
      isPassed: attemptJson['score_obtenu'] != null && quizJson['seuil_reussite_pourcentage'] != null
        ? ((attemptJson['score_obtenu'] as num) >= (quizJson['seuil_reussite_pourcentage'] as num))
        : null,
      attemptDate: DateTime.parse(attemptJson['date_tentative']),
    );
  }
}