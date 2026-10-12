import 'package:flutter/material.dart';

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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
