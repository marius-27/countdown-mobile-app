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

  factory CountdownEvent.fromJson(Map<String, dynamic> json) {
    return CountdownEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      emoji: json['emoji'] as String?,
      colorValue: json['colorValue'] as int?,
      backgroundImagePath: json['backgroundImagePath'] as String?,
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
      notificationDaysBefore: json['notificationDaysBefore'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'emoji': emoji,
      'colorValue': colorValue,
      'backgroundImagePath': backgroundImagePath,
      'notificationEnabled': notificationEnabled,
      'notificationDaysBefore': notificationDaysBefore,
    };
  }

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
