class Message {
  int? id;
  int? chatRoomId;
  int? userId;
  String? content;
  DateTime? timestamp;
  String? userName; // Add this line


  Message({
    this.id,
    this.chatRoomId,
    this.userId,
    this.content,
    this.timestamp,
    this.userName
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatRoomId = json['chat_room_id'];
    userId = json['user_id'];
    content = json['content'];
    try {
      timestamp = DateTime.parse(json['timestamp']);
    } catch (e) {
      timestamp = null;
    }
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          chatRoomId == other.chatRoomId &&
          userId == other.userId &&
          content == other.content &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      chatRoomId.hashCode ^
      userId.hashCode ^
      content.hashCode ^
      timestamp.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, chatRoomId: $chatRoomId, userId: $userId, content: $content, timestamp: $timestamp)';
  }
}
