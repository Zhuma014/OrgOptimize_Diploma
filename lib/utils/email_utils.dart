extension EmailUtils on String? {
  static final emailRegexp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  bool isEmail() {
    String? value = this;
    if (value == null) return false;
    return emailRegexp.hasMatch(value);
  }
}
