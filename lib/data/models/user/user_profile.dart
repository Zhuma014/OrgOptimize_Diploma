import 'package:urven/data/models/base/api_result.dart';

class UserProfile extends APIResponse {
  int? id;
  String? fullName;
  String? email;
  String? birthDate;
  String? createdAt;
  bool? isAdmin;
  String? exception;

  UserProfile.map(dynamic o) : super.map(o) {
    if (o != null) {
      id = o['id'];
      fullName = o['full_name'];
      email = o['email'];
      birthDate = o['birth_date'];
      createdAt = o['created_at'];
      isAdmin = o['is_admin'];
    }
  }

  UserProfile.withError(String errorValue)
      : id = null,
        fullName = null,
        email = null,
        birthDate = null,
        createdAt = null,
        isAdmin = null,
        exception = errorValue,
        super.map(null);

  bool get isValid =>
      id != null &&
      fullName != null &&
      email != null &&
      birthDate != null &&
      createdAt != null &&
      isAdmin != null;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile.map(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'birth_date': birthDate,
      'created_at': createdAt,
      'is_admin': isAdmin,
    };
  }
}