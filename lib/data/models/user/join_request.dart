import 'package:urven/data/models/base/api_result.dart';

class JoinRequest extends APIResponse {
  int? id;
  int? userId;
  int? clubId;
  String? status;
  String? exception;
  

  JoinRequest.map(dynamic o) : super.map(o) {
    if (o != null) {
      id = o['id'];
      userId = o['user_id'];
      clubId = o['club_id'];
      status = o['status'];
    }
  }

  JoinRequest.withError(String errorValue)
      : id = null,
        userId = null,
        clubId = null,
        status = null,
        exception = errorValue,
        super.map(null);

  bool get isValid => id != null && userId != null && clubId != null && status != null;
}
