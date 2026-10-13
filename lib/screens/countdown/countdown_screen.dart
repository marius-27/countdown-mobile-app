import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/utils/countdown_calculator.dart';
import '../../core/utils/date_formatters.dart';
import '../../models/countdown_event.dart';
import '../../repositories/event_repository.dart';
import '../../services/background_image_service.dart';
import '../../services/home_widget_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/countdown_event_card.dart';
import '../../widgets/delete_confirmation_dialog.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({
    super.key,
    required this.event,
    required this.repository,
  });

  final CountdownEvent event;
  final EventRepository repository;

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late CountdownEvent _event;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _remaining = _calculateRemaining();
    if (!_isCompleted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  bool get _isCompleted => _remaining == Duration.zero;

  Duration _calculateRemaining() =>
      CountdownCalculator.remainingDuration(_event.targetDate);

  void _tick() {
    setState(() => _remaining = _calculateRemaining());
    if (_isCompleted) _timer?.cancel();
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.pushNamed<CountdownEvent>(
      context,
      AppRoutes.editEvent,
      arguments: _event,
    );
    if (updated == null || !mounted) return;

    setState(() {
      _event = updated;
      _startCountdown();
    });
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: _event.title,
    );
    if (!confirmed || !mounted) return;

    await NotificationService.instance.cancelEventReminder(_event.id);
    await widget.repository.deleteEvent(_event.id);
    final events = await widget.repository.getEvents();
    await HomeWidgetService.update(events);
    unawaited(BackgroundImageService.deleteUnusedImages(events));
    if (!mounted) return;

    Navigator.pop(context);
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
    final event = _event;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final days = _remaining.inDays;

    final backgroundPath = event.backgroundImagePath;
    // The file can be missing, e.g. after the app data was restored elsewhere.
    final background =
        backgroundPath != null && File(backgroundPath).existsSync()
        ? File(backgroundPath)
        : null;
    final hasBackground = background != null;

    // Over a photo the text is drawn white on a dark scrim to stay readable.
    final foreground = hasBackground ? Colors.white : null;
    final accent = hasBackground ? Colors.white : colorScheme.primary;
    final secondary = hasBackground
        ? Colors.white70
        : colorScheme.onSurfaceVariant;

    final content = Center(
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
                color: foreground,
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
                  color: accent,
                ),
                textAlign: TextAlign.center,
              )
            else ...[
              Text(
                '$days',
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              Text(
                days == 1 ? 'DAY' : 'DAYS',
                style: textTheme.titleMedium?.copyWith(
                  letterSpacing: 2,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _formatTimeOfDay(_remaining),
                style: textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: foreground,
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text(
              DateFormatters.longDate(event.targetDate),
              style: textTheme.bodyLarge?.copyWith(color: secondary),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: hasBackground,
      appBar: AppBar(
        backgroundColor: hasBackground ? Colors.transparent : null,
        foregroundColor: foreground,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: background != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(background, fit: BoxFit.cover),
                const ColoredBox(color: Color(0x73000000)),
                SafeArea(child: content),
              ],
            )
          : content,
    );
  }
}
