import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Utiliser les constantes de couleurs
const Color primaryAppColor = Color(0xFFF45B69);
const Color lightBackground = Color(0xFFF9FAFC);
const Color cardBackgroundColor = Colors.white;
const Color textDarkColor = Color(0xFF1F2024);
const Color textGreyColor = Color(0xFF6A737D);
const double kDefaultBorderRadius = 15.0;

class EnrolledCourse {
  final String title;
  final String instructor;
  final String imageUrl;
  final int totalLessons;
  final int completedLessons;

  EnrolledCourse({
    required this.title,
    required this.instructor,
    required this.imageUrl,
    required this.totalLessons,
    required this.completedLessons,
  });

  double get progress => (completedLessons / totalLessons);
}

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
            onTap: () => Navigator.pop(context), // Ou action différente si c'est un onglet principal
            child: Container(
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                shape: BoxShape.circle,
                 boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3,) ]
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: textDarkColor, size: 20),
            ),
          ),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(color: textDarkColor, fontWeight: FontWeight.w600, fontSize: 18),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textDarkColor),
      ),
    );
  }

  Widget _buildEnrolledCoursesList() {
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
                             borderRadius: BorderRadius.circular(3), // Flutter 3.16+
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
}