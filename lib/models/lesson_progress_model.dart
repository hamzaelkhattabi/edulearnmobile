// lib/models/lesson_progress_model.dart
class LessonProgressModel {
  final int id;
  final int enrollmentId; // inscription_cours_id
  final int lessonId;     // lecon_id
  final bool isCompleted; // est_completee
  final DateTime? dateCompletion;

  LessonProgressModel({
    required this.id,
    required this.enrollmentId,
    required this.lessonId,
    required this.isCompleted,
    this.dateCompletion,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      id: json['id'],
      enrollmentId: json['inscription_cours_id'],
      lessonId: json['lecon_id'],
      isCompleted: json['est_completee'],
      dateCompletion: json['date_completion'] != null
          ? DateTime.parse(json['date_completion'])
          : null,
    );
  }
}