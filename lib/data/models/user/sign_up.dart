import 'package:urven/data/models/base/api_result.dart';

class SignUp extends APIResponse {
  int? userId;
  String? accessToken;
  String? tokenType;
  String? exception;

  SignUp.map(dynamic o) : super.map(o) {
    if (o != null) {
      userId = o['new_user.id'];
      accessToken = o['access_token'];
      tokenType = o['token_type'];
    }
  }

  SignUp.withError(String errorValue)
      : userId = null,
        accessToken = null,
        tokenType = null,
        exception = errorValue,
        super.map(null);

  bool get isValid => accessToken != null;
}
