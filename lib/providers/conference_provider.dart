import 'package:flutter/foundation.dart';
import '../models/abstract_model.dart';
import '../models/submission_models.dart';
import '../models/registration_model.dart';
import '../services/conference_service.dart';

class ConferenceProvider extends ChangeNotifier {
  final ConferenceService _service = ConferenceService();

  // ── State ──────────────────────────────────────────────────────────────

  bool _loading = false;
  String? _error;

  RegistrationModel? registration;
  List<AbstractModel> abstracts = [];
  List<PreConferenceModel> preconference = [];
  List<WorkshopModel> workshops = [];
  Map<String, dynamic>? certificates;
  Map<String, dynamic>? adminStats;
  Map<String, dynamic>? reviewerStats;
  List<Map<String, dynamic>> reviewerAssignedAbstracts = [];
  List<RegistrationModel> allRegistrations = [];
  List<AbstractModel> allAbstracts = [];
  List<PreConferenceModel> allPreconferences = [];
  List<WorkshopModel> allWorkshops = [];
  List<Map<String, dynamic>> allReviewers = [];
  List<Map<String, dynamic>> allConferenceRooms = [];
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> allGeneratedCerts = [];

  bool get loading => _loading;
  String? get error => _error;

  // ── PARTICIPANT ────────────────────────────────────────────────────────

  Future<void> loadMyRegistration() async {
    await _run(() async {
      registration = await _service.getMyRegistration();
    });
  }

  Future<void> loadMyAbstracts() async {
    await _run(() async {
      abstracts = await _service.getMyAbstracts();
    });
  }

  Future<bool> submitAbstract(Map<String, dynamic> data) async {
    return await _runBool(() => _service.submitAbstract(data));
  }

  Future<void> loadMyPreConf() async {
    await _run(() async {
      preconference = await _service.getMyPreConf();
    });
  }

  Future<bool> submitPreConference(Map<String, dynamic> data) async {
    return await _runBool(() => _service.submitPreConference(data));
  }

  Future<void> loadMyWorkshops() async {
    await _run(() async {
      workshops = await _service.getMyWorkshops();
    });
  }

  Future<bool> submitWorkshop(Map<String, dynamic> data) async {
    return await _runBool(() => _service.submitWorkshop(data));
  }

  Future<void> loadMyCertificates() async {
    await _run(() async {
      certificates = await _service.getMyCertificates();
    });
  }

  // ── ADMIN ──────────────────────────────────────────────────────────────

  Future<void> loadAdminDashboard() async {
    await _run(() async {
      adminStats = await _service.getAdminDashboard();
    });
  }

  Future<void> loadReviewerDashboard() async {
    await _run(() async {
      reviewerStats = await _service.getReviewerDashboard();
    });
  }

  Future<void> loadReviewerAbstracts() async {
    await _run(() async {
      reviewerAssignedAbstracts = await _service.getReviewerAbstracts();
    });
  }

  Future<void> loadAllRegistrations() async {
    await _run(() async {
      allRegistrations = await _service.adminGetRegistrations();
    });
  }

  Future<bool> activateParticipant(String regCode) async {
    return await _runBool(() => _service.activateParticipant(regCode));
  }

  Future<void> loadAllAbstracts() async {
    await _run(() async {
      allAbstracts = await _service.adminGetAbstracts();
    });
  }

  Future<bool> updateAbstractStatus(String id, String status,
      {String comment = ''}) async {
    return await _runBool(
        () => _service.updateAbstractStatus(id, status, comment: comment));
  }

  Future<void> loadAllPreconferences() async {
    await _run(() async {
      allPreconferences = await _service.adminGetPreconferences();
    });
  }

  Future<bool> updatePreconfStatus(String id, String status,
      {String comment = ''}) async {
    return await _runBool(
        () => _service.updatePreconfStatus(id, status, comment: comment));
  }

  Future<void> loadAllWorkshops() async {
    await _run(() async {
      allWorkshops = await _service.adminGetWorkshops();
    });
  }

  Future<bool> updateWorkshopStatus(String id, String status,
      {String comment = ''}) async {
    return await _runBool(
        () => _service.updateWorkshopStatus(id, status, comment: comment));
  }

  Future<void> loadMessages() async {
    await _run(() async {
      messages = await _service.adminGetMessages();
    });
  }

  Future<void> loadAllGeneratedCerts() async {
    await _run(() async {
      allGeneratedCerts = await _service.adminGetGeneratedCerts();
    });
  }

  Future<bool> generateCertificates(
      String certType, List<String> regCodes) async {
    return await _runBool(
        () => _service.adminGenerateCertificates(certType, regCodes));
  }

  Future<bool> revokeCertificate(String id) async {
    return await _runBool(() => _service.adminRevokeCertificate(id));
  }

  Future<void> loadAllReviewers() async {
    await _run(() async {
      allReviewers = await _service.adminGetReviewers();
    });
  }

  Future<bool> addReviewer(Map<String, dynamic> data) async {
    return await _runBool(() => _service.adminAddReviewer(data));
  }

  Future<void> loadAllConferenceRooms() async {
    await _run(() async {
      allConferenceRooms = await _service.adminGetConferenceRooms();
    });
  }

  Future<bool> addConferenceRoom(Map<String, dynamic> data) async {
    return await _runBool(() => _service.adminAddConferenceRoom(data));
  }

  Future<bool> updateConferenceRoom(String id, Map<String, dynamic> data) async {
    return await _runBool(() => _service.adminUpdateConferenceRoom(id, data));
  }

  Future<bool> deleteConferenceRoom(String id) async {
    return await _runBool(() => _service.adminDeleteConferenceRoom(id));
  }

  // ── Internal helpers ───────────────────────────────────────────────────

  Future<void> _run(Future<void> Function() fn) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await fn();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> _runBool(Future<Map<String, dynamic>> Function() fn) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await fn();
      _loading = false;
      notifyListeners();
      return res['status'] == true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
