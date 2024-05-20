import 'package:urven/data/models/base/api_result.dart';

class SignIn extends APIResponse {
  String? accessToken;
  String? tokenType;
  String? exception;


  SignIn.map(dynamic o) : super.map(o) {
    if (o != null) {
      accessToken = o['access_token'];
      tokenType = o['token_type'];

    }
  }

  SignIn.withError(String errorValue)
      : accessToken = null,
        tokenType = null,
        exception = errorValue,
        super.map(null);

  bool get isValid => accessToken != null;
}
