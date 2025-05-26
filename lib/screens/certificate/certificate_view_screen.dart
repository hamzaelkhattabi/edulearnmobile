// lib/screens/certificate/certificate_view_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/certificate_model.dart'; // Le CertificateModel mis à jour
import '../../utils/app_colors.dart';
import '../../utils/api_constants.dart'; // Pour construire l'URL du logo si relative

class CertificateViewScreen extends StatelessWidget {
  final CertificateModel certificate;

  const CertificateViewScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    // Déterminer comment charger le logo de l'organisation
    String? logoPath = certificate.organizationLogoAsset;
    Widget organizationLogoWidget;

    if (logoPath == null || logoPath.isEmpty) {
      organizationLogoWidget = const Icon(Icons.business_center_outlined, size: 60, color: eduLearnTextGrey);
    } else if (logoPath.startsWith('assets/')) {
      organizationLogoWidget = Image.asset(
        logoPath,
        height: 60,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.business_center_outlined, size: 60, color: eduLearnTextGrey),
      );
    } else { // Supposer que c'est une URL (complète ou relative)
      String fullLogoUrl = logoPath.startsWith('http')
          ? logoPath
          : ApiConstants.baseUrl.replaceAll("/api", "") + (logoPath.startsWith('/') ? logoPath : '/$logoPath');
      organizationLogoWidget = Image.network(
        fullLogoUrl,
        height: 60,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.business_center_outlined, size: 60, color: eduLearnTextGrey),
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0,)));
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Un fond neutre
      appBar: AppBar(
        backgroundColor: eduLearnCardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Certificate", // Le titre reste statique
          style: GoogleFonts.poppins(
              color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: eduLearnPrimary),
            tooltip: "Share Certificate",
            onPressed: () {
              // Assurez-vous que tous les champs utilisés existent bien dans CertificateModel
              // (certificateName, issuingOrganizationName, score).
              // Le `certificate.certificateUrl` pourrait être partagé aussi.
              String shareText = 'Check out my certificate for "${certificate.certificateName}" from ${certificate.issuingOrganizationName}!';
              if (certificate.score != null) {
                 shareText += ' Score: ${certificate.score!.toInt()}%';
              }
              if (certificate.certificateUrl != null && certificate.certificateUrl!.isNotEmpty) {
                shareText += '\nView it here: ${certificate.certificateUrl}';
              }
              Share.share(
                shareText,
                subject: 'I earned a new certificate from EduLearn!',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            decoration: BoxDecoration(
              color: certificate.isAchieved ? certificateBgColor : certificateBgColor.withOpacity(0.8) , // Utilisez vos couleurs
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: certificate.isAchieved ? certificateBorderColor : Colors.grey.shade400, width: 2.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                organizationLogoWidget,
                const SizedBox(height: 12),
                Text(
                  certificate.issuingOrganizationName,
                  style: GoogleFonts.merriweather(
                      fontSize: 20, // Un peu plus grand
                      fontWeight: FontWeight.bold,
                      color: eduLearnTextBlack),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  "CERTIFICATE OF ${certificate.isAchieved ? 'ACHIEVEMENT' : 'COMPLETION'}", // ou PARTICIPATION
                  style: GoogleFonts.poppins(
                      fontSize: 16, // Un peu plus grand
                      fontWeight: FontWeight.w700, // Plus gras
                      color: certificate.isAchieved ? eduLearnPrimary : eduLearnTextGrey,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 20),
                Text(
                  "This certifies that",
                  style: GoogleFonts.lato(fontSize: 15, color: eduLearnTextGrey),
                ),
                const SizedBox(height: 10),
                Text(
                  certificate.recipientName, // Ce champ est dans CertificateModel
                  style: GoogleFonts.merriweather( // Police plus "prestigieuse"
                      fontSize: 28, // Plus grand
                      fontWeight: FontWeight.bold,
                      color: eduLearnTextBlack),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                 Text(
                  "has successfully ${certificate.isAchieved ? 'completed' : 'participated in'} and demonstrated proficiency in:", // Ou une phrase adaptée si pas "achieved"
                  style: GoogleFonts.lato(fontSize: 15, color: eduLearnTextGrey, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  certificate.certificateName, // C'est le nom du certificat/cours
                  style: GoogleFonts.merriweather(
                      fontSize: 22, // Plus grand
                      fontWeight: FontWeight.w600,
                      color: eduLearnTextBlack.withOpacity(0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (certificate.score != null)
                    Text(
                        "Achieved Score: ${certificate.score!.toStringAsFixed(0)}%", //toStringAsFixed(0) pour enlever .0
                        style: GoogleFonts.lato(fontSize: 16, color: eduLearnTextBlack, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                    ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date Issued", style: GoogleFonts.lato(fontSize: 13, color: eduLearnTextGrey, fontWeight: FontWeight.w500)),
                        Text(
                          certificate.dateObtainedFormatted, // Utilise le getter du modèle
                          style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                        ),
                      ],
                    ),
                    // Remplacer certificateNumber par quelque chose de significatif si ce n'est pas l'ID de la BDD.
                    // S'il n'y a pas de numéro de certificat unique "public", on peut omettre cette partie.
                    // if (certificate.certificateNumber != null && certificate.certificateNumber!.isNotEmpty)
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text("Certificate ID", style: GoogleFonts.lato(fontSize: 13, color: eduLearnTextGrey, fontWeight: FontWeight.w500)),
                    //     Text(
                    //       certificate.certificateNumber!,
                    //       style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 30),
                Icon(
                  certificate.isAchieved ? Icons.verified_user_rounded : Icons.task_alt_rounded, // Ou Icons.emoji_events_rounded
                  size: 55,
                  color: certificate.isAchieved ? Colors.green.shade700 : eduLearnPrimary.withOpacity(0.8),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}