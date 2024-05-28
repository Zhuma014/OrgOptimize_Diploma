
class SignUp {
  int? userId;
  String? accessToken;
  String? tokenType;
  String? exception;

  SignUp({
    this.userId,
    this.accessToken,
    this.tokenType,
    this.exception,
  });

  SignUp.fromJson(Map<String, dynamic> json) {
    userId = json['new_user.id'];
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    }

  SignUp.withError(String errorValue)
      : userId = null,
        accessToken = null,
        tokenType = null,
        exception = errorValue;

  bool get isValid => userId != null && accessToken != null && tokenType != null;
}
