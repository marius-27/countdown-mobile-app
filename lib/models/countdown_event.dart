class CountdownEvent {
  const CountdownEvent({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.createdAt,
    this.emoji,
    this.colorValue,
    this.backgroundImagePath,
    this.notificationEnabled = false,
    this.notificationDaysBefore,
  });

  final String id;
  final String title;
  final DateTime targetDate;

  final String? emoji;
  final int? colorValue;
  final String? backgroundImagePath;

  final bool notificationEnabled;
  final int? notificationDaysBefore;

  final DateTime createdAt;

  CountdownEvent copyWith({
    String? title,
    DateTime? targetDate,
    String? emoji,
    int? colorValue,
    String? backgroundImagePath,
    bool? notificationEnabled,
    int? notificationDaysBefore,
  }) {
    return CountdownEvent(
      id: id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationDaysBefore:
          notificationDaysBefore ?? this.notificationDaysBefore,
    );
  }
}
