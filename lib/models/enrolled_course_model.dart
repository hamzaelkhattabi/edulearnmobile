class EnrolledCourse {
  final String title;
  final String instructor;
  final String imageUrl;
  final int totalLessons;
  final int completedLessons;

  EnrolledCourse({
    required this.title,
    required this.instructor,
    required this.imageUrl,
    required this.totalLessons,
    required this.completedLessons,
  });

  double get progress => (totalLessons > 0 ? (completedLessons / totalLessons) : 0.0);
}