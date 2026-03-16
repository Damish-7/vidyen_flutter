class UserModel {
  final String userId;
  final String email;
  final String usertype;
  final String name;
  final String token;

  UserModel({
    required this.userId,
    required this.email,
    required this.usertype,
    required this.name,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      usertype: json['usertype']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      token: token,
    );
  }

  bool get isAdmin => usertype == 'admin';
  bool get isParticipant => usertype == 'participant';
  bool get isReviewer => usertype == 'reviewer';

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'usertype': usertype,
        'name': name,
        'token': token,
      };
}
