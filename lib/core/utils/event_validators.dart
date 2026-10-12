abstract final class EventValidators {
  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title.';
    }
    return null;
  }

  /// [now] can be passed to make the check deterministic in tests.
  static String? targetDate(DateTime? value, {DateTime? now}) {
    if (value == null) return 'Please select a date.';
    if (!value.isAfter(now ?? DateTime.now())) {
      return 'Please select a future date.';
    }
    return null;
  }
}
