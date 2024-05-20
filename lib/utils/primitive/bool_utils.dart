extension BoolExtensions on bool? {
  bool ifNull({bool? defaultValue}) {
    bool? value = this;
    if (value == null) return defaultValue ?? false;
    return value;
  }
}
