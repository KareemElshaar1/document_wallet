import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_colors.dart';

class CropImagePage extends StatefulWidget {
  final String sourcePath;

  const CropImagePage({super.key, required this.sourcePath});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final _cropController = CropController();
  late final Uint8List _imageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _imageBytes = File(widget.sourcePath).readAsBytesSync();
  }

  Future<void> _saveCrop(Uint8List bytes) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(bytes, flush: true);

      if (mounted) Navigator.pop(context, outPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save crop: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop & Rotate'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _cropController.crop(),
              child: Text(
                'Done',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: _imageBytes,
              controller: _cropController,
              withCircleUi: false,
              baseColor: Colors.black,
              maskColor: Colors.black.withAlpha(120),
              interactive: true,
              fixCropRect: false,
              onCropped: (result) {
                switch (result) {
                  case CropSuccess(:final croppedImage):
                    _saveCrop(croppedImage);
                  case CropFailure():
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not crop image')),
                      );
                    }
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              'Drag to reposition. Pinch to zoom. Tap Done when finished.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ),
          Gap(8.h),
        ],
      ),
    );
  }
}
