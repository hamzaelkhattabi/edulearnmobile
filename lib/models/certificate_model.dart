// lib/models/certificate_model.dart
import 'package:intl/intl.dart'; // Pour le formatage de date

class CertificateModel {
  final int id; // CertificatsUtilisateur.id
  final int userId; // CertificatsUtilisateur.utilisateur_id
  final int certificateDefinitionId; // CertificatsUtilisateur.certificat_id (qui est Certificats.id)
  final int courseId; // CertificatsUtilisateur.cours_id
  final DateTime dateIssued; // CertificatsUtilisateur.date_obtention
  final String? certificateUrl; // CertificatsUtilisateur.url_certificat_genere

  // Infos venant de Certificats (via jointure ou API combinée)
  final String certificateName; // Certificats.titre_certificat
  final String? certificateDescription; // Certificats.description_modele

  // Infos venant de User (pour recipientName) et peut-être d'ailleurs pour l'organisation
  final String recipientName; // User.prenom + User.nom_famille
  final String issuingOrganizationName; // À déterminer d'où ça vient (peut-être fixe par plateforme ou par cours)
  final String? organizationLogoAsset; // Logo fixe pour la plateforme? Ou par cours?
  final String? certificateDisplayAsset; // Petite image pour la liste

  // Champs liés au quiz si applicable (pas directement dans CertificatsUtilisateur)
  final int? quizId;
  final double? score; // Score du quiz qui a mené au certificat

  CertificateModel({
    required this.id,
    required this.userId,
    required this.certificateDefinitionId,
    required this.courseId,
    required this.dateIssued,
    this.certificateUrl,
    required this.certificateName,
    this.certificateDescription,
    required this.recipientName,
    required this.issuingOrganizationName,
    this.organizationLogoAsset = "assets/logo_edulearn.png", // Valeur par défaut
    this.certificateDisplayAsset = "assets/certificate_thumb_default.png", // Valeur par défaut
    this.quizId,
    this.score,
  });

  // lib/models/certificate_model.dart
  // lib/models/certificate_model.dart
  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    // Accéder à l'objet User via la clé de l'alias "utilisateur"
    String prenom = json['utilisateur']?['prenom']?.toString() ?? '';
    String nomFamille = json['utilisateur']?['nom_famille']?.toString() ?? '';
    String nomUtilisateurFallback = json['utilisateur']?['nom_utilisateur']?.toString() ?? '';

    String recipientFullName = '${prenom} ${nomFamille}'.trim();
    if (recipientFullName.isEmpty) {
      recipientFullName = nomUtilisateurFallback.isNotEmpty ? nomUtilisateurFallback : (json['recipient_name_fallback']?.toString() ?? 'Utilisateur EduLearn');
    }

    // ... (le reste du parsing pour score, etc. que nous avions déjà vu)

    // Accéder aux données des modèles joints via leurs noms de modèle (si pas d'alias dans include)
    // OU via leurs alias si vous en avez défini dans le 'include' du contrôleur.
    // Pour Certificate et Course, si vous n'avez PAS mis d'alias explicite dans le 'include':
    String certificateTitle = json['Certificat']?['titre_certificat']?.toString() ?? 'Certificat Inconnu';
    String certificateDesc = json['Certificate']?['description_modele'] ?? ''; // Ou une valeur par défaut

    // Pour 'issuingOrganizationName' et 'organizationLogoAsset', vous devez décider de leur source.
    // S'ils sont dans la table 'Certificats' (la définition), vous y accédez via 'Certificate'.
    // Exemple:
    String issuingOrg = json['Certificate']?['nom_organisation_emettrice'] ?? 'EduLearn Academy';
    String logoAsset = json['Certificate']?['logo_organisation_url'] ?? 'assets/logo_edulearn.png';


    return CertificateModel(
      id: json['id'], // ID de CertificatsUtilisateur
      userId: json['utilisateur_id'],
      certificateDefinitionId: json['certificat_id'],
      courseId: json['cours_id'],
      dateIssued: DateTime.parse(json['date_obtention']),
      certificateUrl: json['url_certificat_genere'],
      
      certificateName: certificateTitle,
      certificateDescription: certificateDesc,
      
      recipientName: recipientFullName, // Maintenant, cela devrait utiliser l'alias "utilisateur"
      
      issuingOrganizationName: issuingOrg,
      organizationLogoAsset: logoAsset,
      certificateDisplayAsset: json['certificate_display_asset'] ?? 'assets/certificate_thumb_default.png',
                            
      quizId: json['Quiz']?['id'], 
      score: (json['QuizAttempt']?['score_obtenu'] as num?)?.toDouble(), 
    );
  }  String get dateObtainedFormatted {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(dateIssued);
  }

  // Remplacer par une logique dynamique si score vient de l'API
  bool get isAchieved => (score ?? 0) >= 70.0; // Seuil de réussite générique, adapter si besoin
}