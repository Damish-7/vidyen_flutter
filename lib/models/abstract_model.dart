class AbstractModel {
  final String abstractId;
  final String registrationId;
  final String paperTitle;
  final String subTheme;
  final String typeOfPresentation;
  final String categoryPresentation;
  final String keywords;
  final String paperAbstract;
  final String status;
  final String createdOn;
  final String reviewerName;
  final List<AuthorModel> authors;

  AbstractModel({
    required this.abstractId,
    required this.registrationId,
    required this.paperTitle,
    required this.subTheme,
    required this.typeOfPresentation,
    required this.categoryPresentation,
    required this.keywords,
    required this.paperAbstract,
    required this.status,
    required this.createdOn,
    this.reviewerName = '',
    this.authors = const [],
  });

  factory AbstractModel.fromJson(Map<String, dynamic> json) {
    return AbstractModel(
      abstractId: json['abstract_id']?.toString() ?? '',
      registrationId: json['registration_id']?.toString() ?? '',
      paperTitle: json['paper_title']?.toString() ?? '',
      subTheme: json['sub_theme']?.toString() ?? '',
      typeOfPresentation: json['type_of_presentation']?.toString() ?? '',
      categoryPresentation: json['category_presentation']?.toString() ?? '',
      keywords: json['keywords']?.toString() ?? '',
      paperAbstract: json['paper_abstract']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      createdOn: json['created_on']?.toString() ?? '',
      reviewerName: json['reviewer_name']?.toString() ?? '',
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

class AuthorModel {
  final String prefix;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String authorType;
  final String designation;
  final String institution;
  final String city;
  final String state;
  final String country;
  final String pincode;

  AuthorModel({
    required this.prefix,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.authorType,
    required this.designation,
    required this.institution,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      prefix:
          json['prefix']?.toString() ?? json['author_type']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      middleName: json['middle_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email:
          json['author_email']?.toString() ?? json['email']?.toString() ?? '',
      authorType: json['author_type']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      institution:
          (json['author_institution'] ?? json['institution'])?.toString() ?? '',
      city: (json['author_city'] ?? json['city'])?.toString() ?? '',
      state: (json['author_state'] ?? json['state'])?.toString() ?? '',
      country: (json['author_country'] ?? json['country'])?.toString() ?? '',
      pincode: (json['author_pincode'] ?? json['pincode'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'prefix': prefix,
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'email': email,
        'author_type': authorType,
        'designation': designation,
        'institution': institution,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
      };

  String get fullName => '$prefix $firstName $middleName $lastName'.trim();
}
