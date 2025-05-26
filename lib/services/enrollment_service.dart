// lib/services/enrollment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enrollment_model.dart'; // Assurez-vous que ce modèle est créé
import '../utils/api_constants.dart';

class EnrollmentService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<EnrollmentModel>> getMyEnrollments() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.myEnrollmentsEndpoint),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => EnrollmentModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load enrollments');
    }
  }

  Future<void> enrollToCourse(int courseId) async {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.enrollCourseEndpoint(courseId)),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 201) {
        // Inscription réussie
        return;
      } else if (response.statusCode == 400) {
         final errorData = json.decode(response.body);
         throw Exception(errorData['message'] ?? 'Already enrolled or course not published.');
      }
      else {
        throw Exception('Failed to enroll in course.');
      }
  }

   Future<void> updateLessonProgress(int enrollmentId, int lessonId, bool isCompleted) async {
    final response = await http.patch( // Utilisation de PATCH comme dans votre controller backend
      Uri.parse(ApiConstants.baseUrl + ApiConstants.updateLessonProgressEndpoint(enrollmentId, lessonId)),
      headers: await _getAuthHeaders(),
      body: json.encode({'est_completee': isCompleted}),
    );

    if (response.statusCode == 200) {
      // La progression a été mise à jour avec succès
      // Le backend renvoie { lessonProgress, courseProgression }
      // Vous pouvez traiter cette réponse si nécessaire ici
      return;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update lesson progress.');
    }
  }
}