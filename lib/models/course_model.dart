// lib/models/course_model.dart
import 'lesson_model.dart';
// Pas besoin d'importer UserModel ou CategoryModel ici car leurs données
// sont parsées directement depuis les sous-objets JSON ('instructor', 'category')
// ou sont déjà des chaînes simples comme instructorName, categoryName.

class CourseModel {
  final int id;
  final String courseName; // Correspond à 'titre' dans le JSON
  final String? description;
  final int? instructorId; // 'instructeur_id'
  final String instructorName; // Construit à partir de json['instructor']
  final String? instructorAvatar; // Construit/récupéré à partir de json['instructor'] ou fallback
  final int? categoryId; // 'categorie_id'
  final String? categoryName; // Récupéré de json['category']
  final String? difficultyLevel; // 'niveau_difficulte'
  final String imageUrl; // 'image_url_couverture'
  final bool isPublished; // 'est_publie'
  final DateTime? dateCreation;
  final List<LessonModel> lessons;

  final double rating;
  final String durationTotal; // Peut être calculé ou fourni par l'API
  final int studentCount; // Peut être calculé ou fourni par l'API

  CourseModel({
    required this.id,
    required this.courseName,
    this.description,
    this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    this.categoryId,
    this.categoryName,
    this.difficultyLevel,
    required this.imageUrl,
    required this.isPublished,
    this.dateCreation,
    this.lessons = const [],
    this.rating = 0.0,
    this.durationTotal = "N/A",
    this.studentCount = 0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final int courseIdFromApi = json['id'] as int? ?? -1;
    if (courseIdFromApi == -1) {
      // Gérer l'erreur ou lancer une exception si un ID de cours est indispensable
      print("ERREUR CRITIQUE : L'ID du cours est null ou invalide dans le JSON : $json");
      // Vous pourriez throw FormatException("Course ID is missing or invalid");
    }

    var lessonsList = <LessonModel>[];
    if (json['Lecons'] != null && json['Lecons'] is List) {
      lessonsList = (json['Lecons'] as List<dynamic>)
          .map((lessonJsonData) {
            if (lessonJsonData is Map<String, dynamic>) {
              return LessonModel.fromJson(lessonJsonData, parentCourseId: courseIdFromApi);
            } else {
              print("AVERTISSEMENT: Élément non-Map trouvé dans la liste 'Lecons': $lessonJsonData pour le cours ID: $courseIdFromApi");
              return null;
            }
          })
          .whereType<LessonModel>() // Filtrer les nulls
          .toList();
    } else if (json['lessons'] != null && json['lessons'] is List) { // Fallback pour une clé "lessons" (moins probable si vous contrôlez l'API)
       lessonsList = (json['lessons'] as List<dynamic>)
          .map((lessonJsonData) {
            if (lessonJsonData is Map<String, dynamic>) {
              return LessonModel.fromJson(lessonJsonData, parentCourseId: courseIdFromApi);
            } else {
              print("AVERTISSEMENT: Élément non-Map trouvé dans la liste 'lessons': $lessonJsonData pour le cours ID: $courseIdFromApi");
              return null;
            }
          })
          .whereType<LessonModel>()
          .toList();
    }

    // Gestion de l'instructeur
    String finalInstructorName = "Instructeur Inconnu";
    String? finalInstructorAvatar;
    if (json['instructor'] != null && json['instructor'] is Map<String, dynamic>) {
      final instructorData = json['instructor'] as Map<String, dynamic>;
      final String prenom = instructorData['prenom']?.toString() ?? '';
      final String nomFamille = instructorData['nom_famille']?.toString() ?? '';
      finalInstructorName = ('$prenom $nomFamille').trim();
      if (finalInstructorName.isEmpty) {
        finalInstructorName = instructorData['nom_utilisateur']?.toString() ?? 'Instructeur Inconnu';
      }
      // Supposons que l'API renvoie 'avatar_url' pour l'avatar de l'instructeur, sinon, null
      finalInstructorAvatar = instructorData['avatar_url']?.toString();
    } else if (json['instructorName'] != null) { // Fallback pour d'anciennes structures si nécessaire
        finalInstructorName = json['instructorName'].toString();
        finalInstructorAvatar = json['instructorAvatar']?.toString();
    }


    // Gestion de la catégorie
    String? finalCategoryName;
    if (json['category'] != null && json['category'] is Map<String, dynamic>) {
      final categoryData = json['category'] as Map<String, dynamic>;
      finalCategoryName = categoryData['nom_categorie']?.toString();
    } else if (json['categoryName'] != null) { // Fallback
        finalCategoryName = json['categoryName'].toString();
    }

    DateTime? parsedDateCreation;
    if (json['date_creation'] != null) {
        parsedDateCreation = DateTime.tryParse(json['date_creation'].toString());
        if (parsedDateCreation == null) {
            print("AVERTISSEMENT: Échec du parsing de date_creation: ${json['date_creation']} pour le cours ID: $courseIdFromApi");
        }
    }
    
    return CourseModel(
      id: courseIdFromApi,
      courseName: json['titre']?.toString() ?? 'Titre Cours Inconnu',
      description: json['description']?.toString(),
      instructorId: json['instructeur_id'] as int?, // Cast direct, sera null si la clé n'existe pas ou si valeur est null
      instructorName: finalInstructorName,
      instructorAvatar: finalInstructorAvatar, // Peut être null
      categoryId: json['categorie_id'] as int?,
      categoryName: finalCategoryName,
      difficultyLevel: json['niveau_difficulte']?.toString(),
      imageUrl: json['image_url_couverture']?.toString() ?? 'assets/default_course_image.png', // Fournir un fallback d'asset
      isPublished: json['est_publie'] as bool? ?? false, // Valeur par défaut false si manquant ou null
      dateCreation: parsedDateCreation,
      lessons: lessonsList,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      durationTotal: json['durationTotal']?.toString() ?? _calculateAndFormatTotalDuration(lessonsList),
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
    );
  }

  // Helper pour calculer et formater la durée totale si non fournie par l'API
  static String _calculateAndFormatTotalDuration(List<LessonModel> lessons) {
    if (lessons.isEmpty) return "N/A";
    int totalMinutes = lessons.fold(0, (prev, lesson) => prev + (lesson.durationEstimatedMin ?? 0));
    if (totalMinutes <= 0) return "N/A";
    return _formatTotalDuration(totalMinutes);
  }

  // Helper pour formater la durée totale
  static String _formatTotalDuration(int totalMinutes) {
    if (totalMinutes <= 0) return "N/A"; // S'assurer que cela gère 0 ou négatif
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours == 0) return "$minutes Mins";
    if (minutes == 0) return "$hours Heure${hours > 1 ? 's' : ''}"; // Ajouter 's' si plus d'une heure
    return "$hours Heure${hours > 1 ? 's' : ''} $minutes Mins";
  }

  // Getter pour le nombre de leçons, toujours basé sur la liste actuelle
  int get lessonCount => lessons.length;
}