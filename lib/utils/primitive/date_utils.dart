
extension DateTimeExtensions on DateTime? {
  DateTime ifNull({DateTime? defaultValue}) {
    DateTime? value = this;
    if (value == null) return defaultValue ?? DateTime.now();
    return value;
  }
  
}

