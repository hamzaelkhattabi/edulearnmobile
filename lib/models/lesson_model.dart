class Lesson {
  final String id; // Identifiant unique de la leçon
  final String title;
  final String duration; // Peut-être moins pertinent si c'est de la lecture
  final String thumbnailAsset; // Pour la liste dans course_details
  final bool isLocked;
  final bool isPlaying; // Ou 'isCurrent'/'isActive' si pas de vidéo
  final String content; // CONTENU TEXTUEL DE LA LEÇON
  final List<String>? imageUrls; // Optionnel : liste d'URLs ou chemins d'assets d'images pour la leçon

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.thumbnailAsset,
    this.isLocked = false,
    this.isPlaying = false,
    required this.content,
    this.imageUrls,
  });
}