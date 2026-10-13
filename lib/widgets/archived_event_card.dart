import 'package:flutter/material.dart';

import '../core/utils/countdown_calculator.dart';
import '../core/utils/date_formatters.dart';
import '../models/countdown_event.dart';
import 'countdown_event_card.dart';

class ArchivedEventCard extends StatelessWidget {
  const ArchivedEventCard({super.key, required this.event, this.onDelete});

  final CountdownEvent event;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              event.emoji ?? CountdownEventCard.defaultEmoji,
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
                    CountdownCalculator.timeAgoLabel(event.targetDate),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
