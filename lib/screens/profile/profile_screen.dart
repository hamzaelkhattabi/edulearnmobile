import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/certificate_model.dart';
import '../../models/profile_model.dart'; // Contient EnrolledCourseModel et UserProfileModel
import '../../utils/app_colors.dart';
import '../certificate/certificate_view_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // Données factices pour l'utilisateur
  final UserProfileModel userProfile = UserProfileModel(
    uid: "user123",
    fullName: "Hamza Edu",
    userName: "hamza_edu",
    email: "hamza@example.com",
    avatarUrl: "assets/profile_avatar.png", // Assurez-vous que cet asset existe
    // levelId, specialityId, dob peuvent être ajoutés
  );

  // Données factices pour les cours inscrits
  final List<EnrolledCourseModel> enrolledCourses = [
    EnrolledCourseModel(
        courseId: "1", // Doit correspondre à un ID de CourseModel
        title: "Développement Web Full Stack",
        instructor: "Jane Doe",
        imageUrl: "assets/course_thumb_python.png", // Remplacez par de vrais assets
        totalLessons: 12, // Correspond au nombre de chapitres du cours
        completedLessons: 8),
    EnrolledCourseModel(
        courseId: "2",
        title: "Design UI/UX pour Mobiles",
        instructor: "John Smith",
        imageUrl: "assets/course_thumb_web.png", // Remplacez par de vrais assets
        totalLessons: 8,
        completedLessons: 8),
  ];

  // Données factices pour les certificats (utilisant le nouveau CertificateModel)
  final List<CertificateModel> userCertificates = [
    CertificateModel(
      id: "cert_001",
      userId: "user123",
      certificateName: "Python Fundamentals Certificate",
      certificateNumber: "CERT-PY-1023-001",
      dateIssued: DateTime(2023, 10, 15),
      quizId: 101, // ID du quiz qui a donné ce certificat
      score: 85.0,
      issuingOrganizationName: "EduLearn Academy",
      recipientName: "Hamza Edu", // Doit correspondre à userProfile.fullName
      organizationLogoAsset: "assets/logo_edulearn.png", // Logo de votre plateforme
      certificateDisplayAsset: "assets/certificate_thumb_python.png", // Mini image
    ),
    CertificateModel(
      id: "cert_002",
      userId: "user123",
      certificateName: "Web Design Master Certificate",
      certificateNumber: "CERT-WD-1123-005",
      dateIssued: DateTime(2023, 11, 22),
      quizId: 201,
      score: 92.0,
      issuingOrganizationName: "EduLearn Design Institute",
      recipientName: "Hamza Edu",
      organizationLogoAsset: "assets/logo_edulearn.png",
      certificateDisplayAsset: "assets/certificate_thumb_web.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: eduLearnBackground, // Thème global
      appBar: AppBar(
        // backgroundColor: eduLearnBackground, // Thème global
        // elevation: 0, // Thème global
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
                decoration: BoxDecoration(
                    color: eduLearnCardBg,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)]),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20)),
          ),
        ),
        title: Text("My Profile"), // Thème global
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: eduLearnTextGrey),
            tooltip: "Edit Profile",
            onPressed: () {
              // TODO: Action pour éditer le profil
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
            enrolledCourses.isEmpty
              ? _buildEmptyState("You haven't enrolled in any courses yet.")
              : _buildEnrolledCoursesList(),
            const SizedBox(height: 30),
            _buildSectionTitle("My Certificates"),
            const SizedBox(height: 16),
            userCertificates.isEmpty
              ? _buildEmptyState("You haven't earned any certificates yet.")
              : _buildCertificatesList(context), // Passer le context
            const SizedBox(height: 20),
             TextButton.icon(
              icon: const Icon(Icons.logout_rounded, color: eduLearnError),
              label: Text("Logout", style: GoogleFonts.poppins(color: eduLearnError)),
              onPressed: (){
                // TODO: Logique de déconnexion
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                  side: BorderSide(color: eduLearnError.withOpacity(0.5))
                )
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
     return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(userProfile.avatarUrl),
          onBackgroundImageError: (e,s) {},
          child: Image.asset(userProfile.avatarUrl, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 50, color: eduLearnTextGrey)),
        ),
        const SizedBox(height: 12),
        Text(
          userProfile.fullName,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: eduLearnTextBlack),
        ),
        const SizedBox(height: 4),
        Text(
          userProfile.email,
          style: GoogleFonts.poppins(fontSize: 15, color: eduLearnTextGrey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
     return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: eduLearnTextBlack),
      ),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_dissatisfied_outlined, size: 50, color: eduLearnTextGrey.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: eduLearnTextGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledCoursesList() {
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
            color: eduLearnCardBg,
            borderRadius: BorderRadius.circular(kDefaultBorderRadius),
            boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5) ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  course.imageUrl,
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      width: 70, height: 70, color: Colors.grey.shade200,
                      child: const Icon(Icons.school_outlined, color: Colors.grey, size: 30)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "By ${course.instructor}",
                      style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: course.progress,
                            backgroundColor: eduLearnPrimary.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(eduLearnPrimary),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${(course.progress * 100).toInt()}%",
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: eduLearnPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                     Text(
                      "${course.completedLessons}/${course.totalLessons} chapters",
                      style: GoogleFonts.poppins(fontSize: 11, color: eduLearnTextLightGrey),
                    ),
                  ],
                ),
              ),
               IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: eduLearnTextGrey, size: 18),
                onPressed: (){
                  // TODO: Naviguer vers CourseDetailsScreen avec le bon CourseModel
                  // Cela nécessite de pouvoir retrouver le CourseModel complet à partir de course.courseId
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Navigation vers détails du cours ${course.title} à implémenter.")));
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertificateCard(BuildContext context, CertificateModel certificate) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: eduLearnCardBg,
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              certificate.certificateDisplayAsset,
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8.0)),
                child: const Icon(Icons.workspace_premium_outlined, color: eduLearnPrimary, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.certificateName,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Issued by: ${certificate.issuingOrganizationName}",
                  style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
                ),
                const SizedBox(height: 2),
                Text(
                  "Date: ${certificate.dateObtainedFormatted}",
                  style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: eduLearnPrimary),
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

  Widget _buildCertificatesList(BuildContext context) { // Ajout de context
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userCertificates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCertificateCard(context, userCertificates[index]);
      },
    );
  }
}