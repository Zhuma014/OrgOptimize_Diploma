extension PasswordUtils on String {
  bool isValidPassword() {
    return length >= 8 && contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
