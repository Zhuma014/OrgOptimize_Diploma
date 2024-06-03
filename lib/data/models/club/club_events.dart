import 'package:intl/intl.dart';
import 'package:urven/utils/primitive/date_utils.dart';
import 'package:urven/utils/primitive/string_utils.dart';
import 'package:urven/utils/primitive/dynamic_utils.dart';

class Event {
  final int? id;
  final String? title;
  final String? description;
  final DateTime? date;
  final String? location;
  final dynamic userId;
  final dynamic clubId;
  String? clubName; 

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.userId,
    required this.clubId,
    this.clubName,
  });

  Event.map(dynamic o)
      : id = o['id'],
        title = DynamicUtils.parseNullableString(o['title']).tryTrim(),
        description =
            DynamicUtils.parseNullableString(o['description']).tryTrim(),
        date = DynamicUtils.parseDateTime(o['event_date']).ifNull(),
        location = DynamicUtils.parseNullableString(o['location']).tryTrim(),
        userId = o['user_id'],
        clubId = o['club_id'];

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: DynamicUtils.parseNullableString(json['title']).tryTrim(),
      description: DynamicUtils.parseNullableString(json['description']).tryTrim(),
      date: DateTime.parse(json['event_date']),  
      location: DynamicUtils.parseNullableString(json['location']).tryTrim(),
      userId: json['user_id'],
      clubId: json['club_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': date,
      'location': location,
      'user_id': userId,
      'club_id': clubId,
    };
  }

  String getFormattedEvent() {
    String formattedEvent = 'Event: ';
    if (title != null && title!.isNotEmpty) {
      formattedEvent += '$title';
      if (description != null && description!.isNotEmpty) {
        formattedEvent += ', Content: $description';
      }
      if (date != null) {
        formattedEvent +=
            ', Date: ${DateFormat('dd MMM yyyy HH:mm').format(date!)}';
      }
      if (location != null && location!.isNotEmpty) {
        formattedEvent += ', Location: $location';
      }
      if (userId != null) {
        formattedEvent += ', User ID: $userId';
      }
      if (clubId != null) {
        formattedEvent += ', Club ID: $clubId';
      }
    }
    return formattedEvent;
  }
}
