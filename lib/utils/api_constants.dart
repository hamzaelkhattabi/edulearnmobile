// lib/utils/api_constants.dart
class ApiConstants {
  // !! IMPORTANT !!
  // Pour Android Emulator sur la même machine que le serveur:
  static const String baseUrl = 'http://192.168.11.107:3000/api';
  // Pour iOS Simulator sur la même machine ou appareil physique connecté au même réseau:
  // static const String baseUrl = 'http://VOTRE_IP_LOCALE_MACHINE:3000/api';
  // Exemple: static const String baseUrl = 'http://192.168.1.100:3000/api';
  // Si vous testez sur un appareil réel et que le backend est sur localhost,
  // vous devez utiliser l'adresse IP de votre machine sur le réseau local.

  // --- Auth ---
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String getMeEndpoint = '/auth/me';
//-----
  // --- Categories ---
  static const String categoriesEndpoint = '/categories';

  // --- Courses ---
  static const String coursesEndpoint = '/courses';
  static String courseByIdEndpoint(int id) => '/courses/$id';
  static String lessonsForCourseEndpoint(int courseId) => '/courses/$courseId/lessons';
  static String enrollCourseEndpoint(int courseId) => '/courses/$courseId/enroll';
  // Note: Les détails de leçons individuelles (GET /lessons/:id)
  // peuvent être appelés par le service de cours ou un service de leçons.

  // --- Enrollments (Inscriptions) ---
  static const String myEnrollmentsEndpoint = '/enrollments/my-enrollments';
  static String enrollmentDetailsEndpoint(int enrollmentId) => '/enrollments/$enrollmentId';
  static String updateLessonProgressEndpoint(int enrollmentId, int lessonId) =>
      '/enrollments/$enrollmentId/lessons/$lessonId/progress';

  // --- Quizzes ---
  static String quizzesForCourseEndpoint(int courseId) => '/courses/$courseId/quizzes'; // Assumant cette route existe pour lister les quiz d'un cours
  static String quizByIdEndpoint(int id) => '/quizzes/$id'; // Pour obtenir les détails d'un quiz avec questions
  static String submitQuizAttemptEndpoint(int quizId) => '/quizzes/$quizId/attempts';
  // Endpoint pour obtenir les quiz disponibles/tentés par l'utilisateur:
  // Pourrait être /api/users/me/quizzes ou /api/quizzes (filtré par l'API)
  // On va supposer /api/quizzes (avec contexte utilisateur au backend) pour QuizListScreen pour l'instant.
  static const String userQuizzesEndpoint = '/quizzes';

  // --- Certificates ---
  static const String myCertificatesEndpoint = '/certificates/my-certificates';
  // Certificat spécifique: GET /api/certificates/:userCertificateId (pour UserCertificate)

  // --- Notifications ---
  // Ces routes devront être créées côté backend.
  static const String myNotificationsEndpoint = '/notifications/my'; // Pour les notifications de l'utilisateur courant
  // static String markNotificationReadEndpoint(String id) => '/notifications/$id/read';
  // static String markAllNotificationsReadEndpoint = '/notifications/mark-all-read';
}