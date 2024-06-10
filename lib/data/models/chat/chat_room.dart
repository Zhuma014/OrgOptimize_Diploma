class ChatRoom {
  int? id;
  int? clubId;
  String? name;
  String? description;
  String? type;
  List<int>? chosenMembers;
  String? lastMessage;
  String? messager;
  int? ownerId;
  DateTime? createdAt;
  String? exception;

  ChatRoom({
    this.id,
    this.clubId,
    this.name,
    this.description,
    this.type,
    this.chosenMembers,
    this.lastMessage,
    this.messager,
    this.ownerId,
    this.createdAt,
    this.exception,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      clubId: json['club_id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      exception: json['detail'],
      chosenMembers: json['chosen_members'] != null
          ? List<int>.from(json['chosen_members'])
          : null,
      lastMessage: json['last_message'],
      messager: json['messager'],
      ownerId: json['owner_id'],
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
      'chosen_members': chosenMembers,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ChatRoom.withError(String errorValue)
      : name = null,
        description = null,
        id = null,
        exception = errorValue;

  bool get isValid =>
      id != null &&
      name != null &&
      description != null &&
      type != null &&
      chosenMembers != null;
}
