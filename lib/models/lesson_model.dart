// lib/models/lesson_model.dart
import '../models/quiz_models.dart'; // Pour QuizInfoModel

class LessonModel {
  final int id;
  final int courseId; // Vient du parent (CourseModel) lors du parsing
  final String title;
  final String? content; // Markdown pour le contenu de la leçon
  final int order;
  final int? durationEstimatedMin;
  final String? imagePath; // URL ou asset path pour une image d'en-tête de leçon
  final List<QuizInfoModel> quizzes; // Quiz associés à cette leçon

  // Champs pour l'état UI, pas directement de l'API ici (seront gérés par la logique de progression)
  bool isLocked;
  bool isPlaying; // (Conceptuel, pourrait indiquer si c'est la leçon en cours de lecture)
  bool isCompleted; // Pourrait être utile de l'avoir

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.content,
    required this.order,
    this.durationEstimatedMin,
    this.imagePath,
    this.quizzes = const [], // Initialiser par défaut à une liste vide
    this.isLocked = false, // Par défaut, une leçon chargée n'est pas verrouillée
    this.isPlaying = false,
    this.isCompleted = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json, {required int parentCourseId}) {
    var quizzesList = <QuizInfoModel>[];
    // La clé 'lessonQuizzes' doit correspondre à l'alias de votre `include` Sequelize
    // dans la requête qui charge les leçons (ex: dans CourseController.getCourseById).
    // Si vous n'utilisez pas d'alias, Sequelize utilise le nom du modèle cible au pluriel
    // ou le nom que vous avez donné via `Model.hasMany(OtherModel, { as: 'someName' })`.
    // Supposons 'lessonQuizzes' comme alias.
    if (json['lessonQuizzes'] != null && json['lessonQuizzes'] is List) {
      quizzesList = (json['lessonQuizzes'] as List<dynamic>)
          .map((quizJson) {
            if (quizJson is Map<String, dynamic>) {
              // Ici, on crée un QuizInfoModel simple juste pour la navigation.
              // QuizAttemptScreen chargera les détails complets du quiz.
              return QuizInfoModel(
                quizId: quizJson['id'] as int? ?? 0, // L'ID du quiz est essentiel
                quizName: quizJson['titre']?.toString() ?? 'Quiz de la leçon',
                // Les champs suivants ne sont pas critiques pour _juste_ lister les quiz de la leçon
                // mais sont requis par QuizInfoModel. Mettez des valeurs par défaut.
                courseId: parentCourseId, // Le cours parent de cette leçon
                courseName: '', // Sera récupéré par le quiz lui-même si nécessaire
                totalQuestions: quizJson['questionsCount'] as int? ?? 0, // Si l'API renvoie un compte de questions
                description: quizJson['description']?.toString(),
              );
            }
            return null;
          })
          .whereType<QuizInfoModel>()
          .toList();
    } else if (json['Quiz'] != null && json['Quiz'] is Map<String, dynamic>) {
        // Cas où une leçon est associée à UN SEUL quiz directement (via json['Quiz'])
        // Ceci est pour le cas où vous avez hasOne: Quiz dans le modèle Lesson
        final quizJson = json['Quiz'] as Map<String, dynamic>;
        quizzesList.add(QuizInfoModel(
                quizId: quizJson['id'] as int? ?? 0,
                quizName: quizJson['titre']?.toString() ?? 'Quiz de la leçon',
                courseId: parentCourseId,
                courseName: '',
                totalQuestions: quizJson['questionsCount'] as int? ?? 0,
                description: quizJson['description']?.toString(),
            ));
    }


    return LessonModel(
      id: json['id'] as int? ?? -1, // Utiliser -1 comme fallback ID est pour le débogage seulement
      courseId: parentCourseId,
      title: json['titre']?.toString() ?? 'Titre de Leçon Inconnu',
      content: json['contenu']?.toString(), // Devrait être nullable si ce n'est pas toujours fourni
      order: json['ordre'] as int? ?? 0, // Idem, 0 comme fallback pour débogage
      durationEstimatedMin: json['duree_estimee_min'] as int?,
      imagePath: json['image_url_lecon']?.toString(), // S'attendre à ce champ ou à un autre nom
      quizzes: quizzesList,
      // isLocked et isPlaying ne viennent généralement pas directement du JSON de la leçon
      // mais sont déterminés par la logique de progression de l'utilisateur.
    );
  }

  // Pourrait être utile pour mettre à jour une leçon sans recréer l'objet
  LessonModel copyWith({
    int? id,
    int? courseId,
    String? title,
    String? content, // Attention, doit être nullable pour accepter `ValueGetter<String?>?`
    int? order,
    int? durationEstimatedMin,
    String? imagePath,
    List<QuizInfoModel>? quizzes,
    bool? isLocked,
    bool? isPlaying,
    bool? isCompleted,
  }) {
    return LessonModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      durationEstimatedMin: durationEstimatedMin ?? this.durationEstimatedMin,
      imagePath: imagePath ?? this.imagePath,
      quizzes: quizzes ?? this.quizzes,
      isLocked: isLocked ?? this.isLocked,
      isPlaying: isPlaying ?? this.isPlaying,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }


  String get durationDisplay {
    if (durationEstimatedMin == null || durationEstimatedMin! <= 0) return "N/A";
    if (durationEstimatedMin! < 60) return "$durationEstimatedMin Mins";
    int hours = durationEstimatedMin! ~/ 60;
    int minutes = durationEstimatedMin! % 60;
    if (minutes == 0) return "$hours hr${hours > 1 ? 's' : ''}";
    return "$hours hr${hours > 1 ? 's' : ''} $minutes Mins";
  }

  // Pour le widget MarkdownBody
  String get fullContent => content ?? '# ${title}\n\nContenu pour cette leçon bientôt disponible.';
}