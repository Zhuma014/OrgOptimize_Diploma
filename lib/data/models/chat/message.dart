import 'package:urven/data/models/base/api_result.dart';

class Message extends APIResponse {
  int? id;
  int? chatRoomId;
  int? userId;
  String? content;
  DateTime? timestamp;
  String? exception;

  Message.map(dynamic o) : super.map(o) {
    if (o != null) {
      id = o['id'];
      chatRoomId = o['chat_room_id'];
      userId = o['user_id'];
      content = o['content'];
      try {
        timestamp = DateTime.parse(o['timestamp']);
      } catch (e) {
        timestamp = null;
      }
    }
  }

  Message.withError(String errorValue)
      : id = null,
        chatRoomId = null,
        userId = null,
        content = null,
        timestamp = null,
        exception = errorValue,
        super.map(null);

  bool get isValid =>
      id != null && chatRoomId != null && userId != null && content != null;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message.map(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}