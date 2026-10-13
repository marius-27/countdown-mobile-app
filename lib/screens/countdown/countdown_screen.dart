import 'package:flutter/material.dart';

import '../../core/utils/countdown_calculator.dart';
import '../../core/utils/date_formatters.dart';
import '../../models/countdown_event.dart';
import '../../widgets/countdown_event_card.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key, required this.event});

  final CountdownEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final days = CountdownCalculator.remainingDuration(
      event.targetDate,
    ).inDays;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.emoji ?? CountdownEventCard.defaultEmoji,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                event.title.toUpperCase(),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                '$days',
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                days == 1 ? 'DAY' : 'DAYS',
                style: textTheme.titleMedium?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 32),
              Text(
                DateFormatters.longDate(event.targetDate),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
