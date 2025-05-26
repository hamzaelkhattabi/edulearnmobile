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

  // lib/services/enrollment_service.dart
Future<EnrollmentModel?> getMyEnrollmentForCourse(int courseId) async {
    // Vous devez créer cet endpoint côté backend : GET /api/courses/:courseId/my-enrollment
    // Il devrait retourner l'objet InscriptionCours de l'utilisateur authentifié pour ce cours, ou 404/null si non inscrit.
    final String endpoint = ApiConstants.baseUrl + '/courses/$courseId/my-enrollment'; // Adaptez l'endpoint
    try {
        final response = await http.get(
            Uri.parse(endpoint),
            headers: await _getAuthHeaders(), // S'assurer que le token est envoyé
        );
        if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data != null && data.isNotEmpty) { // Si l'API renvoie un objet et non un tableau
                 return EnrollmentModel.fromJson(data);
            }
            return null; // Ou si l'API renvoie un corps vide pour "non trouvé" avec statut 200.
        } else if (response.statusCode == 404) {
            return null; // L'utilisateur n'est pas inscrit
        } else {
            print("Erreur getMyEnrollmentForCourse (${response.statusCode}): ${response.body}");
            // throw Exception('Failed to get enrollment status for course $courseId');
            return null; // Traiter comme non inscrit en cas d'autre erreur pour ne pas bloquer
        }
    } catch (e) {
        print("Exception in getMyEnrollmentForCourse: $e");
        return null;
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