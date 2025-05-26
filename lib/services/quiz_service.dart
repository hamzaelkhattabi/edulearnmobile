// lib/services/quiz_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/quiz_models.dart'; // Assurez-vous que ce fichier contient QuizInfoModel, QuizAttemptModel
import '../utils/api_constants.dart';

class QuizService {
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

  // Pour QuizListScreen: lister les quiz (probablement pour l'utilisateur ou un cours)
  Future<List<QuizInfoModel>> getUserQuizzes({int? courseId}) async {
    String endpoint = ApiConstants.userQuizzesEndpoint;
    if (courseId != null) {
      // Si votre API permet de filtrer les quiz par courseId via query param
      endpoint = '${ApiConstants.userQuizzesEndpoint}?cours_id=$courseId';
      // Ou si vous avez une route dédiée comme '/courses/:courseId/quizzes'
      // endpoint = ApiConstants.quizzesForCourseEndpoint(courseId);
    }
    
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      print("QuizService: getQuizForAttempt SUCCESS (200). JSON du Quiz: ${response.body}");
      final List<dynamic> data = json.decode(response.body);
      // L'API doit renvoyer des données agrégées pour QuizInfoModel.
      // Ceci est une supposition sur la structure de la réponse.
      return data.map((jsonItem) => QuizInfoModel.fromJson(jsonItem)).toList();
    } else {
      print("ERREUR API QUIZ: Statut ${response.statusCode}, Corps: ${response.body}");
      throw Exception('Failed to load quizzes');
    }
  }

  // Pour QuizAttemptScreen: obtenir les détails d'un quiz pour le commencer
  Future<QuizAttemptModel> getQuizForAttempt(int quizId) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.quizByIdEndpoint(quizId));
    print("QuizService: Attempting to get quiz details for attempt. URL: $url");
    print("QuizService: With headers: $headers");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      print("QuizService: getQuizForAttempt SUCCESS (200). Body: ${response.body}");
      return QuizAttemptModel.fromQuizJson(json.decode(response.body), forTakingQuiz: true);
    } else {
      // IMPRIMER L'ERREUR ICI
      print("QuizService: Failed to load quiz details for attempt. Status: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to load quiz details for attempt');
    }
  }

  // Soumettre une tentative de quiz
  Future<Map<String, dynamic>> submitQuizAttempt(int quizId, List<Map<String, dynamic>> answers) async {
    // answers format: [{ "question_id": X, "option_id": Y}, ...]
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.submitQuizAttemptEndpoint(quizId)),
      headers: await _getAuthHeaders(),
      body: json.encode({'answers': answers}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      // Le backend renvoie 'attempt', 'score', 'totalPossibleScore', 'scorePourcentage', 'passed'
      // `data['attempt']` contient les détails de `TentativesQuiz` y compris `reponses_utilisateur` et `score_obtenu`
      // On peut reconstruire un QuizAttemptModel complet pour le résultat
      return data; // Renvoyer la réponse brute pour que l'écran de résultat puisse l'utiliser
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to submit quiz attempt');
    }
  }
}