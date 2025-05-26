// lib/models/user_model.dart
class UserModel {
  final int id;
  final String nomUtilisateur;
  final String email;
  final String? prenom;
  final String? nomFamille;
  final String role; // 'etudiant', 'instructeur', 'admin'
  final DateTime? dateInscription;
  final DateTime? derniereConnexion;
  String? token; // Ajouté pour stocker le token côté client après connexion

  UserModel({
    required this.id,
    required this.nomUtilisateur,
    required this.email,
    this.prenom,
    this.nomFamille,
    required this.role,
    this.dateInscription,
    this.derniereConnexion,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nomUtilisateur: json['nom_utilisateur'],
      email: json['email'],
      prenom: json['prenom'],
      nomFamille: json['nom_famille'],
      role: json['role'],
      dateInscription: json['date_inscription'] != null
          ? DateTime.parse(json['date_inscription'])
          : null,
      derniereConnexion: json['derniere_connexion'] != null
          ? DateTime.parse(json['derniere_connexion'])
          : null,
      token: json['token'], // Si le backend le renvoie dans l'objet utilisateur
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'nom_utilisateur': nomUtilisateur,
      'email': email,
      'role': role,
    };
    if (prenom != null) data['prenom'] = prenom;
    if (nomFamille != null) data['nom_famille'] = nomFamille;
    if (dateInscription != null) data['date_inscription'] = dateInscription!.toIso8601String();
    if (derniereConnexion != null) data['derniere_connexion'] = derniereConnexion!.toIso8601String();
    if (token != null) data['token'] = token;
    return data;
  }

  // Pour l'écran de profil, combinant prénom et nom
  String get fullName {
    return '${prenom ?? ''} ${nomFamille ?? ''}'.trim();
  }
}