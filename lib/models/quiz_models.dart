// lib/models/quiz_models.dart

// Pour afficher une liste de quiz (QuizListScreen)
class QuizInfoModel {
  final int quizId; // Quiz.id
  final int? courseId; // Quiz.cours_id ou via Lesson.cours_id
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

  factory QuizInfoModel.fromJson(Map<String, dynamic> json) {
    // Le backend pour `GET /api/quizzes` doit envoyer les champs formatés comme ça.
    // Le `exports.listAllMyQuizzes` que nous avons écrit essaie de faire ça.
    double? parsedScore;
    if (json['score'] != null) {
      if (json['score'] is String) {
        parsedScore = double.tryParse(json['score'] as String);
      } else if (json['score'] is num) {
        parsedScore = (json['score'] as num).toDouble();
      }
    }

    bool? parsedIsPassed;
    if (json['isPassed'] != null && json['isPassed'] is bool) {
        parsedIsPassed = json['isPassed'] as bool;
    } else if (parsedScore != null && json['seuil_reussite_pourcentage'] != null) {
        double seuil;
        if (json['seuil_reussite_pourcentage'] is String) {
            seuil = double.tryParse(json['seuil_reussite_pourcentage'] as String) ?? 101.0;
        } else if (json['seuil_reussite_pourcentage'] is num) {
            seuil = (json['seuil_reussite_pourcentage'] as num).toDouble();
        } else {
            seuil = 101.0; // Seuil impossible à atteindre si le format est inconnu
        }
        parsedIsPassed = parsedScore >= seuil;
    }


    return QuizInfoModel(
      quizId: json['quizId'] as int? ?? 0, // Doit venir du backend
      courseId: json['courseId'] as int?,
      courseName: json['courseName']?.toString() ?? 'Cours Inconnu',
      quizName: json['quizName']?.toString() ?? 'Quiz sans Titre',
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      description: json['description']?.toString(),
      score: parsedScore,
      isPassed: parsedIsPassed,
    );
  }
}

class QuizOptionModel {
  final int id; // OptionsReponse.id
  final String text; // OptionsReponse.texte_option
  final bool? isCorrect; // OptionsReponse.est_correcte

