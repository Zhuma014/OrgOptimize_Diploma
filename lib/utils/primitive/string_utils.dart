extension NullableStringExtensions on String? {
  int length() {
    String? value = this;
    return value == null ? 0 : value.length;
  }

  bool isNullOrBlank() {
    String? value = this;
    if (value == null) return true;
    return value.trim().isEmpty;
  }

  bool isNotNullOrBlank() {
    return !isNullOrBlank();
  }

  String? asNullIfBlank() {
    String? value = this;
    if (value == null) return null;
    if (value.trim().isEmpty) return null;
    return value;
  }

  bool isInt() {
    String? value = this;
    if (value == null) return false;
    if (value.isNullOrBlank()) return false;
    return int.tryParse(value) != null;
  }

  int? toInt() {
    String? value = this;
    if (value == null) return null;
    if (value.isNullOrBlank()) return null;
    return int.tryParse(value);
  }

  bool isDouble() {
    String? value = this;
    if (value == null) return false;
    if (value.isNullOrBlank()) return false;
    return double.tryParse(value) != null;
  }

  double? tryParseToDouble({double? defaultValue}) {
    String? value = this;
    if (value == null) return defaultValue;
    if (value.isNullOrBlank()) return defaultValue;
    return double.tryParse(value);
  }

  String? tryTrim({String? defaultValue}) {
    String? value = this;
    if (value == null) return defaultValue;
    return value.trim();
  }

  String? removeLast() {
    String? value = this;
    if (value == null) return null;
    if (value.isNotNullOrBlank()) return null;
    List<String> split = value.split('');
    split.removeLast();
    return split.join();
  }
}

extension StringExtensions on String {
  String removeLast() {
    List<String> split = this.split('');
    split.removeLast();
    return split.join();
  }
}
