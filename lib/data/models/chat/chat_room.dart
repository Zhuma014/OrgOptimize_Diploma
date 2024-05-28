
class ChatRoom {
  int? id;
  int? clubId;
  String? name;
  String? description;
  String? type;
  DateTime? createdAt;

  ChatRoom({
    this.id,
    this.clubId,
    this.name,
    this.description,
    this.type,
    this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      clubId: json['club_id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'name': name,
      'description': description,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isValid =>
      id != null && name != null && description != null && type != null;
}
