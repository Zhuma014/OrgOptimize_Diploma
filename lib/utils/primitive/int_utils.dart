extension IntExtensions on int? {
  int ifNull({int? defaultValue}) {
    int? value = this;
    if (value == null) return defaultValue ?? 0;
    return value;
  }
}
