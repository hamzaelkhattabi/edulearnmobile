import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/certificate_model.dart';
import '../../models/enrolled_course_model.dart';
import '../certificate/certificate_view_screen.dart';

// Utiliser les constantes de couleurs
const Color primaryAppColor = Color(0xFFF45B69);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const double kDefaultBorderRadius = 15.0;


class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // Données factices
  final String userName = "Ronnie Abs";
  final String userEmail = "ronnie.abs@example.com";
  final String userAvatar = "assets/profile_avatar.png"; // REMPLACEZ

  final List<EnrolledCourse> enrolledCourses = [
    EnrolledCourse(
        title: "Python for Beginners",
        instructor: "John Doe",
        imageUrl: "assets/course_thumb_python.png", // REMPLACEZ
        totalLessons: 20,
        completedLessons: 15),
    EnrolledCourse(
        title: "Advanced Web Development",
        instructor: "Jane Smith",
        imageUrl: "assets/course_thumb_web.png", // REMPLACEZ
        totalLessons: 35,
        completedLessons: 10),
    EnrolledCourse(
        title: "UI/UX Design Masterclass",
        instructor: "Alice Wonderland",
        imageUrl: "assets/course_thumb_uiux.png", // REMPLACEZ
        totalLessons: 25,
        completedLessons: 25),
  ];

  // NOUVELLES DONNÉES FACTICES POUR CERTIFICATS
  // Dans profile_screen.dart
  final List<Certificate> userCertificates = [
    Certificate(
      courseName: "Python Fundamentals Certificate",
      issuingOrganization: "Code Academy Pro",
      dateObtained: "Oct 15, 2023",
      certificateAsset: "assets/certificate_thumb_python.png",
      recipientName: "Ronnie Abs", // Assurez-vous que cela correspond à `userName`
      certificateId: "CERT-PY-1023-001",
      organizationLogoAsset: "assets/logo_code_academy.png", // REMPLACEZ
    ),
    Certificate(
      courseName: "Web Design Master Certificate",
      issuingOrganization: "Design Masters Institute",
      dateObtained: "Nov 22, 2023",
      certificateAsset: "assets/certificate_thumb_web.png",
      recipientName: "Ronnie Abs",
      certificateId: "CERT-WD-1123-005",
      organizationLogoAsset: "assets/logo_design_masters.png", // REMPLACEZ
    ),
     Certificate(
      courseName: "UI/UX Specialization",
      issuingOrganization: "Creative University",
      dateObtained: "Dec 01, 2023",
      certificateAsset: "assets/certificate_thumb_uiux.png",
      recipientName: "Ronnie Abs",
      organizationLogoAsset: "assets/logo_creative_uni.png", // REMPLACEZ
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
                decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3)
                    ]),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: textDarkColor, size: 20)),
          ),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(
              color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: textGreyColor),
            tooltip: "Edit Profile",
            onPressed: () {
              // Action pour éditer le profil
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildSectionTitle("My Enrolled Courses"),
            const SizedBox(height: 16),
            _buildEnrolledCoursesList(),
            const SizedBox(height: 30), // Espace avant la nouvelle section
            _buildSectionTitle("My Certificates"), // NOUVELLE SECTION
            const SizedBox(height: 16),
            _buildCertificatesList(), // NOUVELLE LISTE
            const SizedBox(height: 20), // Espace en bas
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    // ... (code inchangé)
     return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(userAvatar), // REMPLACEZ
          onBackgroundImageError: (e,s) {},
          child: Image.asset(userAvatar, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 50)),
        ),
        const SizedBox(height: 12),
        Text(
          userName,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textDarkColor),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: GoogleFonts.poppins(fontSize: 15, color: textGreyColor),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    // ... (code inchangé)
     return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textDarkColor),
      ),
    );
  }

  Widget _buildEnrolledCoursesList() {
    // ... (code inchangé, assurez-vous que `progress` est bien calculé)
     if (enrolledCourses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Text("You haven't enrolled in any courses yet.", style: GoogleFonts.poppins(color: textGreyColor)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: enrolledCourses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final course = enrolledCourses[index];
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5, ) ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  course.imageUrl, // REMPLACEZ
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      width: 70, height: 70, color: Colors.grey.shade200,
                      child: const Icon(Icons.school_rounded, color: Colors.grey, size: 30)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: textDarkColor),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "By ${course.instructor}",
                      style: GoogleFonts.poppins(fontSize: 12, color: textGreyColor),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: course.progress,
                            backgroundColor: primaryAppColor.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(primaryAppColor),
                            minHeight: 6,
                             borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${(course.progress * 100).toInt()}%",
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: primaryAppColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                     Text(
                      "${course.completedLessons}/${course.totalLessons} lessons",
                      style: GoogleFonts.poppins(fontSize: 11, color: textGreyColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // NOUVELLE MÉTHODE POUR AFFICHER LES CARTES DE CERTIFICATS
  Widget _buildCertificateCard(BuildContext context, Certificate certificate) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              certificate.certificateAsset, // REMPLACEZ
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.workspace_premium_outlined,
                    color: primaryAppColor, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.courseName,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDarkColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Issued by: ${certificate.issuingOrganization}",
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: textGreyColor),
                ),
                const SizedBox(height: 2),
                Text(
                  "Date: ${certificate.dateObtained}",
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: textGreyColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: primaryAppColor),
            tooltip: "View Certificate",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CertificateViewScreen(certificate: certificate),
                ),
              );
            },
          )
        ],
      ),
    );
  }
  // FIN NOUVELLE MÉTHODE

  // NOUVELLE MÉTHODE POUR CONSTRUIRE LA LISTE DES CERTIFICATS
  Widget _buildCertificatesList() {
    if (userCertificates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Text("You haven't earned any certificates yet.",
            style: GoogleFonts.poppins(color: textGreyColor)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userCertificates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        // Passer le BuildContext à _buildCertificateCard
        return _buildCertificateCard(context, userCertificates[index]);
      },
    );
  }
  // FIN NOUVELLE MÉTHODE
}