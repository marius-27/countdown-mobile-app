import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _date;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 100),
    );
    if (picked == null) return;

    setState(() {
      _date = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  void _submit() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Countdown')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'My Birthday',
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
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
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _submit, child: const Text('CREATE')),
          ],
        ),
      ),
    );
  }
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _formatDate(DateTime date) =>
    '${_twoDigits(date.day)} / ${_twoDigits(date.month)} / ${date.year}';
