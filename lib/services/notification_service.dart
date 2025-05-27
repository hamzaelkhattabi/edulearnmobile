import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/notification_model.dart'; // Renommé de notification_item.dart
import '../utils/api_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class NotificationService {
  final _storage = const FlutterSecureStorage();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

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

  Future<void> initFirebaseMessaging() async {
    // Demander la permission
    await _fcm.requestPermission();

    // Obtenir le token FCM
    final token = await _fcm.getToken();
    print("🔐 FCM Token : $token");

    // Tu peux envoyer ce token à ton backend ici si besoin
    // await sendTokenToBackend(token);

    // Écoute des messages reçus quand l'app est ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Notification reçue (foreground) : ${message.notification?.title}");
      // Tu peux aussi déclencher une notif locale ici avec flutter_local_notifications
    });

    // Quand l'utilisateur clique sur une notif (app en background ou terminée)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🟢 Notification ouverte : ${message.notification?.title}");
      // Naviguer vers une page spécifique par exemple
    });
  }

}