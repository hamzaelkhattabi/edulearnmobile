import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/course_model.dart';
import '../../utils/app_colors.dart' as app_colors;
import '../courses/course_details_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // DONNÉES FACTICES UTILISANT LES NOUVEAUX MODÈLES
  // Normalement, ces données viendraient d'une API et seraient converties via CourseModel.fromJson
  static final List<CourseModel> _courses = [
    CourseModel(
      id: 1,
      courseName: "Développement Web Full Stack avec React & Node.js",
      teacherId: "prof_jane_doe",
      description: "Apprenez à construire des applications web complètes de A à Z avec les technologies les plus demandées. Ce cours couvre HTML, CSS, JavaScript, React pour le frontend, et Node.js, Express, MongoDB pour le backend.",
      isGlobal: true,
      chapters: [
        ChapterModel(id: 101, title: "Introduction au HTML & CSS", order: 1, courseId: 1, durationDisplay: "45 Mins", content: "Les bases du HTML et CSS..."),
        ChapterModel(id: 102, title: "JavaScript Fondamental", order: 2, courseId: 1, durationDisplay: "1h 15Mins", content: "Variables, fonctions, DOM...", isLocked: true),
      ],
      materials: [
        MaterialModel(id: 1, fileType: "pdf", path: "slides_intro.pdf", courseId: 1),
      ],
      imageUrl: "assets/course_image_1.png", // Assurez-vous que cet asset existe
      instructorName: "Jane Doe",
      instructorAvatar: "assets/instructor_jenni.png", // Assurez-vous que cet asset existe
      rating: 4.9,
      durationTotal: "45 Heures",
      studentCount: 3250,
      price: 89.99,
    ),
    CourseModel(
      id: 2,
      courseName: "Design UI/UX pour Applications Mobiles",
      teacherId: "prof_john_smith",
      description: "Maîtrisez les principes du design d'interface et d'expérience utilisateur pour créer des applications mobiles intuitives et esthétiques. Figma, prototypage, tests utilisateurs.",
      isGlobal: true,
      chapters: [
        ChapterModel(id: 201, title: "Principes du Design UI", order: 1, courseId: 2, durationDisplay: "30 Mins", content: "Grilles, typographie, couleurs..."),
        ChapterModel(id: 202, title: "Introduction à Figma", order: 2, courseId: 2, durationDisplay: "1h", content: "Outils de base, composants...", isLocked: false),
      ],
      imageUrl: "assets/course_image_2.png", // Assurez-vous que cet asset existe
      instructorName: "John Smith",
      instructorAvatar: "assets/instructor_ronnie.png", // Assurez-vous que cet asset existe
      rating: 4.7,
      durationTotal: "30 Heures",
      studentCount: 1890,
      price: 65.00,
    ),
  ];

  final List<Map<String, dynamic>> _categories = [
    {"icon": Icons.palette_outlined, "name": "Arts", "color": Colors.orangeAccent.shade100.withOpacity(0.6)},
    {"icon": Icons.design_services_outlined, "name": "Design", "color": Colors.purpleAccent.shade100.withOpacity(0.6)},
    {"icon": Icons.campaign_outlined, "name": "Marketing", "color": Colors.pinkAccent.shade100.withOpacity(0.6)}, // Icône changée
    {"icon": Icons.code_outlined, "name": "Coding", "color": Colors.lightBlueAccent.shade100.withOpacity(0.6)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: eduLearnBackground, // Thème global
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 25),
              _buildMainTitle(),
              const SizedBox(height: 25),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildSubjectChips(),
              const SizedBox(height: 30),
              _buildSectionTitle("Categories"),
              const SizedBox(height: 15),
              _buildCategoriesList(_categories),
              const SizedBox(height: 30),
              _buildSectionTitle("Enroll Course", showSeeAll: true),
              const SizedBox(height: 15),
              _buildCoursesList(context, _courses),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: const AssetImage('assets/profile_avatar.png'), // Assurez-vous que cet asset existe
                onBackgroundImageError: (exception, stackTrace) {}, // Gère les erreurs de chargement
                child: Image.asset('assets/profile_avatar.png', errorBuilder: (ctx, err, st) => const Icon(Icons.person, size: 22)),
              ),
              const SizedBox(width: 10),
              Text(
                "Hi, Hamza", // TODO: Rendre dynamique
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500, color: app_colors.eduLearnTextBlack),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: app_colors.eduLearnTextGrey, size: 28),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
      ],
    );
  }

  Widget _buildMainTitle() {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: app_colors.eduLearnTextBlack, height: 1.3),
        children: <TextSpan>[
          const TextSpan(text: 'Find a course\n'),
          TextSpan(text: 'you want to learn.', style: TextStyle(color: app_colors.eduLearnPrimary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration( // Utilise le thème global
              hintText: 'Search for course...',
              prefixIcon: Icon(Icons.search, color: app_colors.eduLearnTextGrey.withOpacity(0.7)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: app_colors.eduLearnPrimary,
            borderRadius: BorderRadius.circular(app_colors.kDefaultBorderRadius),
          ),
          child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 26),
        ),
      ],
    );
  }

  Widget _buildSubjectChips() {
    final subjects = ["Python", "Graphic Design", "Development", "Marketing"];
    return SizedBox(
      height: 42, // Augmenté un peu pour le padding des chips
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return ChoiceChip( // Utilise le thème global ChipTheme
            label: Text(subjects[index]),
            selected: index == 0, // Exemple: premier chip sélectionné
            onSelected: (selected) {
              // TODO: Logique de filtrage par sujet
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: app_colors.eduLearnTextBlack),
        ),
        if (showSeeAll)
          TextButton( // Utilisation de TextButton pour une meilleure sémantique
            onPressed: () {
              // TODO: Naviguer vers la page "See All"
            },
            child: Text(
              "See all",
              style: GoogleFonts.poppins(fontSize: 14, color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesList(List<Map<String, dynamic>> categories) {
    return SizedBox(
      height: 100, // Légèrement augmenté pour le texte
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18), // Augmenté pour une icône plus grande
                decoration: BoxDecoration(
                  color: category["color"],
                  shape: BoxShape.circle,
                ),
                child: Icon(category["icon"], color: app_colors.eduLearnTextBlack.withOpacity(0.7), size: 30), // Plus grande
              ),
              const SizedBox(height: 8),
              Text(
                category["name"],
                style: GoogleFonts.poppins(fontSize: 13, color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 20),
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context, List<CourseModel> courses) {
    return SizedBox(
      height: 320, // Maintenu
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsScreen(course: course),
                ),
              );
            },
            child: Card( // Utilisation de Card pour l'élévation et la forme
              elevation: 2.0,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(app_colors.kDefaultBorderRadius)),
              child: SizedBox( // Conteneur pour la largeur de la carte
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(app_colors.kDefaultBorderRadius)),
                      child: Image.asset(
                        course.imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 130,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.school_outlined, color: Colors.grey, size: 50)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text("${course.rating}", style: GoogleFonts.poppins(color: app_colors.eduLearnTextGrey.withOpacity(0.8), fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Icon(Icons.timer_outlined, color: app_colors.eduLearnTextGrey, size: 16),
                              const SizedBox(width: 4),
                              Text(course.durationTotal.split(" ").first, style: GoogleFonts.poppins(fontSize: 12, color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500)), // Afficher que le nombre d'heures
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.courseName, // Utiliser courseName
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: app_colors.eduLearnTextBlack, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.grey.shade200,
                                child: ClipOval(
                                  child: Image.asset(
                                    course.instructorAvatar,
                                    fit: BoxFit.cover, width: 30, height: 30,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 15, color: app_colors.eduLearnTextGrey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(course.instructorName, style: GoogleFonts.poppins(color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis,)),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: app_colors.eduLearnAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "\$${course.price.toStringAsFixed(2)}",
                                  style: GoogleFonts.poppins(color: app_colors.eduLearnPrimary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 15),
      ),
    );
  }
}