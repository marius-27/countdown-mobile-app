import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/countdown_event.dart';

class BackgroundImageService {
  BackgroundImageService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const String _folderName = 'backgrounds';

  final ImagePicker _picker;

  /// Lets the user pick a photo from the gallery and copies it into the app's
  /// documents folder, since the picker's own file can be cleaned up by the
  /// system. Returns the copied file's path, or null if nothing was picked.
  Future<String?> pickBackgroundImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory('${documents.path}/$_folderName');
    await folder.create(recursive: true);

    final extension = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    final fileName = '${DateTime.now().microsecondsSinceEpoch}$extension';
    final copy = await File(picked.path).copy('${folder.path}/$fileName');
    return copy.path;
  }

  /// Deletes copied images that none of [events] uses any more: ones that
  /// were replaced or removed, belonged to a deleted event, or were picked on
  /// a form that was then left without saving.
  ///
  /// Nothing waits on the result, so callers run it with `unawaited`.
  static Future<void> deleteUnusedImages(List<CountdownEvent> events) async {
    try {
      final documents = await getApplicationDocumentsDirectory();
      final folder = Directory('${documents.path}/$_folderName');
      if (!await folder.exists()) return;

      // Compared by file name: on iOS the documents folder's absolute path
      // can change after an app update.
      final used = {
        for (final event in events)
          if (event.backgroundImagePath case final path?) _fileName(path),
      };
      await for (final entity in folder.list()) {
        if (entity is File && !used.contains(_fileName(entity.path))) {
          await entity.delete();
        }
      }
    } on Exception {
      // Cleanup is best effort; a file left behind only takes up space.
    }
  }

  static String _fileName(String path) =>
      path.substring(path.lastIndexOf('/') + 1);
}
