extension DoubleExtensions on double? {
  double ifNull({double? defaultValue}) {
    double? value = this;
    if (value == null) return defaultValue ?? 0.0;
    return value;
  }
}
