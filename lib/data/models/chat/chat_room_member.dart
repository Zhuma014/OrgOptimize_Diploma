
class ChatRoomMember {
  int? id;
  String? fullName;
  String? email;
  DateTime? birthDate;
  DateTime? createdAt;
  bool? isAdmin;

  ChatRoomMember({
    this.id,
    this.fullName,
    this.email,
    this.birthDate,
    this.createdAt,
    this.isAdmin,
  });

  ChatRoomMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    email = json['email'];
    try {
      birthDate = DateTime.parse(json['birth_date']);
    } catch (e) {
      birthDate = null;
    }
    try {
      createdAt = DateTime.parse(json['created_at']);
    } catch (e) {
      createdAt = null;
    }
    isAdmin = json['is_admin'];
    }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'birth_date': birthDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'is_admin': isAdmin,
    };
  }

  bool get isValid => id != null && fullName != null && email != null;
}
