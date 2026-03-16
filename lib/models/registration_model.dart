class RegistrationModel {
  final String id;
  final String registrationCode;
  final String title;
  final String fullName;
  final String age;
  final String gender;
  final String typeOfDelegate;
  final String designation;
  final String institution;
  final String universityName;
  final String fullAddress;
  final String email;
  final String phone;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String status;
  final String createdOn;

  RegistrationModel({
    required this.id,
    required this.registrationCode,
    required this.title,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.typeOfDelegate,
    required this.designation,
    required this.institution,
    required this.universityName,
    required this.fullAddress,
    required this.email,
    required this.phone,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.status,
    required this.createdOn,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id']?.toString() ?? '',
      registrationCode: json['registration_code']?.toString() ?? '',
      title: json['title']?.toString() ?? json['honorofic']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      typeOfDelegate: json['type_of_delegate']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      institution: json['institution']?.toString() ?? json['college_name']?.toString() ?? '',
      universityName: json['university_name']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      createdOn: json['created_on']?.toString() ?? '',
    );
  }

  bool get isActive => status == '1';

  String get statusLabel => isActive ? 'Active' : 'Pending';
}
