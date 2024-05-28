
class UserProfile {
  int? id;
  String? fullName;
  String? email;
  String? birthDate;
  String? createdAt;
  bool? isAdmin;
  String? exception;

  UserProfile({
    this.id,
    this.fullName,
    this.email,
    this.birthDate,
    this.createdAt,
    this.isAdmin,
    this.exception,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    email = json['email'];
    birthDate = json['birth_date'];
    createdAt = json['created_at'];
    isAdmin = json['is_admin'];
    }

  bool get isValid =>
      id != null &&
      fullName != null &&
      email != null &&
      birthDate != null &&
      createdAt != null &&
      isAdmin != null;

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
