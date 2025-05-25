import 'package:flutter/foundation.dart';

// Basé sur `CertificateResponse` et `Certificate` dans certificate.ts
class CertificateModel {
  final String id; // `id` dans le `Certificate` transformé du TS (était int pour `CertificateResponse`)
  final String userId; // `user_id` de `CertificateResponse`
  final String certificateName; // `certificate.certificateName`
  final String certificateNumber; // `certificate.certificateNumber`
  final DateTime dateIssued; // `certificate.createdAt`
  final int? quizId; // `certificate.quiz_id`
  final double score; // `score` de `CertificateResponse`

  // Champs spécifiques à l'UI mobile (peuvent être dérivés ou ajoutés)
  final String issuingOrganizationName; // Non présent dans le TS, à ajouter pour l'UI
  final String recipientName; // Nom de l'utilisateur, à obtenir séparément
  final String? organizationLogoAsset; // Pour l'UI
  final String certificateDisplayAsset; // Mini image pour la liste

  CertificateModel({
    required this.id,
    required this.userId,
    required this.certificateName,
    required this.certificateNumber,
    required this.dateIssued,
    this.quizId,
    required this.score,
    // UI specific
    required this.issuingOrganizationName,
    required this.recipientName,
    this.organizationLogoAsset,
    required this.certificateDisplayAsset,
  });

  String get dateObtainedFormatted {
    // Formatter la date comme "Oct 15, 2023"
    const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${monthNames[dateIssued.month - 1]} ${dateIssued.day}, ${dateIssued.year}";
  }

  bool get isAchieved => score >= 70; // Seuil de réussite, similaire à `status` dans TS

  // Si vous voulez un factory constructor depuis un JSON
  // Cela nécessiterait d'aplatir la structure de CertificateResponse
  factory CertificateModel.fromWebResponse(Map<String, dynamic> json, String currentUserName) {
    final certData = json['certificate'] as Map<String, dynamic>;
    return CertificateModel(
      id: json['id'].toString(),
      userId: json['user_id'],
      certificateName: certData['certificateName'],
      certificateNumber: certData['certificateNumber'],
      dateIssued: DateTime.parse(certData['createdAt']),
      quizId: certData['quiz_id'],
      score: (json['score'] as num).toDouble(),
      // UI specific - Mettez des valeurs par défaut ou cherchez-les si disponibles
      issuingOrganizationName: "EduLearn Platform", // Placeholder
      recipientName: currentUserName,
      organizationLogoAsset: 'assets/logo_edulearn.png', // Placeholder
      certificateDisplayAsset: 'assets/certificate_thumb_default.png', // Placeholder
    );
  }
}