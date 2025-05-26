// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';      // Assurez-vous que le chemin est correct
import '../utils/api_constants.dart'; // Assurez-vous que le chemin est correct

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const String _authTokenKey = 'authToken';
  static const String _authUserKey = 'authUser';

  // Méthode privée pour obtenir le token du stockage
  Future<String?> _getTokenFromStorage() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Méthode privée pour sauvegarder les données d'authentification
  Future<void> _saveAuthData(String token, UserModel user) async {
    user.token = token; // Attribuer le token au modèle utilisateur aussi pour la cohérence
    await _storage.write(key: _authTokenKey, value: token);
    await _storage.write(key: _authUserKey, value: json.encode(user.toJson()));
    print("AuthService: Auth data saved (token & user).");
  }

  // Méthode privée pour effacer les données d'authentification
  Future<void> _clearAuthData() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _authUserKey);
    print("AuthService: Auth data cleared from storage.");
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("AuthService: Attempting login for email: $email");
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'email': email, 'mot_de_passe': password}),
    );

    print("AuthService: Login API response status: ${response.statusCode}");
    // print("AuthService: Login API response body: ${response.body}");


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = UserModel.fromJson(data['user']);
      await _saveAuthData(data['token'], user);
      return {'token': data['token'], 'user': user};
    } else {
      String errorMessage = 'Échec de la connexion';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        // La réponse n'est pas un JSON valide ou pas de champ 'message'
        print("AuthService: Login error, could not parse error response: ${response.body}");
      }
      print("AuthService: Login failed with message: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> register({
    required String nomUtilisateur,
    required String email,
    required String motDePasse,
    String? prenom,
    String? nomFamille,
    String role = 'etudiant',
  }) async {
    print("AuthService: Attempting registration for username: $nomUtilisateur, email: $email");
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.registerEndpoint),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({
        'nom_utilisateur': nomUtilisateur,
        'email': email,
        'mot_de_passe': motDePasse,
        'prenom': prenom,
        'nom_famille': nomFamille,
        'role': role,
      }),
    );
    
    print("AuthService: Register API response status: ${response.statusCode}");
    // print("AuthService: Register API response body: ${response.body}");

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final user = UserModel.fromJson(data['user']);
      // L'API de register renvoie un token, donc on connecte l'utilisateur directement
      await _saveAuthData(data['token'], user);
      return {'token': data['token'], 'user': user};
    } else {
      String errorMessage = 'Échec de l\'inscription';
       try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        print("AuthService: Register error, could not parse error response: ${response.body}");
      }
      print("AuthService: Registration failed with message: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  // Méthode pour récupérer l'utilisateur actuel en utilisant le token stocké
  Future<UserModel?> getMe() async {
    print("AuthService: getMe called.");
    final token = await _getTokenFromStorage();
    if (token == null) {
      print("AuthService: No token found in storage for getMe.");
      return null;
    }
    // Utilise getMeWithStoredToken pour éviter la duplication de code
    return await getMeWithStoredToken(token);
  }

  // Méthode spécifique pour AuthProvider afin de valider un token lors du tryAutoLogin
  Future<UserModel?> getMeWithStoredToken(String token) async {
    print("AuthService: Attempting getMe with provided token.");
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.getMeEndpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print("AuthService: getMe (with token) API response status: ${response.statusCode}");
      // print("AuthService: getMe (with token) API response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data);
        // Il est crucial de réenregistrer l'utilisateur (avec son token)
        // pour mettre à jour le cache 'authUser' avec les données fraîches de l'API.
        await _saveAuthData(token, user);
        print("AuthService: getMe successful, user data refreshed in storage.");
        return user;
      } else {
        // Si getMe échoue (token invalide, expiré, etc.), on efface les données d'auth.
        print("AuthService: getMe (with token) failed, status ${response.statusCode}. Clearing auth data.");
        await _clearAuthData();
        return null;
      }
    } catch (e) {
      print("AuthService: Exception in getMeWithStoredToken: $e. Clearing auth data.");
      // Une exception réseau pourrait survenir, on considère l'utilisateur comme non connecté
      // ou du moins on ne peut pas valider son état. Effacer les données est plus sûr.
      await _clearAuthData();
      return null;
    }
  }


  Future<void> logout() async {
    print("AuthService: Logging out user.");
    // TODO: Informer le backend du logout (invalider le token côté serveur si possible/nécessaire)
    // Pour l'instant, on efface juste les données locales.
    await _clearAuthData();
  }

  // Récupère l'utilisateur directement depuis le stockage (cache)
  Future<UserModel?> getCurrentUserFromStorage() async {
    print("AuthService: Attempting to get user from storage.");
    try {
      final userJson = await _storage.read(key: _authUserKey);
      final token = await _storage.read(key: _authTokenKey); // Lire aussi le token
      if (userJson != null && token != null) {
        final user = UserModel.fromJson(json.decode(userJson));
        user.token = token; // S'assurer que le token est aussi dans l'objet user
        print("AuthService: User found in storage: ${user.email}");
        return user;
      }
      print("AuthService: No user or token found in storage.");
      return null;
    } catch (e) {
      print("AuthService: Error decoding user from storage: $e. Clearing auth data.");
      // Si les données sont corrompues, les effacer
      await _clearAuthData();
      return null;
    }
  }
}