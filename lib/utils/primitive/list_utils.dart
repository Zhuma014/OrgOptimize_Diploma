extension ListExtensions<T> on List<T>? {
  bool isNullOrEmpty() {
    List<T>? value = this;
    if (value == null) return true;
    return value.isEmpty;
  }

  bool isNotNullOrEmpty() => !isNullOrEmpty();
}
