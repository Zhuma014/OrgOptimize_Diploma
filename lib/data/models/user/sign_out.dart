
class SignOut {
  String? exception;

  SignOut({
    this.exception,
  });

  SignOut.fromJson(Map<String, dynamic> json) {
    exception = json['exception'];
    }
}
