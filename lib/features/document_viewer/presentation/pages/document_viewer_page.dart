import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/pin_auth_dialog.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../../../document_manager/data/models/document_model.dart';
import '../../../document_manager/presentation/cubit/document_cubit.dart';

class DocumentViewerPage extends StatefulWidget {
  final DocumentModel document;

  const DocumentViewerPage({super.key, required this.document});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  late DocumentModel _doc;
  bool _isAuthenticated = false;
  bool _isAuthorizing = false;
  int _rotationQuarterTurns = 0; // 0, 1, 2, 3 (each representing 90 deg)
  String _textContent = '';
  double _textFontSize = 14.0;

  late String _currentFilePath;
  late String _currentFileType;

  @override
  void initState() {
    super.initState();
    _doc = widget.document;
    _currentFilePath = _doc.filePath;
    _currentFileType = _doc.fileType;

    // Check if the document requires authentication
    if (_doc.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _triggerAuthenticationGate();
        }
      });
    } else {
      _isAuthenticated = true;
      _loadContent();
    }
  }

  Future<void> _triggerAuthenticationGate() async {
    setState(() {
      _isAuthorizing = true;
    });

    final success = await showPinAuthDialog(context);

    if (!mounted) return;

    if (success) {
      setState(() {
        _isAuthenticated = true;
        _isAuthorizing = false;
      });
      _loadContent();
    } else {
      setState(() => _isAuthorizing = false);
      Navigator.pop(context);
    }
  }

  Future<void> _loadContent() async {
    if (_currentFileType == 'txt') {
      try {
        final file = File(_currentFilePath);
        if (await file.exists()) {
          final text = await file.readAsString();
          if (!mounted) return;
          setState(() {
            _textContent = text;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _textContent = 'Failed to load text file: ${e.toString()}';
        });
      }
    }
  }

  // --- ACTIONS ---
  Future<void> _shareDocument() async {
    await Share.shareXFiles([XFile(_currentFilePath)], text: _doc.title);
  }

  Future<void> _printDocument() async {
    try {
      final file = File(_currentFilePath);
      final bytes = await file.readAsBytes();

      if (_currentFileType == 'pdf') {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
          name: _doc.title,
        );
      } else {
        // Image printing
        final pdf = pw.Document();
        final pwImage = pw.MemoryImage(bytes);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(pwImage));
            },
          ),
        );
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: _doc.title,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print: ${e.toString()}')),
      );
    }
  }

  void _toggleFavorite() {
    context.read<DocumentCubit>().toggleFavoriteDocument(_doc.id);
    setState(() {
      _doc = _doc.copyWith(isFavorite: !_doc.isFavorite);
    });
  }

  void _toggleLock() {
    final newLockStatus = !_doc.isLocked;
    context.read<DocumentCubit>().toggleLockDocument(_doc.id, newLockStatus);
    setState(() {
      _doc = _doc.copyWith(isLocked: newLockStatus);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newLockStatus ? 'Document locked with PIN' : 'Document unlocked',
        ),
      ),
    );
  }

  void _renameDocument() {
    final controller = TextEditingController(text: _doc.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Document'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  final updated = _doc.copyWith(title: newName);
                  context.read<DocumentCubit>().updateDocumentDetails(updated);
                  setState(() {
                    _doc = updated;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDocument() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to permanently delete "${_doc.title}"? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<DocumentCubit>().deleteDocument(_doc.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(this.context); // Exit viewer
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _rotateImage() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  void _showDocumentInfo() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String? folderName;
    if (_doc.folderId != null) {
      final folders = context.read<DocumentCubit>().state.folders;
      final match = folders.where((f) => f.id == _doc.folderId);
      if (match.isNotEmpty) {
        folderName = match.first.name;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return GlassmorphicContainer(
          borderRadius: 24.r,
          borderWidth: 1.5,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          margin: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.black26,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _doc.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _doc.fileType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              const Divider(),
              Gap(12.h),

              // Category
              _buildInfoRow(
                context,
                Icons.category_rounded,
                l10n.category,
                _doc.categoryName,
              ),

              // Folder (if any)
              if (folderName != null) ...[
                Gap(12.h),
                _buildInfoRow(
                  context,
                  Icons.folder_rounded,
                  l10n.folder,
                  folderName,
                ),
              ],

              // Description (if any)
              if (_doc.description.isNotEmpty) ...[
                Gap(12.h),
                _buildInfoRow(
                  context,
                  Icons.description_rounded,
                  l10n.description,
                  _doc.description,
                ),
              ],

              // Expiration Date (if any)
              if (_doc.expirationDate != null) ...[
                Gap(12.h),
                _buildInfoRow(
                  context,
                  Icons.event_busy_rounded,
                  l10n.expirationDate,
                  DateFormat('yyyy-MM-dd').format(_doc.expirationDate!),
                  valueColor: AppColors.error,
                ),
              ],

              // File Size
              Gap(12.h),
              _buildInfoRow(
                context,
                Icons.data_usage_rounded,
                'File Size',
                '${(_doc.fileSize / 1024).toStringAsFixed(1)} KB',
              ),

              // Created Date
              Gap(12.h),
              _buildInfoRow(
                context,
                Icons.calendar_today_rounded,
                'Created',
                DateFormat('yyyy-MM-dd HH:mm').format(_doc.createdAt),
              ),

              // Tags (if any)
              if (_doc.tags.isNotEmpty) ...[
                Gap(16.h),
                Text(
                  l10n.tags,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Gap(8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _doc.tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.cardDark : AppColors.cardLight)
                                .withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight)
                                  .withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              Gap(24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.r,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Gap(2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      valueColor ??
                      (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelector(List<DocumentFile> allFiles) {
    if (allFiles.length <= 1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                .withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: allFiles.length,
        itemBuilder: (context, index) {
          final file = allFiles[index];
          final isSelected = file.filePath == _currentFilePath;

          IconData iconData = Icons.insert_drive_file_rounded;
          if (file.fileType == 'pdf')
            iconData = Icons.picture_as_pdf_rounded;
          else if (['jpg', 'jpeg', 'png', 'webp'].contains(file.fileType))
            iconData = Icons.image_rounded;
          else if (file.fileType == 'txt')
            iconData = Icons.description_rounded;

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: ChoiceChip(
              avatar: Icon(
                iconData,
                size: 16.r,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              label: Text(
                'File ${index + 1} (${file.fileType.toUpperCase()})',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark
                  ? AppColors.cardDark
                  : AppColors.cardLight,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentFilePath = file.filePath;
                    _currentFileType = file.fileType;
                    _rotationQuarterTurns = 0; // reset rotation
                  });
                  _loadContent();
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: _isAuthorizing
              ? const CircularProgressIndicator()
              : const Text('Authentication Required'),
        ),
      );
    }

    final allFiles = [
      DocumentFile(
        filePath: _doc.filePath,
        fileSize: _doc.fileSize,
        fileType: _doc.fileType,
      ),
      ..._doc.additionalFiles,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_doc.title),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _doc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _doc.isFavorite ? Colors.amber : null,
            ),
          ),
          IconButton(
            onPressed: _toggleLock,
            icon: Icon(
              _doc.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: _doc.isLocked ? AppColors.warning : null,
            ),
          ),
          IconButton(
            onPressed: _showDocumentInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'rename') _renameDocument();
              if (val == 'delete') _deleteDocument();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFileSelector(allFiles),
          Expanded(child: _buildViewerContent()),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildViewerContent() {
    final file = File(_currentFilePath);
    if (!file.existsSync()) {
      return const Center(child: Text('Error: Local file not found.'));
    }

    if (_currentFileType == 'pdf') {
      return SfPdfViewer.file(
        file,
        key: ValueKey(_currentFilePath),
        canShowScrollHead: true,
        canShowScrollStatus: true,
      );
    } else if (_currentFileType == 'txt') {
      return SingleChildScrollView(
        key: ValueKey(_currentFilePath),
        padding: EdgeInsets.all(20.r),
        child: SelectableText(
          _textContent,
          style: TextStyle(fontSize: _textFontSize),
        ),
      );
    } else if (['jpg', 'png', 'webp'].contains(_currentFileType)) {
      final targetImageWidth =
          (MediaQuery.sizeOf(context).width *
                  MediaQuery.devicePixelRatioOf(context))
              .round();
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: InteractiveViewer(
          key: ValueKey(_currentFilePath),
          maxScale: 4.0,
          child: RotatedBox(
            quarterTurns: _rotationQuarterTurns,
            child: Image.file(file, cacheWidth: targetImageWidth),
          ),
        ),
      );
    }

    return const Center(child: Text('Unsupported file format.'));
  }

  Widget _buildBottomActionBar() {
    return GlassmorphicContainer(
      borderRadius: 0,
      borderWidth: 0,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBarItem(Icons.share_rounded, 'Share', _shareDocument),
            _buildBarItem(Icons.print_rounded, 'Print', _printDocument),
            if (['jpg', 'png', 'webp'].contains(_currentFileType))
              _buildBarItem(Icons.rotate_right_rounded, 'Rotate', _rotateImage),
            if (_currentFileType == 'txt') ...[
              _buildBarItem(Icons.zoom_in_rounded, 'Zoom In', () {
                setState(
                  () => _textFontSize = (_textFontSize + 2).clamp(10.0, 30.0),
                );
              }),
              _buildBarItem(Icons.zoom_out_rounded, 'Zoom Out', () {
                setState(
                  () => _textFontSize = (_textFontSize - 2).clamp(10.0, 30.0),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.r, color: AppColors.primary),
            Gap(4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
