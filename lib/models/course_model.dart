// Supposons que votre modèle Lesson est déjà défini comme vu dans course_details_screen.dart
// import 'lesson_model.dart'; // si vous avez un lesson_model.dart
import 'quiz_models.dart';
class CourseModel {
  final String id; // Un identifiant unique pour le cours
  final String imageUrl;
  final String title;
  final double rating;
  final String duration;
  final String instructorName;
  final String instructorAvatar;
  final double price;
  final String description; // Ajouté pour CourseDetailsScreen
  final int studentCount;   // Ajouté
  final int lessonCount; 
  final Quiz? quiz;   // Ajouté
  // Optionnel: Vous pourriez aussi inclure la liste des leçons ici
  // final List<Lesson> lessons;

  CourseModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.duration,
    required this.instructorName,
    required this.instructorAvatar,
    required this.price,
    this.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam sit porta neque ullamcorper. Cum egestas gravida nam eu, cras ipsum mi. Orci donec a est.", // Valeur par défaut
    this.studentCount = 1843, // Valeur par défaut
    this.lessonCount = 12,
    this.quiz,    // Valeur par défaut
    // this.lessons = const [],
  });
}