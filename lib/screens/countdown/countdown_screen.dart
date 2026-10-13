import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/utils/countdown_calculator.dart';
import '../../core/utils/date_formatters.dart';
import '../../models/countdown_event.dart';
import '../../widgets/countdown_event_card.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key, required this.event});

  final CountdownEvent event;

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _calculateRemaining();
    if (!_isCompleted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  bool get _isCompleted => _remaining == Duration.zero;

  Duration _calculateRemaining() =>
      CountdownCalculator.remainingDuration(widget.event.targetDate);

  void _tick() {
    setState(() => _remaining = _calculateRemaining());
    if (_isCompleted) _timer?.cancel();
  }

  void _openEdit() {
    Navigator.pushNamed(context, AppRoutes.editEvent, arguments: widget.event);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Formats the part of [duration] below one day as
  /// `03 HOURS : 42 MIN : 19 SEC`.
  static String _formatTimeOfDay(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours HOURS : $minutes MIN : $seconds SEC';
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final days = _remaining.inDays;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _openEdit,
          ),
        ],
      ),
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
              if (_isCompleted)
                Text(
                  'COUNTDOWN COMPLETED',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                )
              else ...[
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
                const SizedBox(height: 24),
                Text(
                  _formatTimeOfDay(_remaining),
                  style: textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
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
