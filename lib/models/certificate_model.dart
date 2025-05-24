// Par exemple dans lib/pages/profile/models/certificate_model.dart
class Certificate {
  final String courseName;
  final String issuingOrganization;
  final String dateObtained;
  final String certificateAsset; // C'est une miniature, pour la page principale du certificat on utilisera peut-être une autre image
  final String recipientName; // Nom de l'utilisateur sur le certificat
  final String? certificateId; // Optionnel : un ID unique pour le certificat
  final String? organizationLogoAsset; // Optionnel : logo de l'organisation

  Certificate({
    required this.courseName,
    required this.issuingOrganization,
    required this.dateObtained,
    required this.certificateAsset, // La vignette pour la liste
    required this.recipientName,
    this.certificateId,
    this.organizationLogoAsset,
  });
}