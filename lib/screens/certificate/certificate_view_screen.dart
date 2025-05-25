import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/certificate_model.dart'; // Nouveau modèle
import '../../utils/app_colors.dart';

class CertificateViewScreen extends StatelessWidget {
  final CertificateModel certificate; // Utilise le nouveau CertificateModel

  const CertificateViewScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: eduLearnCardBg, // Fond blanc pour cette AppBar
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Certificate",
          style: GoogleFonts.poppins(
              color: eduLearnTextBlack, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: eduLearnPrimary),
            tooltip: "Share Certificate",
            onPressed: () {
              Share.share(
                'Check out my certificate for ${certificate.certificateName} from ${certificate.issuingOrganizationName}! Score: ${certificate.score.toInt()}%',
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
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: certificateBgColor, // Couleur spécifique pour le certificat
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: certificateBorderColor, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
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
                        const Icon(Icons.business_center_outlined, size: 40, color: eduLearnTextGrey),
                  ),
                if (certificate.organizationLogoAsset != null) const SizedBox(height: 10),
                Text(
                  certificate.issuingOrganizationName, // Nouveau champ
                  style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: eduLearnTextBlack),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "CERTIFICATE OF ${certificate.isAchieved ? 'ACHIEVEMENT' : 'PARTICIPATION'}",
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: eduLearnPrimary,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 15),
                Text(
                  "This certifies that",
                  style: GoogleFonts.lato(fontSize: 14, color: eduLearnTextGrey),
                ),
                const SizedBox(height: 8),
                Text(
                  certificate.recipientName, // Nouveau champ
                  style: GoogleFonts.merriweather(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: eduLearnTextBlack),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "has successfully ${certificate.isAchieved ? 'completed' : 'participated in'} the course",
                  style: GoogleFonts.lato(fontSize: 14, color: eduLearnTextGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  certificate.certificateName, // Ancien courseName
                  style: GoogleFonts.merriweather(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: eduLearnTextBlack.withOpacity(0.85)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "Achieved Score: ${certificate.score.toInt()}%",
                   style: GoogleFonts.lato(fontSize: 15, color: eduLearnTextBlack, fontWeight: FontWeight.w500),
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
                          style: GoogleFonts.lato(fontSize: 12, color: eduLearnTextGrey),
                        ),
                        Text(
                          certificate.dateObtainedFormatted, // Utilise le getter formaté
                          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Certificate ID",
                          style: GoogleFonts.lato(fontSize: 12, color: eduLearnTextGrey),
                        ),
                        Text(
                          certificate.certificateNumber, // Ancien certificateId
                          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Icon(
                  certificate.isAchieved ? Icons.verified_user_outlined : Icons.hourglass_bottom_rounded,
                  size: 50,
                  color: certificate.isAchieved ? eduLearnSuccess : eduLearnWarning
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}