class Attendance {
  final int userId;
  final int eventId;
  final String fullName;

  Attendance({
    required this.userId,
    required this.eventId,
    required this.fullName,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      userId: json['user_id'],
      eventId: json['event_id'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'event_id': eventId,
      'full_name': fullName,
    };
  }
}
