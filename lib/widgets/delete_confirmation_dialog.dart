import 'package:flutter/material.dart';

/// Asks the user to confirm deleting the event called [title].
///
/// Returns true only when Delete was pressed.
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  required String title,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete countdown?'),
      content: Text('Are you sure you want to delete "$title"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
