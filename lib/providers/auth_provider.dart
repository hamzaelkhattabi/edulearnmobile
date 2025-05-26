// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  // _isAuthAttempted est important pour que FutureBuilder dans main.dart
  // attende la fin de tryAutoLogin avant de décider d'afficher Login ou Home.
  bool _isAuthAttempted = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;
  String? get token => _token;
  bool get isAuthAttempted => _isAuthAttempted;

  AuthProvider() {
    // Optionnel: Si vous ne voulez pas de FutureBuilder dans main.dart
    // pour tryAutoLogin, vous pouvez appeler tryAutoLogin ici.
    // Mais avec FutureBuilder c'est plus explicite.
  }

  Future<void> tryAutoLogin() async {
    // Si déjà tenté, ne pas recommencer (sauf si forcé, ex: après un rechargement à chaud)
    // if (_isAuthAttempted && (_user != null || _token == null) ) return; // Simple protection

    final storedToken = await _storage.read(key: 'authToken');
    final storedUserJson = await _storage.read(key: 'authUser');

    if (storedToken == null) {
      print("AuthProvider: No token found, user not logged in.");
      _isAuthAttempted = true;
      notifyListeners();
      return;
    }

    // Tenter de charger l'utilisateur depuis le stockage d'abord
    if (storedUserJson != null) {
      try {
        _user = UserModel.fromJson(json.decode(storedUserJson));
        _token = storedToken;
         _user!.token = _token; // Assigner le token ici aussi pour la cohérence
        print("AuthProvider: User loaded from storage.");
        _isAuthAttempted = true;
        notifyListeners();
        // Optionnel: Vérifier la validité du token en arrière-plan avec getMe
        // _verifyTokenWithApi();
        return;
      } catch (e) {
        print("AuthProvider: Error decoding stored user, clearing. $e");
        // Si l'utilisateur stocké est corrompu, effacer et tenter via API
        await _clearAuthData();
      }
    }
    
    // Si pas d'utilisateur en cache ou si le cache était invalide, essayer avec l'API
    print("AuthProvider: No user in storage or cache invalid, trying getMe() with token: $storedToken");
    try {
      // On passe explicitement le token à getMe si ce n'est pas géré en interne par getMe.
      // La version getMeWithStoredToken est plus explicite.
      final freshUser = await _authService.getMeWithStoredToken(storedToken);
      if (freshUser != null) {
        _user = freshUser;
        _token = storedToken;
        _user!.token = _token; // Important d'assigner le token aussi au modèle
        await _storage.write(key: 'authUser', value: json.encode(_user!.toJson()));
        print("AuthProvider: User refreshed from API via getMe.");
      } else {
        print("AuthProvider: getMe() returned null (token likely invalid), clearing auth data.");
        await _clearAuthData(); // Le token est probablement invalide, ou l'utilisateur a été supprimé
      }
    } catch (e) {
      print("AuthProvider: Error during getMe(): $e. Clearing auth data.");
      await _clearAuthData();
    } finally {
      _isAuthAttempted = true;
      notifyListeners();
    }
  }
  
  // Optionnel: pour rafraîchir/valider le token de temps en temps sans bloquer l'UI
  // Future<void> _verifyTokenWithApi() async {
  //   try {
  //     final freshUser = await _authService.getMe(); // getMe devrait utiliser le token déjà dans _authService si dispo
  //     if (freshUser == null) { // Token invalide
  //       await logout();
  //     } else {
  //       _user = freshUser;
  //       // Mettre à jour le user en cache si différent
  //       await _storage.write(key: 'authUser', value: json.encode(_user!.toJson()));
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     await logout(); // Erreur, considérer comme déconnecté
  //   }
  // }

  Future<void> loginSuccess(UserModel user, String token) async {
    _user = user;
    _token = token;
    _user!.token = token; // Attribuer le token aussi à l'instance de l'utilisateur
    await _storage.write(key: 'authToken', value: token);
    await _storage.write(key: 'authUser', value: json.encode(_user!.toJson()));
    _isAuthAttempted = true; // Authentification réussie
    notifyListeners();
    print("AuthProvider: Login successful for ${user.email}. Token stored.");
  }

  Future<void> logout() async {
    print("AuthProvider: Logging out.");
    await _clearAuthData();
    _isAuthAttempted = true; // L'état a été tenté/modifié
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    _user = null;
    _token = null;
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'authUser');
  }
}