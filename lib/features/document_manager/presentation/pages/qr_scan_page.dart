import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class QrScanResult {
  final String rawValue;
  final String? url;

  const QrScanResult({required this.rawValue, this.url});
}

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;
  bool _isProcessingImage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _normalizeUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('www.')) {
      return 'https://$value';
    }
    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final raw = barcode.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    _hasScanned = true;
    _controller.stop();

    final url = _normalizeUrl(raw);
    Navigator.pop(context, QrScanResult(rawValue: raw, url: url));
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessingImage) return;

    setState(() => _isProcessingImage = true);

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() => _isProcessingImage = false);
        return;
      }

      // Pause live camera while analyzing the image
      await _controller.stop();

      final BarcodeCapture? result = await _controller.analyzeImage(image.path);

      if (!mounted) return;

      if (result == null || result.barcodes.isEmpty) {
        setState(() => _isProcessingImage = false);
        // Resume camera and show a snackbar
        await _controller.start();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).noQrFound),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final raw = result.barcodes.first.rawValue?.trim();
      if (raw == null || raw.isEmpty) {
        setState(() => _isProcessingImage = false);
        await _controller.start();
        return;
      }

      _hasScanned = true;
      final url = _normalizeUrl(raw);
      Navigator.pop(context, QrScanResult(rawValue: raw, url: url));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingImage = false);
      await _controller.start();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorPickingImage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                Center(
                  child: Container(
                    width: 240.w,
                    height: 240.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 32.r,
                ),
                Gap(8.h),
                Text(
                  l10n.scanQrHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
                Gap(16.h),
                OutlinedButton.icon(
                  onPressed: _isProcessingImage ? null : _pickFromGallery,
                  icon: _isProcessingImage
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(Icons.photo_library_rounded, size: 18.r),
                  label: Text(
                    _isProcessingImage
                        ? l10n.processing
                        : l10n.importFromGallery,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
