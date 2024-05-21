import 'package:urven/data/models/base/api_result.dart';

class ChatRoomMember extends APIResponse {
  int? chatRoomId;
  int? userId;
  String? role;
  DateTime? joinedAt;
  String? exception;

  ChatRoomMember.map(dynamic o) : super.map(o) {
    if (o != null) {
      chatRoomId = o['chat_room_id'];
      userId = o['user_id'];
      role = o['role'];
      try {
        joinedAt = DateTime.parse(o['joined_at']);
      } catch (e) {
        joinedAt = null;
      }
    }
  }

  ChatRoomMember.withError(String errorValue)
      : chatRoomId = null,
        userId = null,
        role = null,
        joinedAt = null,
        exception = errorValue,
        super.map(null);

  bool get isValid => chatRoomId != null && userId != null && role != null;

  factory ChatRoomMember.fromJson(Map<String, dynamic> json) {
    return ChatRoomMember.map(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }
}