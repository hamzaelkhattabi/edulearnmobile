import 'package:flutter/material.dart';
// Assurez-vous d'importer votre CourseDetailsScreen et CourseModel
import '../../models/course_model.dart'; // Ajustez le chemin si nécessaire
import '../courses/course_details_screen.dart'; // Ajustez le chemin vers votre course_details_screen.dart

// ... (vos constantes de couleur existantes) ...
const Color primaryRed = Color(0xFFF45B69);
const Color lightPinkChipBg = Color(0xFFFDEEF0);
const Color textBlack = Color(0xFF1F2024);
const Color textGrey = Color(0xFF6D6D6D);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisez votre modèle CourseModel pour les données
    final List<CourseModel> courses = [
      CourseModel(
        id: "course_1",
        imageUrl: "assets/course_image_1.png",
        title: "How to design creative patt\nin illustrator",
        rating: 4.8,
        duration: "2.4 Hrs",
        instructorName: "Ronnie Abs",
        instructorAvatar: "assets/instructor_ronnie.png",
        price: 68.99,
        description: "Dive deep into Illustrator to create stunning patterns. Learn from industry expert Ronnie Abs and unlock your creative potential. This course covers basics to advanced techniques.",
        studentCount: 2150,
        lessonCount: 15,
      ),
      CourseModel(
        id: "course_2",
        imageUrl: "assets/course_image_2.png",
        title: "About to flying with drone\nin illustrator", // Le titre original semblait un peu étrange, ajustez si besoin
        rating: 4.8,
        duration: "3.0 Hrs",
        instructorName: "Jenni Pen",
        instructorAvatar: "assets/instructor_jenni.png",
        price: 75.50,
        description: "Master the art of drone videography and integrate your footage with Illustrator projects. Jenni Pen guides you through flight basics, safety, and creative editing workflows.",
        studentCount: 1780,
        lessonCount: 18,
      ),
    ];

    final List<Map<String, dynamic>> categories = [
      {"icon": Icons.palette_outlined, "name": "Arts", "color": Colors.orangeAccent.shade100.withOpacity(0.6)},
      {"icon": Icons.design_services_outlined, "name": "Design", "color": Colors.purpleAccent.shade100.withOpacity(0.6)},
      {"icon": Icons.volume_up_outlined, "name": "Marketing", "color": Colors.pinkAccent.shade100.withOpacity(0.6)},
      {"icon": Icons.code_outlined, "name": "Coding", "color": Colors.lightBlueAccent.shade100.withOpacity(0.6)},
    ];

    return Scaffold(
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
              _buildCategoriesList(categories),
              const SizedBox(height: 30),
              _buildSectionTitle("Enroll Course", showSeeAll: true),
              const SizedBox(height: 15),
              // Passez le contexte à _buildCoursesList si la navigation se fait à partir de là
              _buildCoursesList(context, courses),
            ],
          ),
        ),
      ),
    );
  }

  // ... (vos méthodes _buildHeader, _buildMainTitle, etc. restent les mêmes) ...
   Widget _buildHeader(BuildContext context) { // Ajout de context ici si non déjà présent
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: const AssetImage('assets/profile_avatar.png'),
                onBackgroundImageError: (exception, stackTrace) {},
                child: Image.asset(
                  'assets/profile_avatar.png',
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 22);
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Hi, Ronnie", // Vous pouvez rendre cela dynamique plus tard
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: textBlack),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: textGrey, size: 28),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
    );
  }

  Widget _buildMainTitle() { // Code existant
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textBlack, height: 1.3),
        children: <TextSpan>[
          TextSpan(text: 'Find a course you\n'),
          TextSpan(text: 'want to learn.', style: TextStyle(color: primaryRed)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() { // Code existant
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for course...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryRed,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 26),
        ),
      ],
    );
  }

  Widget _buildSubjectChips() { // Code existant
    final subjects = ["Python", "Graphic Design", "Development"];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(subjects[index]),
            selected: false,
            onSelected: (selected) {},
            backgroundColor: lightPinkChipBg,
            labelStyle: const TextStyle(color: primaryRed, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.pink.shade100, width: 0.5)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeAll = false}) { // Code existant
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: textBlack),
        ),
        if (showSeeAll)
          Text(
            "See all",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildCategoriesList(List<Map<String, dynamic>> categories) { // Code existant
    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category["color"],
                  shape: BoxShape.circle,
                ),
                child: Icon(category["icon"], color: Colors.black87.withOpacity(0.7), size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                category["name"],
                style: TextStyle(fontSize: 13, color: textGrey, fontWeight: FontWeight.w500),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 20),
      ),
    );
  }


  // MODIFICATION ICI DANS _buildCoursesList
  Widget _buildCoursesList(BuildContext context, List<CourseModel> courses) { // Ajout du context et changement du type de la liste
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index]; // Maintenant c'est un objet CourseModel
          return GestureDetector( // Ou InkWell pour un effet de splash
            onTap: () {
              // Navigation vers CourseDetailsScreen en passant l'objet course
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsScreen(course: course),
                ),
              );
              // Ou si vous avez une route nommée qui gère les arguments:
              // Navigator.pushNamed(context, '/course_details', arguments: course);
            },
            child: Card(
              elevation: 2.0,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: SizedBox(
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                      child: Image.asset(
                        course.imageUrl, // Utiliser course.imageUrl
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 130,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
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
                              Text("${course.rating}", style: TextStyle(color: textGrey.withOpacity(0.8), fontWeight: FontWeight.w500)),
                              const Spacer(),
                              const Icon(Icons.timer_outlined, color: textGrey, size: 16),
                              const SizedBox(width: 4),
                              Text(course.duration, style: const TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.title, // Utiliser course.title
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textBlack, height: 1.3),
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
                                    course.instructorAvatar, // Utiliser course.instructorAvatar
                                    fit: BoxFit.cover,
                                    width: 30,
                                    height: 30,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person, size: 15, color: textGrey);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(course.instructorName, style: const TextStyle(color: textGrey, fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: lightPinkChipBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "\$${course.price}", // Utiliser course.price
                                  style: const TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
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