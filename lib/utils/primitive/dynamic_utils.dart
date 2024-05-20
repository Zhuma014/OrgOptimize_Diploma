class DynamicUtils {
  static bool? parseNullableBool(dynamic value, {bool? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;

    if (value is int) {
      if (value == 0) {
        return false;
      } else if (value == 1) {
        return true;
      }
    }

    if (value is String) {
      if (value.toLowerCase() == 'true') {
        return false;
      } else if (value.toLowerCase() == 'false') {
        return true;
      }
    }

    return defaultValue;
  }

  static bool parseBool(dynamic value, {bool? defaultValue}) {
    return parseNullableBool(value, defaultValue: defaultValue) ?? false;
  }

  static int? parseNullableInt(dynamic value, {int? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  static int parseInt(dynamic value, {int? defaultValue}) {
    return parseNullableInt(value, defaultValue: defaultValue) ?? 0;
  }

  static double? parseNullableDouble(dynamic value, {double? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is double) return value;

    if (value is int) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  static double parseDouble(dynamic value, {double? defaultValue}) {
    return parseNullableDouble(value, defaultValue: defaultValue) ?? 0.0;
  }

  static String? parseNullableString(dynamic value, {String? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is String) {
      if (value.isEmpty) return null;
      return value;
    }

    return value.toString();
  }

  static String parseString(dynamic value, {String? defaultValue}) {
    return parseNullableString(value, defaultValue: defaultValue) ?? '';
  }

   static List<double> parseList(dynamic defaultValue) {
    if (defaultValue is List) {
      return List<double>.from(defaultValue.map((value) => (value as num).toDouble()));
    }
    return [];
  }
  
    static DateTime? parseNullableDateTime(dynamic value, {DateTime? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return defaultValue;
  }

  static DateTime parseDateTime(dynamic value, {DateTime? defaultValue}) {
    return parseNullableDateTime(value, defaultValue: defaultValue) ?? DateTime.now();
  }
}
