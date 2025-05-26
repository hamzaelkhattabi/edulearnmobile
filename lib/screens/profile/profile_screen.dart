import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Pour AuthProvider si utilisé

import '../../models/certificate_model.dart';
import '../../models/user_model.dart'; // Utiliser notre UserModel principal
import '../../models/enrollment_model.dart'; // Utiliser notre EnrollmentModel
import '../../models/course_model.dart'; // Pour naviguer vers les détails du cours
import '../../utils/app_colors.dart';
import '../../utils/api_constants.dart'; // Pour construire URL d'avatar si relative
import '../certificate/certificate_view_screen.dart';
import '../courses/course_details_screen.dart'; // Pour la navigation

import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/certificate_service.dart';
// import '../../providers/auth_provider.dart'; // Si utilisé

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final CertificateService _certificateService = CertificateService();

  UserModel? _userProfile;
  Future<List<EnrollmentModel>>? _enrolledCoursesFuture;
  Future<List<CertificateModel>>? _userCertificatesFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if(mounted) setState(() { _isLoading = true; });
    try {
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // UserModel? user = authProvider.user;
      // if (user == null) { // Si pas dans le provider, fetch depuis le service
      //   user = await _authService.getMe(); // getMe pourrait utiliser le token stocké
      // }
      UserModel? user = await _authService.getCurrentUserFromStorage();
      if (user == null) { // Tenter de fetch depuis l'API si non stocké ou invalide
        user = await _authService.getMe();
      }


      if (user != null) {
        if(mounted) {
          setState(() {
            _userProfile = user;
            _enrolledCoursesFuture = _enrollmentService.getMyEnrollments();
            _userCertificatesFuture = _certificateService.getMyCertificates();
          });
        }
      } else {
        // L'utilisateur n'est pas authentifié, le rediriger vers login
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement du profil: ${e.toString()}"), backgroundColor: eduLearnError),
        );
        // Optionnel: Rediriger vers login si getMe échoue à cause de l'authentification
        if (e.toString().toLowerCase().contains('authentication') || e.toString().toLowerCase().contains('unauthorized')) {
           Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
      }
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _logout() async {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // await authProvider.logout();
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
                decoration: BoxDecoration(
                    color: eduLearnCardBg, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)]),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: eduLearnTextBlack, size: 20)),
          ),
        ),
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: _isLoading || _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(_userProfile!),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Mes Courses"),
                  const SizedBox(height: 16),
                  _buildEnrolledCoursesList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Mes Certificats"),
                  const SizedBox(height: 16),
                  _buildCertificatesList(context),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    icon: const Icon(Icons.logout_rounded, color: eduLearnError),
                    label: Text("Logout", style: GoogleFonts.poppins(color: eduLearnError)),
                    onPressed: _logout,
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

  Widget _buildProfileHeader(UserModel user) {
    String avatarUrl = /* user.avatarUrl ?? */ 'assets/profile_avatar.png'; // Prioriser l'URL de l'API si disponible

    // Si l'API ne fournit pas l'avatar, utiliser celui par défaut.
    // Si l'API fournit un chemin relatif, il faudrait le construire avec ApiConstants.baseUrl.
    // if (user.avatarUrl != null && !user.avatarUrl!.startsWith('http')) {
    //   avatarUrl = ApiConstants.baseUrl.replaceAll("/api", "") + user.avatarUrl!;
    // }

     return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade200,
          child: avatarUrl.startsWith('assets/')
            ? ClipOval(child: Image.asset(avatarUrl, fit: BoxFit.cover, width: 100, height: 100, errorBuilder: (c,e,s) => _defaultAvatar()))
            : ClipOval(child:Image.network(avatarUrl, fit: BoxFit.cover, width: 100, height: 100, errorBuilder: (c,e,s) => _defaultAvatar())),
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName.isNotEmpty ? user.fullName : user.nomUtilisateur,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: eduLearnTextBlack),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.poppins(fontSize: 15, color: eduLearnTextGrey),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return const Icon(Icons.person, size: 50, color: eduLearnTextGrey);
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
    return FutureBuilder<List<EnrollmentModel>>(
      future: _enrolledCoursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildEmptyState("Erreur de chargement des cours: ${snapshot.error.toString()}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState("Vous n'êtes inscrit à aucun cours pour le moment.");
        }

        final enrolledCourses = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enrolledCourses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final enrollment = enrolledCourses[index];
            final course = enrollment.course; // Le modèle Course est imbriqué
            if (course == null) return const SizedBox.shrink(); // Ne devrait pas arriver si l'API joint bien

            String courseImageUrl = course.imageUrl;
            if (!courseImageUrl.startsWith('http') && !courseImageUrl.startsWith('assets/')) {
              courseImageUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (courseImageUrl.startsWith('/') ? courseImageUrl : '/$courseImageUrl') ;
            }

            return InkWell( // Ajout de InkWell pour la navigation
              onTap: () {
                // Naviguer vers CourseDetailsScreen avec le CourseModel complet.
                // L'objet `course` ici vient de la jointure de `getMyEnrollments`.
                // S'il ne contient pas tous les détails (comme les leçons), CourseDetailsScreen les chargera.
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CourseDetailsScreen(courseInput: course)),
                );
              },
              child: Container(
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
                      child: courseImageUrl.startsWith('assets/')
                          ? Image.asset(courseImageUrl, width: 70, height: 70, fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => _courseThumbErrorPlaceholder())
                          : Image.network(courseImageUrl, width: 70, height: 70, fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => _courseThumbErrorPlaceholder(),
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(width:70, height: 70, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
                              },
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.courseName,
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: eduLearnTextBlack),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "By ${course.instructorName}",
                            style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: enrollment.progressionPourcentage / 100,
                                  backgroundColor: eduLearnPrimary.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(eduLearnPrimary),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${enrollment.progressionPourcentage.toInt()}%",
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: eduLearnPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                           Text( // Afficher la progression en leçons si disponible
                             // Il faudrait le nombre de leçons complétées et total ici
                             // ce qui n'est pas directement dans EnrollmentModel ou CourseModel simple.
                             // L'API getMyEnrollments devrait enrichir ces données.
                             // Pour l'instant, on peut afficher juste le pourcentage.
                            "${(enrollment.progressionPourcentage / 100 * course.lessonCount).round()}/${course.lessonCount} chapters",
                            style: GoogleFonts.poppins(fontSize: 11, color: eduLearnTextLightGrey),
                          ),
                        ],
                      ),
                    ),
                     const Icon(Icons.arrow_forward_ios_rounded, color: eduLearnTextGrey, size: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget _courseThumbErrorPlaceholder() {
      return Container(
          width: 70, height: 70, color: Colors.grey.shade200,
          child: const Icon(Icons.school_outlined, color: Colors.grey, size: 30));
  }


  Widget _buildCertificateCard(BuildContext context, CertificateModel certificate) {
    String displayAssetUrl = certificate.certificateDisplayAsset ?? 'assets/certificate_thumb_default.png';
    if (!displayAssetUrl.startsWith('http') && !displayAssetUrl.startsWith('assets/')) {
       displayAssetUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (displayAssetUrl.startsWith('/') ? displayAssetUrl : '/$displayAssetUrl') ;
    }

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
             child: displayAssetUrl.startsWith('assets/')
              ? Image.asset(displayAssetUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => _certThumbErrorPlaceholder())
              : Image.network(displayAssetUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => _certThumbErrorPlaceholder(),
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(width:60, height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
                  },
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
                  "Date: ${certificate.dateObtainedFormatted}", // Assurez-vous que cette méthode existe
                  style: GoogleFonts.poppins(fontSize: 12, color: eduLearnTextGrey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: eduLearnPrimary),
            tooltip: "View Certificate",
            onPressed: () {
              // L'objet `certificate` doit déjà être le modèle complet nécessaire
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

  Widget _certThumbErrorPlaceholder(){
    return Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8.0)),
        child: const Icon(Icons.workspace_premium_outlined, color: eduLearnPrimary, size: 30),
    );
  }


  Widget _buildCertificatesList(BuildContext context) {
    return FutureBuilder<List<CertificateModel>>(
      future: _userCertificatesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildEmptyState("Erreur de chargement des certificats: ${snapshot.error.toString()}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState("Vous n'avez aucun certificat pour le moment.");
        }
        final certificates = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: certificates.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildCertificateCard(context, certificates[index]);
          },
        );
      },
    );
  }
}