// lib/services/course_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../utils/api_constants.dart';

class CourseService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<List<CourseModel>> getAllCourses({String? categoryId, String? searchQuery}) async {
    // Construire l'URL avec les query parameters
    var queryParams = <String, String>{};
    if (categoryId != null) queryParams['categorie_id'] = categoryId;
    if (searchQuery != null) queryParams['search'] = searchQuery;
    // Ajoutez d'autres filtres comme page, limit si nécessaire

    final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.coursesEndpoint)
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri, headers: await _getHeaders(includeAuth: true)); // Inclure auth pour voir les cours non publiés si instructeur/admin

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // L'API de getAllCourses renvoie un objet avec une clé 'courses' (Array)
      // et potentiellement 'totalPages', 'currentPage', 'totalCourses'.
      // Nous nous intéressons ici à la liste 'courses'.
      final List<dynamic> courseListJson = data['courses'] ?? data; // Si l'API renvoie directement une liste
      return courseListJson.map((jsonItem) => CourseModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<CourseModel> getCourseById(int courseId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.courseByIdEndpoint(courseId)),
      headers: await _getHeaders(includeAuth: true), // L'accès peut dépendre du statut de publication et du rôle
    );

    if (response.statusCode == 200) {
      print("DEBUG JSON POUR COURSE ID $courseId: ${response.body}");
      return CourseModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Course not found');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load course details');
    }
  }

  Future<List<LessonModel>> getLessonsForCourse(int courseId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.lessonsForCourseEndpoint(courseId)),
      headers: await _getHeaders(includeAuth: true),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body); // Ou data['lessons'] si imbriqué
      return data.map((jsonItem) => LessonModel.fromJson(jsonItem, parentCourseId: courseId)).toList();
    } else {
      throw Exception('Failed to load lessons for course $courseId');
    }
  }

  // Ajouter d'autres méthodes: enrollToCourse, updateLessonProgress etc.
  // updateLessonProgress sera probablement dans enrollment_service.dart
}