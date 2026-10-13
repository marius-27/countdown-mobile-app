import 'package:flutter/material.dart';

import '../core/utils/countdown_calculator.dart';
import '../core/utils/date_formatters.dart';
import '../models/countdown_event.dart';

class CountdownEventCard extends StatelessWidget {
  const CountdownEventCard({super.key, required this.event, this.onTap});

  static const String defaultEmoji = '📅';

  final CountdownEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorValue = event.colorValue;
    final customColor = colorValue == null ? null : Color(colorValue);

    return Card(
      clipBehavior: Clip.antiAlias,
      // A light tint keeps the text readable for every palette color.
      color: customColor == null
          ? null
          : Color.alphaBlend(
              customColor.withValues(alpha: 0.12),
              Theme.of(context).colorScheme.surfaceContainerLow,
            ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: customColor == null
              ? null
              : BoxDecoration(
                  border: Border(
                    left: BorderSide(color: customColor, width: 6),
                  ),
                ),
          child: Row(
            children: [
              Text(
                event.emoji ?? defaultEmoji,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CountdownCalculator.remainingDaysLabel(event.targetDate),
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatters.shortDate(event.targetDate),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
