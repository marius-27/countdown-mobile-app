import 'package:flutter/material.dart';

class ReminderSettings extends StatelessWidget {
  const ReminderSettings({
    super.key,
    required this.enabled,
    required this.daysBefore,
    required this.timeLabel,
    required this.onEnabledChanged,
    required this.onDaysBeforeChanged,
    required this.onTimeTap,
  });

  static const List<int> daysBeforeOptions = [1, 2, 3, 7, 14, 30];
  static const int defaultDaysBefore = 1;
  static const TimeOfDay defaultTime = TimeOfDay(hour: 9, minute: 0);

  final bool enabled;
  final int daysBefore;
  final String timeLabel;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onDaysBeforeChanged;
  final VoidCallback onTimeTap;

  static String daysBeforeLabel(int days) =>
      days == 1 ? '1 day before' : '$days days before';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable notification'),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: daysBefore,
            decoration: const InputDecoration(labelText: 'When'),
            items: [
              for (final days in daysBeforeOptions)
                DropdownMenuItem(
                  value: days,
                  child: Text(daysBeforeLabel(days)),
                ),
            ],
            onChanged: (days) {
              if (days != null) onDaysBeforeChanged(days);
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onTimeTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Notification time',
                suffixIcon: Icon(Icons.schedule_outlined),
              ),
              child: Text(timeLabel),
            ),
          ),
        ],
      ],
    );
  }
}
