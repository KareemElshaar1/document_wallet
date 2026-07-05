import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'image_editor_helper.dart';

class ImportedMedia {
  final File file;
  final String fileName;
  final int fileSize;
  final String fileType;

  const ImportedMedia({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });
}

class MediaImportHelper {
  MediaImportHelper._();

  static final ImagePicker _picker = ImagePicker();
  static bool _cropInProgress = false;

  static Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> _ensureGalleryPermission() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    final photos = await Permission.photos.request();
    return photos.isGranted;
  }

  static Future<File?> _editOrUseOriginal(
    BuildContext context,
    String sourcePath,
  ) async {
    if (_cropInProgress) return File(sourcePath);
    _cropInProgress = true;

    try {
      if (!context.mounted) return File(sourcePath);

      final croppedPath = await ImageEditorHelper.editImage(
        sourcePath: sourcePath,
        context: context,
      );

      if (croppedPath != null && await File(croppedPath).exists()) {
        return File(croppedPath);
      }
    } catch (_) {
      // Fall back to original on any error.
    } finally {
      _cropInProgress = false;
    }

    return File(sourcePath);
  }

  static Future<ImportedMedia?> importFromCamera(BuildContext context) async {
    try {
      if (!await _ensureCameraPermission()) return null;

      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (image == null || !context.mounted) return null;

      final file = await _editOrUseOriginal(context, image.path);
      if (file == null || !await file.exists()) return null;

      final size = await file.length();
      final ext = file.path.split('.').last.toLowerCase();

      return ImportedMedia(
        file: file,
        fileName: 'Photo_${DateTime.now().millisecondsSinceEpoch}.$ext',
        fileSize: size,
        fileType: ext == 'jpeg' ? 'jpg' : ext,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
      return null;
    }
  }

  static Future<ImportedMedia?> importFromGallery(BuildContext context) async {
    try {
      await _ensureGalleryPermission();

      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image == null || !context.mounted) return null;

      final file = await _editOrUseOriginal(context, image.path);
      if (file == null || !await file.exists()) return null;

      final size = await file.length();
      final ext = file.path.split('.').last.toLowerCase();

      return ImportedMedia(
        file: file,
        fileName: 'Gallery_${DateTime.now().millisecondsSinceEpoch}.$ext',
        fileSize: size,
        fileType: ext == 'jpeg' ? 'jpg' : ext,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e')),
        );
      }
      return null;
    }
  }

  static Future<ImportedMedia?> importFromFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'txt'],
        withData: false,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final picked = result.files.single;
      final path = picked.path;
      if (path == null) return null;

      final file = File(path);
      if (!await file.exists()) return null;

      final size = await file.length();
      final ext = path.split('.').last.toLowerCase();

      return ImportedMedia(
        file: file,
        fileName: picked.name,
        fileSize: size,
        fileType: ext == 'jpeg' ? 'jpg' : ext,
      );
    } catch (e) {
      return null;
    }
  }
}
