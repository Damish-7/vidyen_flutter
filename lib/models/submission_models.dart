class PreConferenceModel {
  final String preconferenceId;
  final String participantId;
  final String subthemes;
  final String paperTitle;
  final String keyword;
  final String paperAbstract;
  final String typeOfPresentation;
  final String status;
  final String createdOn;

  PreConferenceModel({
    required this.preconferenceId,
    required this.participantId,
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
      participantId: json['participant_id']?.toString() ?? '',
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
        return 'Evaluated';
      case '1':
        return 'Under Review';
      default:
        return 'Submitted';
    }
  }
}

class WorkshopModel {
  final String workshopId;
  final String participantId;
  final String subthemes;
  final String paperTitle;
  final String keyword;
  final String paperAbstract;
  final String typeOfPresentation;
  final String status;
  final String createdOn;

  WorkshopModel({
    required this.workshopId,
    required this.participantId,
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
      participantId: json['participant_id']?.toString() ?? '',
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
        return 'Evaluated';
      case '1':
        return 'Under Review';
      default:
        return 'Submitted';
    }
  }
}
