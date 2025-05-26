// lib/services/certificate_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/certificate_model.dart';
import '../utils/api_constants.dart';

class CertificateService {
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

  Future<List<CertificateModel>> getMyCertificates() async {
  final headers = await _getAuthHeaders(); // Assurez-vous que cette méthode est là et fonctionne
  print("CertificateService: Calling ${ApiConstants.baseUrl + ApiConstants.myCertificatesEndpoint}");
  print("CertificateService: With headers: $headers");

  final response = await http.get(
    Uri.parse(ApiConstants.baseUrl + ApiConstants.myCertificatesEndpoint),
    headers: headers,
  );

  if (response.statusCode == 200) {
    print("CertificateService: Got 200, response body: ${response.body}");
    final List<dynamic> data = json.decode(response.body);
    return data.map((jsonItem) => CertificateModel.fromJson(jsonItem)).toList();
  } else {
    // IMPRIMER L'ERREUR ICI
    print("CertificateService: Failed to load certificates. Status: ${response.statusCode}, Body: ${response.body}");
    throw Exception('Failed to load certificates');
  }
}
}