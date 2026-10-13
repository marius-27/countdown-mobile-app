import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/utils/event_validators.dart';
import '../../models/countdown_event.dart';
import '../../repositories/event_repository.dart';
import '../../services/background_image_service.dart';
import '../../services/home_widget_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/color_selector.dart';
import '../../widgets/emoji_selector.dart';
import '../../widgets/reminder_settings.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key, required this.repository, this.event});

  final EventRepository repository;

  /// The event being edited, or null when creating a new one.
  final CountdownEvent? event;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _backgroundImageService = BackgroundImageService();

  DateTime? _date;
  TimeOfDay _time = const TimeOfDay(hour: 12, minute: 0);
  String? _emoji;
  int? _colorValue;
  String? _backgroundImagePath;
  bool _notificationEnabled = false;
  int _notificationDaysBefore = ReminderSettings.defaultDaysBefore;
  TimeOfDay _notificationTime = ReminderSettings.defaultTime;
  bool _isSaving = false;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();

    final event = widget.event;
    if (event != null) {
      final target = event.targetDate;
      _titleController.text = event.title;
      _date = DateTime(target.year, target.month, target.day);
      _dateController.text = _formatDate(target);
      _time = TimeOfDay.fromDateTime(target);
      _emoji = event.emoji;
      _colorValue = event.colorValue;
      _backgroundImagePath = event.backgroundImagePath;
      _notificationEnabled = event.notificationEnabled;
      _notificationDaysBefore =
          event.notificationDaysBefore ?? _notificationDaysBefore;
      final minutes = event.notificationTimeMinutes;
      if (minutes != null) {
        _notificationTime = TimeOfDay(
          hour: minutes ~/ 60,
          minute: minutes % 60,
        );
      }
    }
    _timeController.text = _formatTime(_time);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = _date ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      // An edited event can already be in the past.
      firstDate: initialDate.isBefore(today) ? initialDate : today,
      lastDate: DateTime(now.year + 100),
    );
    if (picked == null) return;

    setState(() {
      _date = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;

    setState(() {
      _time = picked;
      _timeController.text = _formatTime(picked);
    });
  }

  Future<void> _pickBackgroundImage() async {
    final path = await _backgroundImageService.pickBackgroundImage();
    if (path == null || !mounted) return;

    setState(() => _backgroundImagePath = path);
  }

  Future<void> _setNotificationEnabled(bool enabled) async {
    if (enabled) {
      final allowed = await NotificationService.instance.requestPermission();
      if (!mounted) return;
      if (!allowed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allow notifications in settings to get reminders.'),
          ),
        );
        return;
      }
    }

    setState(() => _notificationEnabled = enabled);
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked == null) return;

    setState(() => _notificationTime = picked);
  }

  DateTime? get _targetDate {
    final date = _date;
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day, _time.hour, _time.minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final targetDate = _targetDate!;
    final existing = widget.event;

    // Editing keeps the id, so the repository replaces the stored event.
    // The event is rebuilt rather than copied so a cleared emoji or color is
    // stored as null instead of falling back to the previous value.
    final event = CountdownEvent(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      targetDate: targetDate,
      createdAt: existing?.createdAt ?? DateTime.now(),
      emoji: _emoji,
      colorValue: _colorValue,
      backgroundImagePath: _backgroundImagePath,
      notificationEnabled: _notificationEnabled,
      notificationDaysBefore: _notificationDaysBefore,
      notificationTimeMinutes:
          _notificationTime.hour * 60 + _notificationTime.minute,
    );

    setState(() => _isSaving = true);
    await widget.repository.saveEvent(event);
    // An edit can change the date or turn the reminder off, so the old
    // reminder is dropped before scheduling the current one.
    final notifications = NotificationService.instance;
    if (existing != null) await notifications.cancelEventReminder(event.id);
    await notifications.scheduleEventReminder(event);
    await HomeWidgetService.update(await widget.repository.getEvents());
    if (!mounted) return;

    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Countdown' : 'New Countdown'),
      ),
      body: Form(
        key: _formKey,
        // A Column keeps every field built while scrolled out of view; a
        // lazy ListView disposes them, and the Form then skips validating
        // them, letting an event without a date through.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'My Birthday',
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                validator: EventValidators.title,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'DD / MM / YYYY',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (_) => EventValidators.targetDate(_targetDate),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.schedule_outlined),
                ),
                readOnly: true,
                onTap: _pickTime,
              ),
              const SizedBox(height: 32),
              Text('Customize event', style: textTheme.titleMedium),
              const SizedBox(height: 16),
              Text('Emoji', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              EmojiSelector(
                selected: _emoji,
                onSelected: (emoji) => setState(() => _emoji = emoji),
              ),
              const SizedBox(height: 16),
              Text('Color', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              ColorSelector(
                selected: _colorValue,
                onSelected: (value) => setState(() => _colorValue = value),
              ),
              const SizedBox(height: 16),
              Text('Background', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              if (_backgroundImagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_backgroundImagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 140,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickBackgroundImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      _backgroundImagePath == null
                          ? 'Choose image'
                          : 'Change image',
                    ),
                  ),
                  if (_backgroundImagePath != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          setState(() => _backgroundImagePath = null),
                      child: const Text('Remove'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              Text('Remind me', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              ReminderSettings(
                enabled: _notificationEnabled,
                daysBefore: _notificationDaysBefore,
                timeLabel: _formatTime(_notificationTime),
                onEnabledChanged: _setNotificationEnabled,
                onDaysBeforeChanged: (days) =>
                    setState(() => _notificationDaysBefore = days),
                onTimeTap: _pickNotificationTime,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: Text(_isEditing ? 'SAVE' : 'CREATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _formatDate(DateTime date) =>
    '${_twoDigits(date.day)} / ${_twoDigits(date.month)} / ${date.year}';

String _formatTime(TimeOfDay time) =>
    '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