  QuizOptionModel({
    required this.id,
    required this.text,
    this.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json, {bool hideCorrectness = false}) {
    return QuizOptionModel(
      id: json['id'] as int? ?? 0, // Fallback pour ID
      text: json['texte_option']?.toString() ?? 'Option vide',
      isCorrect: hideCorrectness ? null : (json['est_correcte'] as bool?), // Laisser bool?
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
  final String? explanation; // Explication après réponse

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

  factory QuizQuestionModel.fromJson(Map<String, dynamic> qJson, {bool hideCorrectness = false}) {
    var optionsList = <QuizOptionModel>[];
    // La clé du JSON pour les options est "OptionsReponses" d'après vos logs
    if (qJson['OptionsReponses'] != null && qJson['OptionsReponses'] is List) {
      optionsList = (qJson['OptionsReponses'] as List<dynamic>)
          .map((oJson) {
            if (oJson is Map<String, dynamic>) {
              return QuizOptionModel.fromJson(oJson, hideCorrectness: hideCorrectness);
            }
            return null;
          })
          .whereType<QuizOptionModel>()
          .toList();
    } else {
      //  print("QuizQuestionModel.fromJson: Clé 'OptionsReponses' non trouvée ou n'est pas une liste pour la question ID ${qJson['id']}");
    }
    return QuizQuestionModel(
      id: qJson['id'] as int? ?? 0, // Fallback
      questionText: qJson['texte_question']?.toString() ?? 'Texte de question manquant',
      typeQuestion: qJson['type_question']?.toString() ?? 'QCM',
      order: qJson['ordre'] as int? ?? 0, // Fallback
      imagePath: qJson['image_url_question']?.toString(),
      options: optionsList,
      explanation: qJson['explication_reponse']?.toString(), // Si vous avez ce champ dans l'API
    );
  }
}

class QuizAttemptModel {
  final int? attemptId; // TentativesQuiz.id (nullable car on peut construire un QuizAttemptModel avant soumission)
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

  QuizAttemptModel({
    this.attemptId,
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
  });

  // Factory pour construire un modèle de tentative à partir des données d'un quiz (avant la tentative)
  factory QuizAttemptModel.fromQuizJson(Map<String, dynamic> quizJson, {bool forTakingQuiz = true}) {
    var questionsList = <QuizQuestionModel>[];
    // La clé du JSON pour les questions est "QuestionsQuizzes" d'après vos logs
    if (quizJson['QuestionsQuizzes'] != null && quizJson['QuestionsQuizzes'] is List) {
      questionsList = (quizJson['QuestionsQuizzes'] as List<dynamic>)
          .map((qJson) {
            if (qJson is Map<String, dynamic>) {
              return QuizQuestionModel.fromJson(qJson, hideCorrectness: forTakingQuiz);
            }
            return null;
          })
          .whereType<QuizQuestionModel>()
          .toList();
    } else {
      print("QuizAttemptModel.fromQuizJson: Clé 'QuestionsQuizzes' non trouvée ou pas une liste dans JSON: ${quizJson['id']}");
    }

    // Déterminer courseName et courseId
    String? tempCourseName;
    int? tempCourseId;

    if (quizJson['course'] != null && quizJson['course'] is Map<String,dynamic>) { // Quiz direct du cours
        tempCourseName = quizJson['course']['titre']?.toString();
        tempCourseId = quizJson['course']['id'] as int?;
    } else if (quizJson['lesson'] != null && quizJson['lesson'] is Map<String,dynamic>) { // Quiz de leçon
        tempCourseId = quizJson['lesson']['cours_id'] as int?; // Directement depuis la leçon
        if (quizJson['lesson']['courseForLesson'] != null && quizJson['lesson']['courseForLesson'] is Map<String,dynamic>){
             tempCourseName = quizJson['lesson']['courseForLesson']['titre']?.toString();
             // Si courseForLesson.id est différent de lesson.cours_id, il y a un problème d'alias ou de structure
             if (tempCourseId == null) tempCourseId = quizJson['lesson']['courseForLesson']['id'] as int?;
        }
    }
    
    tempCourseName ??= 'Cours Inconnu';


    return QuizAttemptModel(
      // attemptId, score, isPassed, attemptDate sont nulls ici car c'est une nouvelle tentative
      quizId: quizJson['id'] as int? ?? 0,
      courseId: tempCourseId ?? (quizJson['cours_id'] as int?), // Fallback sur le cours_id direct du quiz
      courseName: tempCourseName,
      quizName: quizJson['titre']?.toString() ?? 'Quiz Sans Titre',
      description: quizJson['description']?.toString(),
      totalQuestions: questionsList.length,
      questions: questionsList,
    );
  }

  // Factory pour reconstruire un modèle de tentative après l'avoir passée (pour l'écran de résultats)
  factory QuizAttemptModel.fromAttemptJson(Map<String, dynamic> attemptJson, Map<String, dynamic> quizDetailJson) {
    var questionsList = <QuizQuestionModel>[];

    // La clé pour les questions DANS l'objet de détail du quiz (quizDetailJson) est "QuestionsQuizzes"
    if (quizDetailJson['QuestionsQuizzes'] != null && quizDetailJson['QuestionsQuizzes'] is List) {
      questionsList = (quizDetailJson['QuestionsQuizzes'] as List<dynamic>).map((qJsonData) {
        if (qJsonData is Map<String, dynamic>) {
          final questionModel = QuizQuestionModel.fromJson(qJsonData, hideCorrectness: false); // Afficher les bonnes réponses pour la revue

          final userAnswersInAttempt = attemptJson['reponses_utilisateur'] as List<dynamic>?;
          final userAnswerForThisQuestion = userAnswersInAttempt?.firstWhere(
              (ans) => (ans is Map<String, dynamic>) && ans['question_id'] == questionModel.id,
              orElse: () => null,
          ) as Map<String, dynamic>?; // Cast l'élément trouvé en Map

          if (userAnswerForThisQuestion != null && userAnswerForThisQuestion['option_id'] != null) {
            questionModel.selectedOption = questionModel.options.firstWhere(
                (opt) => opt.id == (userAnswerForThisQuestion['option_id'] as int?), // Cast ici aussi
                orElse: () {
                  print('Option avec ID ${userAnswerForThisQuestion['option_id']} non trouvée pour la question ${questionModel.id}');
                  return QuizOptionModel(id: -1, text:"OPTION INTROUVABLE", isCorrect:false); // Fallback si option non trouvée (ne devrait pas arriver)
                }
            );
          }
          // Gérer les réponses textuelles si votre quiz les supporte et si elles sont dans `reponses_utilisateur`
          // if (userAnswerForThisQuestion != null && userAnswerForThisQuestion['answer_text'] != null) {
          //    questionModel.userTextAnswer = userAnswerForThisQuestion['answer_text']?.toString();
          // }
          return questionModel;
        }
        return null;
      }).whereType<QuizQuestionModel>().toList();
    } else {
        print("QuizAttemptModel.fromAttemptJson: 'QuestionsQuizzes' est null ou n'est pas une liste dans quizDetailJson pour quiz ID ${quizDetailJson['id']}");
    }

    // Déterminer courseName et courseId depuis quizDetailJson
    String? tempCourseName;
    int? tempCourseId;

    if (quizDetailJson['course'] != null && quizDetailJson['course'] is Map<String,dynamic>) {
        tempCourseName = quizDetailJson['course']['titre']?.toString();
        tempCourseId = quizDetailJson['course']['id'] as int?;
    } else if (quizDetailJson['lesson'] != null && quizDetailJson['lesson'] is Map<String,dynamic>) {
        tempCourseId = quizDetailJson['lesson']['cours_id'] as int?;
        if (quizDetailJson['lesson']['courseForLesson'] != null && quizDetailJson['lesson']['courseForLesson'] is Map<String,dynamic>){
             tempCourseName = quizDetailJson['lesson']['courseForLesson']['titre']?.toString();
             if (tempCourseId == null) tempCourseId = quizDetailJson['lesson']['courseForLesson']['id'] as int?;
        }
    }
    tempCourseName ??= 'Cours Inconnu';
    
    double? seuilReussite;
    if (quizDetailJson['seuil_reussite_pourcentage'] != null) {
      if (quizDetailJson['seuil_reussite_pourcentage'] is String) {
        seuilReussite = double.tryParse(quizDetailJson['seuil_reussite_pourcentage'] as String);
      } else if (quizDetailJson['seuil_reussite_pourcentage'] is num) {
        seuilReussite = (quizDetailJson['seuil_reussite_pourcentage'] as num).toDouble();
      }
    }

    double? scoreObtenu = (attemptJson['score_obtenu'] as num?)?.toDouble();
    bool? estPasse;
    if (scoreObtenu != null && seuilReussite != null) {
      estPasse = scoreObtenu >= seuilReussite;
    }


    return QuizAttemptModel(
      attemptId: attemptJson['id'] as int?,
      quizId: attemptJson['quiz_id'] as int? ?? 0,
      courseId: tempCourseId ?? (quizDetailJson['cours_id'] as int?),
      courseName: tempCourseName,
      quizName: quizDetailJson['titre']?.toString() ?? 'Quiz Sans Titre',
      description: quizDetailJson['description']?.toString(),
      totalQuestions: questionsList.length,
      questions: questionsList,
      score: scoreObtenu,
      isPassed: estPasse, // Utiliser la valeur calculée
      attemptDate: attemptJson['date_tentative'] != null ? DateTime.tryParse(attemptJson['date_tentative'].toString()) : null,
    );
  }
}