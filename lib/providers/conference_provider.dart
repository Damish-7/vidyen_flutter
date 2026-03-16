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
  List<RegistrationModel> allRegistrations = [];
  List<AbstractModel> allAbstracts = [];
  List<Map<String, dynamic>> messages = [];

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

  Future<void> loadMessages() async {
    await _run(() async {
      messages = await _service.adminGetMessages();
    });
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
