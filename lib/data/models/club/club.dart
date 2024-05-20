import 'package:urven/data/models/base/api_result.dart';
class Club extends APIResponse {
  String? name;
  String? description;
  int? id;
  int? adminId;
  DateTime? createdAt;
  String? exception;

  Club.map(dynamic o) : super.map(o) {
    if (o != null) {
      name = o['name'];
      description = o['description'];
      id = o['id'];
      adminId = o['admin_id'];
      try {
        createdAt = DateTime.parse(o['created_at']);
      } catch (e) {
        createdAt = null;
      }
    }
  }

  Club.withError(String errorValue)
      : name = null,
        description = null,
        id = null,
        adminId = null,
        exception = errorValue,
        super.map(null);

  bool get isValid =>
      name != null && description != null && id != null && adminId != null;

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club.map(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'id': id,
      'admin_id': adminId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}