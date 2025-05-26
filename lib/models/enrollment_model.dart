// lib/models/enrollment_model.dart
import 'course_model.dart';

class EnrollmentModel {
  final int id;
  final int userId;
  final int courseId;
  final DateTime dateInscription;
  final double progressionPourcentage;
  final DateTime? dateAchevement;
  final CourseModel? course; // Optionnel, si vous chargez les détails du cours avec l'inscription

  EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.dateInscription,
    this.progressionPourcentage = 0.0,
    this.dateAchevement,
    this.course,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    double parsedProgression = 0.0;
    if (json['progression_pourcentage'] != null) {
      if (json['progression_pourcentage'] is String) {
        parsedProgression = double.tryParse(json['progression_pourcentage'] as String) ?? 0.0;
      } else if (json['progression_pourcentage'] is num) {
        parsedProgression = (json['progression_pourcentage'] as num).toDouble();
      }
    }
    return EnrollmentModel(
      id: json['id'],
      userId: json['utilisateur_id'],
      courseId: json['cours_id'],
      dateInscription: DateTime.parse(json['date_inscription']),
      progressionPourcentage: parsedProgression, // Utiliser la valeur parsée
      dateAchevement: json['date_achevement'] != null
          ? DateTime.parse(json['date_achevement'])
          : null,
      // Assurez-vous que l'alias pour le cours joint est correct ("Cour" ou "course")
      course: json['Cour'] != null ? CourseModel.fromJson(json['Cour']) : (json['course'] != null ? CourseModel.fromJson(json['course']) : null),
    );
  }
    // Ce que vous aviez dans ProfileScreen pour EnrolledCourseModel est en fait un EnrollmentModel enrichi.
    // Je vais créer un modèle spécifique pour ProfileScreen si besoin, ou nous adapterons cela.
    // Pour l'instant, ProfileScreen pourrait utiliser List<EnrollmentModel>
    // et accéder à `enrollment.course.title`, etc.
}