import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/notification_model.dart'; // Renommé de notification_item.dart
import '../utils/api_constants.dart';

class NotificationService {
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

  Future<List<NotificationModel>> getMyNotifications() async {
    // Assurez-vous que l'endpoint '/notifications/my' existe et est protégé côté backend
    // et qu'il renvoie les notifications pour l'utilisateur authentifié.
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.myNotificationsEndpoint),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => NotificationModel.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Optionnel: Marquer comme lu
  // Future<void> markAsRead(String notificationId) async { ... }
  // Future<void> markAllAsRead() async { ... }
}