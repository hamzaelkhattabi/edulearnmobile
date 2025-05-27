// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // À utiliser si vous avez un AuthProvider

import '../../models/course_model.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';
import '../../services/course_service.dart';
import '../../services/category_service.dart';
import '../../services/auth_service.dart'; // Utilisé pour charger l'utilisateur si pas via Provider
import '../../services/notification_service.dart';
import '../../utils/api_constants.dart'; // Pour construire les URLs d'images
import '../../utils/app_colors.dart' as app_colors; // Pour éviter les conflits de noms

// Assurez-vous que ce chemin est correct ou créez cet écran si besoin
import '../courses/course_details_screen.dart';
// import '../../providers/auth_provider.dart'; // Décommentez si vous utilisez un AuthProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CourseService _courseService = CourseService();
  final CategoryService _categoryService = CategoryService();
  final AuthService _authService = AuthService(); // Pour le chargement initial de l'utilisateur

  Future<List<CourseModel>>? _coursesFuture;
  Future<List<CategoryModel>>? _categoriesFuture;
  UserModel? _currentUser;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedSubjectFilter; // Si les sujets correspondent à des tags ou catégories spécifiques

  // Sujets pour les chips - Ceux-ci pourraient aussi venir de l'API
  // Pour l'instant, gardons-les statiques. Si dynamique, chargez-les avec un FutureBuilder.
  final List<String> _subjects = ["Python", "Graphic Design", "Development", "Marketing", "Business"];
  int _selectedSubjectIndex = -1; // -1 signifie aucune sélection

  final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    notificationService.initFirebaseMessaging();
  }

  Future<void> _loadInitialData() async {
    // Tenter de charger l'utilisateur depuis AuthProvider ou AuthService
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // if (authProvider.isAuthenticated && authProvider.user != null) {
    //   if (mounted) setState(() => _currentUser = authProvider.user);
    // } else {
      UserModel? userFromStorage = await _authService.getCurrentUserFromStorage();
       if (userFromStorage == null) { // Double vérification auprès de l'API
          try {
            userFromStorage = await _authService.getMe();
          } catch(e) {
            // Si getMe échoue (token invalide), rediriger vers login
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
            return;
          }
       }
      if (mounted) setState(() => _currentUser = userFromStorage);
    // }

    // Si _currentUser est null après ces tentatives, cela pourrait indiquer un problème,
    // mais HomeScreen pourrait toujours afficher du contenu public.

    _loadCategories();
    _loadCourses(); // Charge initialement tous les cours (ou selon filtres par défaut)
  }

  void _loadCourses({String? categoryId, String? searchQuery, String? subjectFilter}) {
    // Si on clique sur une catégorie, on met à jour _selectedCategoryId
    if (categoryId != null) {
      _selectedCategoryId = categoryId;
    }
    // si on cherche, on met à jour searchQuery (qui vient du _searchController.text)
    // si on sélectionne un sujet, on met à jour subjectFilter

    // Le CourseService devra gérer ces filtres, par exemple:
    // L'API `/courses` peut prendre `categorie_id`, `search_term`, `tag` comme query params
    // Ici on simplifie et on assume que categoryId est le principal filtre clair.
    // Le searchQuery sera géré par onSubmitted du TextField.
    // Le subjectFilter est plus conceptuel ici.
    setState(() {
      _coursesFuture = _courseService.getAllCourses(
          categoryId: _selectedCategoryId, // Utilise la catégorie sélectionnée
          searchQuery: searchQuery ?? _searchController.text,
          // subjectFilter: subjectFilter // à implémenter si besoin
      );
    });
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = _categoryService.getAllCategories();
    });
  }

  void _clearFiltersAndReloadCourses() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedSubjectIndex = -1;
      _selectedSubjectFilter = null;
      _loadCourses(); // Recharge avec les filtres par défaut (aucun)
  }


  Future<void> _refreshData() async {
    // Conserver les filtres actuels ou les réinitialiser selon le besoin
    _loadInitialData(); // recharge user
    _loadCategories();  // recharge categories
    _loadCourses(
      categoryId: _selectedCategoryId,
      searchQuery: _searchController.text,
      subjectFilter: _selectedSubjectFilter,
    ); // Recharge les cours avec les filtres actuels
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: app_colors.eduLearnPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, _currentUser),
                const SizedBox(height: 25),
                _buildMainTitle(),
                const SizedBox(height: 25),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildSubjectChips(),
                const SizedBox(height: 30),
                _buildSectionTitle("Categories"),
                const SizedBox(height: 15),
                _buildCategoriesListWidget(), // Renommé pour éviter confusion
                const SizedBox(height: 30),
                _buildSectionTitleWithClear("Courses", showSeeAll: true),
                const SizedBox(height: 15),
                _buildCoursesListWidget(context), // Renommé pour éviter confusion
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? currentUser) {
    String displayName = "Hi, Guest";
    String? avatarPath = 'assets/profile_avatar.png'; // Avatar par défaut

    if (currentUser != null) {
      displayName = "Hi, ${currentUser.prenom ?? currentUser.nomUtilisateur}";
      // Si UserModel a un champ `avatar_url` ou similaire
      // String? apiAvatarUrl = currentUser.avatarUrl;
      // if (apiAvatarUrl != null && apiAvatarUrl.isNotEmpty) {
      //   avatarPath = apiAvatarUrl.startsWith('http') ? apiAvatarUrl : ApiConstants.baseUrl.replaceAll("/api","") + apiAvatarUrl;
      // }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                child: (avatarPath != null && avatarPath.startsWith('assets/'))
                  ? ClipOval(child: Image.asset(avatarPath, fit:BoxFit.cover, width: 44, height: 44, errorBuilder: (ctx, err, st) => const Icon(Icons.person, size: 22)))
                  : (avatarPath != null && avatarPath.startsWith('http'))
                      ? ClipOval(child:Image.network(avatarPath, fit:BoxFit.cover, width: 44, height: 44, errorBuilder: (ctx, err, st) => const Icon(Icons.person, size: 22)))
                      : const Icon(Icons.person, size: 22), // Fallback
              ),
              const SizedBox(width: 10),
              Text(
                displayName,
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
          TextSpan(text: 'you want to learn', style: TextStyle(color: app_colors.eduLearnPrimary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for course...',
              prefixIcon: Icon(Icons.search, color: app_colors.eduLearnTextGrey.withOpacity(0.7)),
              // suffixIcon: _searchController.text.isNotEmpty ? IconButton(
              //   icon: Icon(Icons.clear),
              //   onPressed: (){ _searchController.clear(); _loadCourses(); }
              // ) : null,
            ),
            onSubmitted: (value) {
                _loadCourses(searchQuery: value);
            },
             onChanged: (value) { // Pour recherche en temps réel (optionnel, peut être lourd)
                 // if (value.isEmpty) _loadCourses(); // Si on efface la recherche, recharger
            },
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            // TODO: Afficher des filtres avancés (popup, bottom sheet)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Advanced filters TBD.")));
          },
          borderRadius: BorderRadius.circular(app_colors.kDefaultBorderRadius),
          child: Container(
            padding: const EdgeInsets.all(14), // Taille cohérente avec la hauteur du TextField
            decoration: BoxDecoration(
              color: app_colors.eduLearnPrimary,
              borderRadius: BorderRadius.circular(app_colors.kDefaultBorderRadius),
            ),
            child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectChips() {
    return SizedBox(
      height: 45, // Un peu plus d'espace pour les puces
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(_subjects[index]),
            selected: _selectedSubjectIndex == index,
            selectedColor: app_colors.eduLearnPrimary.withOpacity(0.2),
            labelStyle: TextStyle(
                color: _selectedSubjectIndex == index ? app_colors.eduLearnPrimary : app_colors.eduLearnTextGrey,
                fontWeight: FontWeight.w500),
            backgroundColor: app_colors.eduLearnAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: _selectedSubjectIndex == index ? app_colors.eduLearnPrimary : Colors.grey.shade300,
                  width: _selectedSubjectIndex == index ? 1 : 0.5
              )
            ),
            onSelected: (selected) {
              setState(() {
                _selectedSubjectIndex = selected ? index : -1; // Déselectionner si on reclique
                _selectedSubjectFilter = selected ? _subjects[index] : null;
                _loadCourses(subjectFilter: _selectedSubjectFilter); // Assurez-vous que getAllCourses gère ce filtre
                 print("Selected subject filter: $_selectedSubjectFilter");
              });
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }

  Widget _buildSectionTitle(String title) { // Section title simple
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: app_colors.eduLearnTextBlack),
    );
  }
  
  Widget _buildSectionTitleWithClear(String title, {bool showSeeAll = false}) {
    bool hasActiveFilter = _selectedCategoryId != null || _searchController.text.isNotEmpty || _selectedSubjectFilter != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: app_colors.eduLearnTextBlack),
        ),
        if (showSeeAll)
            TextButton(
                onPressed: () { /* TODO: Naviguer vers la page "See All" */
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("See All page not implemented.")));
                },
                child: Text( "See all", style: GoogleFonts.poppins(fontSize: 14, color: app_colors.eduLearnPrimary, fontWeight: FontWeight.w500)),
            ),
        if(hasActiveFilter && title == "Courses") // Afficher "Clear" seulement pour les cours et si un filtre est actif
           TextButton(
                onPressed: _clearFiltersAndReloadCourses,
                child: Text( "Clear filters", style: GoogleFonts.poppins(fontSize: 12, color: app_colors.eduLearnError, fontWeight: FontWeight.w500)),
            )
      ],
    );
  }

  Widget _buildCategoriesListWidget() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return SizedBox(height: 110, child: Center(child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center,)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 110, child: Center(child: Text("No categories found.")));
        }

        final categories = snapshot.data!;
        final List<Color> categoryColors = [
            Colors.orangeAccent.shade100, Colors.purpleAccent.shade100, Colors.pinkAccent.shade100,
            Colors.lightBlueAccent.shade100, Colors.greenAccent.shade100, Colors.tealAccent.shade100
        ];
         final Map<String, IconData> categoryIcons = { // Mapping simplifié, vous devrez l'améliorer
            "arts": Icons.palette_outlined, "art": Icons.palette_outlined,
            "design": Icons.design_services_outlined,
            "marketing": Icons.campaign_outlined,
            "coding": Icons.code_outlined, "développement": Icons.code_outlined,
            "business": Icons.business_center_outlined, "commerce": Icons.business_center_outlined,
            "data science": Icons.bar_chart_rounded,
            "photography": Icons.camera_alt_outlined,
        };

        return SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final color = categoryColors[index % categoryColors.length].withOpacity(0.7);
              final icon = categoryIcons[category.nomCategorie.toLowerCase()] ?? Icons.category_rounded;

              return InkWell(
                onTap: () {
                   _loadCourses(categoryId: category.id.toString());
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Courses for ${category.nomCategorie}")));
                },
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Icon(icon, color: app_colors.eduLearnTextBlack.withOpacity(0.8), size: 30),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.nomCategorie,
                      style: GoogleFonts.poppins(fontSize: 13, color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 20),
          ),
        );
      },
    );
  }

  Widget _buildCoursesListWidget(BuildContext context) {
    return FutureBuilder<List<CourseModel>>(
      future: _coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 320, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return SizedBox(height: 320, child: Center(child: Text("Error loading courses: ${snapshot.error}")));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 320, child: Center(child: Text("No courses match your criteria.")));
        }

        final courses = snapshot.data!;
        return SizedBox(
          height: 320, // Ajustez si nécessaire
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              String imageUrl = course.imageUrl;
              if (!imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
                  imageUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
              }
              String instructorAvatarUrl = course.instructorAvatar ?? 'assets/default_avatar.png';
               if (course.instructorAvatar != null && !course.instructorAvatar!.startsWith('http') && !course.instructorAvatar!.startsWith('assets/')) {
                  instructorAvatarUrl = ApiConstants.baseUrl.replaceAll("/api", "") + (course.instructorAvatar!.startsWith('/') ? course.instructorAvatar! : '/${course.instructorAvatar!}');
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailsScreen(courseInput: course),
                    ),
                  );
                },
                child: Card(
                  elevation: 3.0,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(app_colors.kDefaultBorderRadius)),
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero( // Ajout de Hero pour la transition d'image
                          tag: 'course_image_${course.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(app_colors.kDefaultBorderRadius)),
                            child: imageUrl.startsWith('assets/')
                                ? Image.asset(imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _courseImageErrorPlaceholder())
                                : Image.network(imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _courseImageErrorPlaceholder(),
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(height: 130, child: Center(child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2.0,
                                      )));
                                    },
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
                                  Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                                  const SizedBox(width: 4),
                                  Text(course.rating.toStringAsFixed(1), style: GoogleFonts.poppins(color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Icon(Icons.schedule_outlined, color: app_colors.eduLearnTextGrey, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.durationTotal.split(" ").first, // "45 Heures" -> "45"
                                    style: GoogleFonts.poppins(fontSize: 12, color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course.courseName,
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: app_colors.eduLearnTextBlack, height: 1.3),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10), // Un peu plus d'espace
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.grey.shade200,
                                    child: ClipOval(
                                      child: instructorAvatarUrl.startsWith('assets/')
                                          ? Image.asset(instructorAvatarUrl, fit: BoxFit.cover, width: 30, height: 30, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 15))
                                          : Image.network(instructorAvatarUrl, fit: BoxFit.cover, width: 30, height: 30, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 15)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(course.instructorName, style: GoogleFonts.poppins(fontSize: 13, color: app_colors.eduLearnTextGrey, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: app_colors.eduLearnAccent.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Details", // ou "Watch Now"
                                      style: GoogleFonts.poppins(color: app_colors.eduLearnPrimary, fontWeight: FontWeight.bold, fontSize: 11),
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
      },
    );
  }

  Widget _courseImageErrorPlaceholder() {
    return Container(
      height: 130, width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.school_outlined, color: Colors.grey, size: 50)),
    );
  }
}