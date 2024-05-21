import 'package:urven/data/models/base/api_result.dart';

class ChatRoom extends APIResponse {
  int? id;
  int? clubId;
  String? name;
  String? description;
  String? type;
  DateTime? createdAt;
  String? exception;

  ChatRoom.map(dynamic o) : super.map(o) {
    if (o != null) {
      id = o['id'];
      clubId = o['club_id'];
      name = o['name'];
      description = o['description'];
      type = o['type'];
      try {
        createdAt = DateTime.parse(o['created_at']);
      } catch (e) {
        createdAt = null;
      }
    }
  }

  ChatRoom.withError(String errorValue)
      : id = null,
        clubId = null,
        name = null,
        description = null,
        type = null,
        createdAt = null,
        exception = errorValue,
        super.map(null);

  bool get isValid =>
      id != null && name != null && description != null && type != null;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom.map(json);
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
}