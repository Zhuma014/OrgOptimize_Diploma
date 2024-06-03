
class SignIn {
  String? accessToken;
  String? tokenType;
  String? exception;

  SignIn({
    this.accessToken,
    this.tokenType,
    this.exception,
  });

  SignIn.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    exception = json['detail']; 
  }

  bool get isValid => accessToken != null;
}
