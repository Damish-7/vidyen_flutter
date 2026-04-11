class PreConferenceModel {
  final String preconferenceId;
  final String registrationId;
  final String subthemes;
  final String paperTitle;
  final String keyword;
  final String paperAbstract;
  final String typeOfPresentation;
  final String status;
  final String createdOn;

  PreConferenceModel({
    required this.preconferenceId,
    required this.registrationId,
    required this.subthemes,
    required this.paperTitle,
    required this.keyword,
    required this.paperAbstract,
    required this.typeOfPresentation,
    required this.status,
    required this.createdOn,
  });

  factory PreConferenceModel.fromJson(Map<String, dynamic> json) {
    return PreConferenceModel(
      preconferenceId: json['preconference_id']?.toString() ?? '',
      registrationId: json['registration_id']?.toString() ?? '',
      subthemes: json['subthemes']?.toString() ?? '',
      paperTitle: json['paper_title']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
      paperAbstract: json['paper_abstract']?.toString() ?? '',
      typeOfPresentation: json['type_of_presentation']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      createdOn: json['created_on']?.toString() ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case '2':
        return 'Reviewed';
      case '1':
        return 'Assigned';
      default:
        return 'Not Assigned';
    }
  }
}

class WorkshopModel {
  final String workshopId;
  final String registrationId;
  final String subthemes;
  final String paperTitle;
  final String keyword;
  final String paperAbstract;
  final String typeOfPresentation;
  final String status;
  final String createdOn;

  WorkshopModel({
    required this.workshopId,
    required this.registrationId,
    required this.subthemes,
    required this.paperTitle,
    required this.keyword,
    required this.paperAbstract,
    required this.typeOfPresentation,
    required this.status,
    required this.createdOn,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> json) {
    return WorkshopModel(
      workshopId: json['workshop_id']?.toString() ?? '',
      registrationId: json['registration_id']?.toString() ?? '',
      subthemes: json['subthemes']?.toString() ?? '',
      paperTitle: json['paper_title']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
      paperAbstract: json['paper_abstract']?.toString() ?? '',
      typeOfPresentation: json['type_of_presentation']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      createdOn: json['created_on']?.toString() ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case '2':
        return 'Reviewed';
      case '1':
        return 'Assigned';
      default:
        return 'Not Assigned';
    }
  }
}
