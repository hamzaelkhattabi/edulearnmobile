import 'package:flutter/foundation.dart';

class UserProfileModel {
  final String uid;
  final String fullName;
  final String userName;
  final String email;
  final String? dateOfBirth; // Format YYYY-MM-DD
  final int? levelId;
  final int? specialityId;
  final String avatarUrl; // Chemin vers l'asset ou URL

  UserProfileModel({
    required this.uid,
    required this.fullName,
    required this.userName,
    required this.email,
    this.dateOfBirth,
    this.levelId,
    this.specialityId,
    required this.avatarUrl,
  });
}

class EnrolledCourseModel {
  final String courseId; // Pour lier au CourseModel
  final String title;
  final String instructor;
  final String imageUrl;
  final int totalLessons;
  final int completedLessons;

  EnrolledCourseModel({
    required this.courseId,
    required this.title,
    required this.instructor,
    required this.imageUrl,
    required this.totalLessons,
    required this.completedLessons,
  });

  double get progress => totalLessons > 0 ? completedLessons / totalLessons : 0.0;
}