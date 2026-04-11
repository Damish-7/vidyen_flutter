import '../config/api_config.dart';
import '../models/abstract_model.dart';
import '../models/submission_models.dart';
import '../models/registration_model.dart';
import '../services/api_service.dart';

class ConferenceService {
  final ApiService _api = ApiService();

  // ── REGISTRATION ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return await _api.post(ApiConfig.register, data, auth: false);
  }

  Future<RegistrationModel> getMyRegistration() async {
    final res = await _api.get(ApiConfig.myRegistration);
    _assertSuccess(res);
    return RegistrationModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ── ABSTRACTS ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitAbstract(Map<String, dynamic> data) async {
    return await _api.post(ApiConfig.createAbstract, data);
  }

  Future<List<AbstractModel>> getMyAbstracts() async {
    final res = await _api.get(ApiConfig.myAbstracts);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => AbstractModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getAbstractFull(String id) async {
    final res = await _api.get(ApiConfig.abstractById(id));
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  // ── PRE-CONFERENCE ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitPreConference(
      Map<String, dynamic> data) async {
    return await _api.post(ApiConfig.createPreconf, data);
  }

  Future<List<PreConferenceModel>> getMyPreConf() async {
    final res = await _api.get(ApiConfig.myPreconf);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => PreConferenceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getPreConfFull(String id) async {
    final res = await _api.get(ApiConfig.preconfById(id));
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  // ── WORKSHOP ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitWorkshop(Map<String, dynamic> data) async {
    return await _api.post(ApiConfig.createWorkshop, data);
  }

  Future<List<WorkshopModel>> getMyWorkshops() async {
    final res = await _api.get(ApiConfig.myWorkshop);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => WorkshopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getWorkshopFull(String id) async {
    final res = await _api.get(ApiConfig.workshopById(id));
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  // ── CERTIFICATES ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMyCertificates() async {
    final res = await _api.get(ApiConfig.myCertificates);
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  Future<String> getCertDownloadUrl(String type, String regCode) async {
    final res = await _api.get(ApiConfig.certDownload(type, regCode));
    _assertSuccess(res);
    return (res['data'] as Map<String, dynamic>)['download_url'] as String;
  }

  // ── REVIEWER ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getReviewerDashboard() async {
    final res = await _api.get(ApiConfig.reviewerDashboard);
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getReviewerAbstracts() async {
    final res = await _api.get(ApiConfig.reviewerAbstracts);
    _assertSuccess(res);
    return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  // ── ADMIN ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await _api.get(ApiConfig.adminDashboard);
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  Future<List<RegistrationModel>> adminGetRegistrations() async {
    final res = await _api.get(ApiConfig.adminRegistrations);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => RegistrationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> activateParticipant(String regCode) async {
    final res = await _api.put(ApiConfig.adminActivate(regCode), {});
    _assertSuccess(res);
    return res;
  }

  Future<List<AbstractModel>> adminGetAbstracts() async {
    final res = await _api.get(ApiConfig.adminAbstracts);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => AbstractModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> updateAbstractStatus(String id, String status,
      {String comment = ''}) async {
    final res = await _api.put(ApiConfig.abstractStatus(id), {
      'status': status,
      'comment': comment,
    });
    _assertSuccess(res);
    return res;
  }

  Future<Map<String, dynamic>> adminAssignAbstractReviewer(
      String abstractId, String reviewerCode) async {
    final res = await _api.post(
        ApiConfig.abstractAssignReviewer(abstractId), {'reviewer_code': reviewerCode});
    _assertSuccess(res);
    return res;
  }

  Future<List<Map<String, dynamic>>> adminGetMessages() async {
    final res = await _api.get(ApiConfig.adminMessages);
    _assertSuccess(res);
    return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> adminGetGeneratedCerts() async {
    final res = await _api.get(ApiConfig.adminCerts);
    _assertSuccess(res);
    return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> adminGenerateCertificates(
      String certType, List<String> regCodes) async {
    final res = await _api.post(ApiConfig.adminGenerateCerts,
        {'certificate_type': certType, 'users': regCodes});
    _assertSuccess(res);
    return res;
  }

  Future<Map<String, dynamic>> adminRevokeCertificate(String id) async {
    final res = await _api.delete(ApiConfig.adminRevokeCert(id));
    _assertSuccess(res);
    return res;
  }

  Future<List<Map<String, dynamic>>> adminGetReviewers() async {
    final res = await _api.get(ApiConfig.adminReviewers);
    _assertSuccess(res);
    return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> adminGetReviewer(String id) async {
    final res = await _api.get(ApiConfig.reviewerById(id));
    _assertSuccess(res);
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> adminAddReviewer(
      Map<String, dynamic> data) async {
    final res = await _api.post(ApiConfig.adminReviewers, data);
    _assertSuccess(res);
    return res;
  }

  Future<List<Map<String, dynamic>>> adminGetConferenceRooms() async {
    final res = await _api.get(ApiConfig.adminConferenceRooms);
    _assertSuccess(res);
    return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> adminAddConferenceRoom(
      Map<String, dynamic> data) async {
    final res = await _api.post(ApiConfig.adminConferenceRooms, data);
    _assertSuccess(res);
    return res;
  }

  Future<Map<String, dynamic>> adminUpdateConferenceRoom(
      String id, Map<String, dynamic> data) async {
    final res = await _api.put(ApiConfig.conferenceRoomById(id), data);
    _assertSuccess(res);
    return res;
  }

  Future<Map<String, dynamic>> adminDeleteConferenceRoom(String id) async {
    final res = await _api.delete(ApiConfig.conferenceRoomById(id));
    _assertSuccess(res);
    return res;
  }

  Future<List<PreConferenceModel>> adminGetPreconferences() async {
    final res = await _api.get(ApiConfig.adminPreconf);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => PreConferenceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> updatePreconfStatus(String id, String status,
      {String comment = ''}) async {
    final res = await _api.put(ApiConfig.preconfStatus(id), {
      'status': status,
      'comment': comment,
    });
    _assertSuccess(res);
    return res;
  }

  Future<Map<String, dynamic>> adminAssignPreconfReviewer(
      String preconfId, String reviewerCode) async {
    final res = await _api.post(
        ApiConfig.preconfAssignReviewer(preconfId), {'reviewer_code': reviewerCode});
    _assertSuccess(res);
    return res;
  }

  Future<List<WorkshopModel>> adminGetWorkshops() async {
    final res = await _api.get(ApiConfig.adminWorkshop);
    _assertSuccess(res);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => WorkshopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> updateWorkshopStatus(String id, String status,
      {String comment = ''}) async {
    final res = await _api.put(ApiConfig.workshopStatus(id), {
      'status': status,
      'comment': comment,
    });
    _assertSuccess(res);
    return res;
  }

  Future<Map<String, dynamic>> adminAssignWorkshopReviewer(
      String workshopId, String reviewerCode) async {
    final res = await _api.post(
        ApiConfig.workshopAssignReviewer(workshopId), {'reviewer_code': reviewerCode});
    _assertSuccess(res);
    return res;
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _assertSuccess(Map<String, dynamic> res) {
    if (res['status'] != true) {
      throw Exception(res['message'] ?? 'Request failed');
    }
  }
}
