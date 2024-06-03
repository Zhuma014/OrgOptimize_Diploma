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
    exception = json['detail'];
  }


  bool get isValid =>
       accessToken != null ;
}
