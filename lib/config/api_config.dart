class ApiConfig {
  // For Windows desktop: use localhost:8000
  // For phone: use your PC's IP:8000 (run: php -S 0.0.0.0:8000 router.php)
  static const String baseUrl =
      'http://192.168.14.24:8070/vidyen_flutter/api'; // nginx via MAMP

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String changePassword = '$baseUrl/auth/change-password';
  static const String me = '$baseUrl/auth/me';

  // Registration
  static const String register = '$baseUrl/registration';
  static const String myRegistration = '$baseUrl/registration/me';

  // Abstracts
  static const String createAbstract = '$baseUrl/abstracts';
  static const String myAbstracts = '$baseUrl/abstracts/my';
  static String abstractById(String id) => '$baseUrl/abstracts/$id';

  // Pre-conference
  static const String createPreconf = '$baseUrl/preconference';
  static const String myPreconf = '$baseUrl/preconference/my';
  static String preconfById(String id) => '$baseUrl/preconference/$id';

  // Workshop
  static const String createWorkshop = '$baseUrl/workshop';
  static const String myWorkshop = '$baseUrl/workshop/my';
  static String workshopById(String id) => '$baseUrl/workshop/$id';

  // Certificates
  static const String myCertificates = '$baseUrl/certificates/my';
  static String certDownload(String type, String regCode) =>
      '$baseUrl/certificates/$type/$regCode';

  // Admin
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminRegistrations = '$baseUrl/admin/registrations';
  static String adminActivate(String code) =>
      '$baseUrl/admin/registrations/$code/activate';
  static const String adminAbstracts = '$baseUrl/admin/abstracts';
  static String abstractStatus(String id) =>
      '$baseUrl/admin/abstracts/$id/status';
  static String abstractAssignReviewer(String id) =>
      '$baseUrl/admin/abstracts/$id/assign-reviewer';
  static const String adminPreconf = '$baseUrl/admin/preconference';
  static String preconfStatus(String id) =>
      '$baseUrl/admin/preconference/$id/status';
  static String preconfAssignReviewer(String id) =>
      '$baseUrl/admin/preconference/$id/assign-reviewer';
  static const String adminWorkshop = '$baseUrl/admin/workshop';
  static String workshopStatus(String id) =>
      '$baseUrl/admin/workshop/$id/status';
  static String workshopAssignReviewer(String id) =>
      '$baseUrl/admin/workshop/$id/assign-reviewer';
  static const String adminCerts = '$baseUrl/admin/certificates';
  static const String adminGenerateCerts = '$baseUrl/admin/certificates/generate';
  static String adminRevokeCert(String id) => '$baseUrl/admin/certificates/$id';
  static const String adminUsers = '$baseUrl/admin/users';
  static String toggleUser(String id) =>
      '$baseUrl/admin/users/$id/toggle-status';
  static const String adminMessages = '$baseUrl/admin/messages';
  static const String adminReviewers = '$baseUrl/admin/reviewers';
  static const String reviewerDashboard = '$baseUrl/reviewer/dashboard';
  static const String reviewerAbstracts = '$baseUrl/reviewer/abstracts';
  static String reviewerById(String id) => '$baseUrl/admin/reviewers/$id';
  static const String adminConferenceRooms = '$baseUrl/admin/conference-rooms';
  static String conferenceRoomById(String id) =>
      '$baseUrl/admin/conference-rooms/$id';
}
