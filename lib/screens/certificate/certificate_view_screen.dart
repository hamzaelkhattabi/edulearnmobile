import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart'; // Ajoutez share_plus à pubspec.yaml

// Importez votre modèle de certificat
import '../../models/certificate_model.dart'; // Ajustez le chemin si nécessaire

// Couleurs (vous pouvez les centraliser)
const Color primaryAppColor = Color(0xFFF45B69);
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const Color certificateBgColor = Color(0xFFFDFBF6); // Un fond crème léger pour le certificat
const Color certificateBorderColor = Color(0xFFEAE0C8);

class CertificateViewScreen extends StatelessWidget {
  final Certificate certificate;

  const CertificateViewScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Un fond légèrement différent de la page précédente
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDarkColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Certificate",
          style: GoogleFonts.poppins(
              color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: primaryAppColor),
            tooltip: "Share Certificate",
            onPressed: () {
              // Logique de partage
              Share.share(
                'Check out my certificate for ${certificate.courseName} from ${certificate.issuingOrganization}!',
                subject: 'I earned a new certificate!',
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
            constraints: const BoxConstraints(maxWidth: 450), // Max width pour une meilleure lisibilité
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: certificateBgColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: certificateBorderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (certificate.organizationLogoAsset != null)
                  Image.asset(
                    certificate.organizationLogoAsset!,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business_center_outlined, size: 40, color: textGreyColor),
                  ),
                if (certificate.organizationLogoAsset != null) const SizedBox(height: 10),
                Text(
                  certificate.issuingOrganization,
                  style: GoogleFonts.merriweather( // Une police plus formelle/serif
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "CERTIFICATE OF ACHIEVEMENT",
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryAppColor,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 15),
                Text(
                  "This certifies that",
                  style: GoogleFonts.lato(fontSize: 14, color: textGreyColor),
                ),
                const SizedBox(height: 8),
                Text(
                  certificate.recipientName,
                  style: GoogleFonts.merriweather(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "has successfully completed the course",
                  style: GoogleFonts.lato(fontSize: 14, color: textGreyColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  certificate.courseName,
                  style: GoogleFonts.merriweather(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textDarkColor.withOpacity(0.85)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date Issued",
                          style: GoogleFonts.lato(fontSize: 12, color: textGreyColor),
                        ),
                        Text(
                          certificate.dateObtained,
                          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: textDarkColor),
                        ),
                      ],
                    ),
                    if (certificate.certificateId != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Certificate ID",
                            style: GoogleFonts.lato(fontSize: 12, color: textGreyColor),
                          ),
                          Text(
                            certificate.certificateId!,
                            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: textDarkColor),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Vous pourriez ajouter un QR code ici pour vérification, ou une signature factice
                const Icon(Icons.verified_user_outlined, size: 50, color: Colors.green)
              ],
            ),
          ),
        ),
      ),
    );
  }
}