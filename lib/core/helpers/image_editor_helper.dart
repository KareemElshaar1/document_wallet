import 'package:flutter/material.dart';

import '../widgets/crop_image_page.dart';

class ImageEditorHelper {
  ImageEditorHelper._();

  /// Opens a Flutter-based crop UI (no native UCrop activity — avoids Android crashes).
  /// Returns the cropped file path, or null if the user cancelled.
  static Future<String?> editImage({
    required String sourcePath,
    required BuildContext context,
  }) async {
    if (!context.mounted) return null;

    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CropImagePage(sourcePath: sourcePath),
      ),
    );
  }
}
