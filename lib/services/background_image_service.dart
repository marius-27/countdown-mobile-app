import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
}
