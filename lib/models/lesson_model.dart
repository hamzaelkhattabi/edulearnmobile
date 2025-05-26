// lib/models/lesson_model.dart
import 'package:intl/intl.dart'; // Pour formater la durée

class LessonModel {
  final int id;
  final int courseId; // cours_id
  final String title;    // titre
  final String? content;  // contenu (markdown)
  final int order;      // ordre
  final int? durationEstimatedMin; // duree_estimee_min
  final String? imagePath; // Peut être une URL de l'API ou un asset local (besoin de logique)

  // Champs pour l'UI, pas forcément de l'API directement pour isLocked/isPlaying
  bool isLocked; // Géré côté client ou via la logique de progression
  bool isPlaying; // État purement UI

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.content,
    required this.order,
    this.durationEstimatedMin,
    this.imagePath,
    this.isLocked = false, // Par défaut non verrouillé
    this.isPlaying = false,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json, {required int parentCourseId}) {
    final lessonId = json['id'];
    if (lessonId == null) print("ERREUR PARSING LECON: ID est null pour leçon JSON: $json");

    final lessonOrder = json['ordre'];
    if (lessonOrder == null) print("ERREUR PARSING LECON: order est null pour leçon JSON: $json");
    
    return LessonModel(
      id: lessonId ?? -1,
      courseId: parentCourseId,
      title: json['titre'],
      content: json['contenu'],
      order: json['ordre'],
      durationEstimatedMin: json['duree_estimee_min'],
      imagePath: json['image_url_lecon'], // Supposez une image_url_lecon, sinon à gérer
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cours_id': courseId,
    'titre': title,
    'contenu': content,
    'ordre': order,
    'duree_estimee_min': durationEstimatedMin,
    'image_url_lecon': imagePath,
  };

  String get durationDisplay {
    if (durationEstimatedMin == null || durationEstimatedMin == 0) return "N/A";
    if (durationEstimatedMin! < 60) return "$durationEstimatedMin Mins";
    int hours = durationEstimatedMin! ~/ 60;
    int minutes = durationEstimatedMin! % 60;
    if (minutes == 0) return "$hours hr";
    return "$hours hr $minutes Mins";
  }

  // Similaire à votre ancien `fullContent` mais ici c'est `content` qui contient le markdown
  String get fullContent => content ?? '# ${title}\n\nContenu non disponible.';
}