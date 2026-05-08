import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl => kIsWeb
      ? 'http://localhost:8888/vidyen_flutter/api'      // Chrome testing
      : 'http://192.168.14.89:8888/vidyen_flutter/api'; // physical device

  // Auth
  static String get login => '$baseUrl/auth/login';
  static String get changePassword => '$baseUrl/auth/change-password';
  static String get me => '$baseUrl/auth/me';

  // Registration
  static String get register => '$baseUrl/registration';
  static String get myRegistration => '$baseUrl/registration/me';

  // Abstracts
  static String get createAbstract => '$baseUrl/abstracts';
  static String get myAbstracts => '$baseUrl/abstracts/my';
  static String abstractById(String id) => '$baseUrl/abstracts/$id';

  // Pre-conference
  static String get createPreconf => '$baseUrl/preconference';
  static String get myPreconf => '$baseUrl/preconference/my';
  static String preconfById(String id) => '$baseUrl/preconference/$id';

  // Workshop
  static String get createWorkshop => '$baseUrl/workshop';
  static String get myWorkshop => '$baseUrl/workshop/my';
  static String workshopById(String id) => '$baseUrl/workshop/$id';

  // Certificates
  static String get myCertificates => '$baseUrl/certificates/my';
  static String get certCoAuthors => '$baseUrl/certificates/co-authors';
  static String certDownload(String type, String regCode) =>
      '$baseUrl/certificates/$type/$regCode';

  // Admin
  static String get adminDashboard => '$baseUrl/admin/dashboard';
  static String get adminRegistrations => '$baseUrl/admin/registrations';
  static String adminActivate(String code) =>
      '$baseUrl/admin/registrations/$code/activate';
  static String get adminAbstracts => '$baseUrl/admin/abstracts';
  static String abstractStatus(String id) =>
      '$baseUrl/admin/abstracts/$id/status';
  static String abstractAssignReviewer(String id) =>
      '$baseUrl/admin/abstracts/$id/assign-reviewer';
  static String get adminPreconf => '$baseUrl/admin/preconference';
  static String preconfStatus(String id) =>
      '$baseUrl/admin/preconference/$id/status';
  static String preconfAssignReviewer(String id) =>
      '$baseUrl/admin/preconference/$id/assign-reviewer';
  static String get adminWorkshop => '$baseUrl/admin/workshop';
  static String workshopStatus(String id) =>
      '$baseUrl/admin/workshop/$id/status';
  static String workshopAssignReviewer(String id) =>
      '$baseUrl/admin/workshop/$id/assign-reviewer';
  static String get adminCerts => '$baseUrl/admin/certificates';
  static String get adminGenerateCerts =>
      '$baseUrl/admin/certificates/generate';
  static String adminRevokeCert(String id) => '$baseUrl/admin/certificates/$id';
  static String get adminCoAuthors => '$baseUrl/admin/co-authors';
  static String get adminUsers => '$baseUrl/admin/users';
  static String toggleUser(String id) =>
      '$baseUrl/admin/users/$id/toggle-status';
  static String get adminMessages => '$baseUrl/admin/messages';
  static String get adminReviewers => '$baseUrl/admin/reviewers';
  static String get reviewerDashboard => '$baseUrl/reviewer/dashboard';
  static String get reviewerAbstracts => '$baseUrl/reviewer/abstracts';
  static String reviewerById(String id) => '$baseUrl/admin/reviewers/$id';
  static String get adminConferenceRooms => '$baseUrl/admin/conference-rooms';
  static String conferenceRoomById(String id) =>
      '$baseUrl/admin/conference-rooms/$id';
}
