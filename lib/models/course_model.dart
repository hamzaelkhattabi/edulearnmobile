import 'package:flutter/foundation.dart';

// Correspond à `Chapter` dans course.ts
class ChapterModel {
  final int id;
  final String title;
  final String? intro; // Peut être nul
  final String? content; // Le contenu principal, peut être Markdown/HTML
  final String? conclusion; // Peut être nul
  final String? imagePath; // `image_path` dans TS, peut être une URL ou un asset local
  final int order;
  final int courseId;
  // Champs spécifiques à l'UI mobile, non présents dans le modèle web
  final String durationDisplay; // Ex: "Lecture: 15 Mins"
  final bool isLocked;
  final bool isPlaying; // Pour indiquer la leçon en cours de lecture

  ChapterModel({
    required this.id,
    required this.title,
    this.intro,
    this.content,
    this.conclusion,
    this.imagePath, // Adapter pour assets/network
    required this.order,
    required this.courseId,
    this.durationDisplay = "10 Mins", // Valeur par défaut
    this.isLocked = false,
    this.isPlaying = false,
  });

  // Méthode pour obtenir le contenu complet de la leçon
  String get fullContent {
    String full = "";
    if (intro != null && intro!.isNotEmpty) full += "$intro\n\n";
    if (content != null && content!.isNotEmpty) full += "$content\n\n";
    if (conclusion != null && conclusion!.isNotEmpty) full += conclusion!;
    return full.isEmpty ? "Contenu non disponible." : full;
  }

  // Factory constructor pour créer depuis un JSON (si vous intégrez une API)
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      title: json['title'],
      intro: json['intro'],
      content: json['content'],
      conclusion: json['conclusion'],
      imagePath: json['image_path'],
      order: json['order'],
      courseId: json['course_id'],
      // Les champs UI peuvent nécessiter une logique supplémentaire ou être initialisés
      durationDisplay: "N/A", // À déterminer ou à passer autrement
      isLocked: false, // Logique de verrouillage à implémenter
    );
  }
}

// Correspond à `Material` dans course.ts
class MaterialModel {
  final int id;
  final String fileType; // ex: 'pdf', 'video', 'zip'
  final String path; // URL ou chemin vers le fichier
  final int courseId;

  MaterialModel({
    required this.id,
    required this.fileType,
    required this.path,
    required this.courseId,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      fileType: json['fileType'],
      path: json['path'],
      courseId: json['course_id'],
    );
  }
}

// Correspond à `Course` dans course.ts
class CourseModel {
  final int id;
  final String courseName; // `courseName` dans TS
  final String? teacherId; // `teacher_id` dans TS (peut être lié à un modèle User/Teacher plus tard)
  final String description; // `Description` dans TS
  final bool isGlobal;
  final List<ChapterModel> chapters;
  final List<MaterialModel> materials;

  // Champs spécifiques à l'UI mobile, non présents directement dans le modèle web Course
  // mais utiles pour l'affichage et potentiellement dérivés/ajoutés côté client
  final String imageUrl; // Pour l'image principale du cours
  final String instructorName;
  final String instructorAvatar;
  final double rating;
  final String durationTotal; // Durée totale estimée du cours
  final int studentCount;
  final double price;

  CourseModel({
    required this.id,
    required this.courseName,
    this.teacherId,
    required this.description,
    this.isGlobal = false,
    this.chapters = const [],
    this.materials = const [],
    // UI specific
    required this.imageUrl,
    required this.instructorName,
    required this.instructorAvatar,
    required this.rating,
    required this.durationTotal,
    required this.studentCount,
    required this.price,
  });

  int get lessonCount => chapters.length;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      courseName: json['courseName'],
      teacherId: json['teacher_id'],
      description: json['Description'],
      isGlobal: json['isGlobal'] ?? false,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((chapJson) => ChapterModel.fromJson(chapJson as Map<String, dynamic>))
              .toList() ??
          [],
      materials: (json['materials'] as List<dynamic>?)
              ?.map((matJson) => MaterialModel.fromJson(matJson as Map<String, dynamic>))
              .toList() ??
          [],
      // Les champs UI ci-dessous devraient être fournis séparément ou dérivés
      // Pour l'instant, on met des placeholders si non présents dans le JSON principal
      imageUrl: json['imageUrl_mobile_ui'] ?? 'assets/placeholder_course.png',
      instructorName: json['instructorName_mobile_ui'] ?? 'Instructeur Inconnu',
      instructorAvatar: json['instructorAvatar_mobile_ui'] ?? 'assets/avatar_placeholder.png',
      rating: (json['rating_mobile_ui'] ?? 0.0).toDouble(),
      durationTotal: json['durationTotal_mobile_ui'] ?? 'N/A',
      studentCount: json['studentCount_mobile_ui'] ?? 0,
      price: (json['price_mobile_ui'] ?? 0.0).toDouble(),
    );
  }
}