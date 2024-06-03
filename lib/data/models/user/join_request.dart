
class JoinRequest {
  int? id;
  int? userId;
  int? clubId;
  String? status;
  String? exception;
  String? message; 

  JoinRequest({
    this.id,
    this.userId,
    this.clubId,
    this.status,
    this.exception,
    this.message,
  });

  JoinRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    clubId = json['club_id'];
    status = json['status'];
    message = json['message']; 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    if (userId != null) data['user_id'] = userId;
    if (clubId != null) data['club_id'] = clubId;
    if (status != null) data['status'] = status;
    if (message != null) data['message'] = message; 
    return data;
  }

  bool get isValid =>
      id != null && userId != null && clubId != null && status != null;
}
