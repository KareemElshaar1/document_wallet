import 'dart:io';
import 'package:document_wallet/features/document_manager/data/models/document_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/image_editor_helper.dart';
import '../../../../core/helpers/media_import_helper.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/document_cubit.dart';
import '../cubit/document_state.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import 'qr_scan_page.dart';

enum AddDocumentLaunchMode { none, camera, gallery, file, qr }

class AddDocumentPage extends StatefulWidget {
  final AddDocumentLaunchMode launchMode;

  const AddDocumentPage({
    super.key,
    this.launchMode = AddDocumentLaunchMode.none,
  });

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final _linkController = TextEditingController();

  String _selectedCategory = AppStrings.categoryPersonal;
  String? _selectedFolderId;
  DateTime? _selectedExpirationDate;
  bool _isLocked = false;

  final List<ImportedMedia> _selectedMedias = [];

  final List<String> _categories = [
    AppStrings.categoryPersonal,
    AppStrings.categoryEducation,
    AppStrings.categoryMedical,
    AppStrings.categoryFinance,
    AppStrings.categoryWork,
    AppStrings.categoryVehicle,
    AppStrings.categoryWarranty,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runLaunchMode();
    });
  }

  Future<void> _runLaunchMode() async {
    switch (widget.launchMode) {
      case AddDocumentLaunchMode.camera:
        await _importFromCamera();
      case AddDocumentLaunchMode.gallery:
        await _importFromGallery();
      case AddDocumentLaunchMode.file:
        await _importFromFilePicker();
      case AddDocumentLaunchMode.qr:
        await _scanQrAndAttachPhoto();
      case AddDocumentLaunchMode.none:
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _applyImportedMedia(ImportedMedia media, String suggestedTitle) {
    if (!mounted) return;
    setState(() {
      _selectedMedias.add(media);
      if (_titleController.text.isEmpty) {
        _titleController.text = suggestedTitle;
      }
    });
  }

  Future<void> _importFromFilePicker() async {
    final media = await MediaImportHelper.importFromFilePicker();
    if (media == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file picker')),
        );
      }
      return;
    }

    _applyImportedMedia(media, media.fileName.split('.').first);
  }

  Future<void> _importFromCamera() async {
    final media = await MediaImportHelper.importFromCamera(context);
    if (media != null) {
      _applyImportedMedia(
        media,
        'Photo_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> _importFromGallery() async {
    final media = await MediaImportHelper.importFromGallery(context);
    if (media != null) {
      _applyImportedMedia(
        media,
        'Gallery_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> _scanQrAndAttachPhoto() async {
    final result = await Navigator.push<QrScanResult>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );

    if (result == null || !mounted) return;

    final link = result.url ?? result.rawValue;
    _linkController.text = link;

    if (_descController.text.isEmpty) {
      _descController.text = 'Linked URL: $link';
    } else if (!_descController.text.contains(link)) {
      _descController.text = '${_descController.text}\nLinked URL: $link';
    }

    if (_tagController.text.isEmpty) {
      _tagController.text = 'qr, link';
    } else if (!_tagController.text.contains('qr')) {
      _tagController.text = '${_tagController.text}, qr, link';
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('QR detected: $link')));
    }
  }

  Future<void> _editSelectedPhoto(int index) async {
    final media = _selectedMedias[index];

    final isImage =
        media.fileType == 'jpg' ||
        media.fileType == 'jpeg' ||
        media.fileType == 'png' ||
        media.fileType == 'webp';

    if (!isImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only photos can be edited')),
      );
      return;
    }

    try {
      final croppedPath = await ImageEditorHelper.editImage(
        sourcePath: media.file.path,
        context: context,
      );
      if (croppedPath == null || !mounted) return;

      final file = File(croppedPath);
      final size = await file.length();
      final ext = croppedPath.split('.').last.toLowerCase();

      if (!mounted) return;
      setState(() {
        _selectedMedias[index] = ImportedMedia(
          file: file,
          fileName: media.fileName,
          fileSize: size,
          fileType: ext == 'jpeg' ? 'jpg' : ext,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Edit failed: $e')));
      }
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMedias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo or file first')),
      );
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localFolder = Directory('${appDir.path}/secure_wallet_files');
      if (!await localFolder.exists()) {
        await localFolder.create(recursive: true);
      }

      final mainMedia = _selectedMedias.first;
      final uniqueMainFileName =
          '${DateTime.now().microsecondsSinceEpoch}_0.${mainMedia.fileType}';
      final mainLocalFilePath = '${localFolder.path}/$uniqueMainFileName';
      await mainMedia.file.copy(mainLocalFilePath);

      final List<DocumentFile> additionalFiles = [];
      for (int i = 1; i < _selectedMedias.length; i++) {
        final media = _selectedMedias[i];
        final uniqueFileName =
            '${DateTime.now().microsecondsSinceEpoch}_$i.${media.fileType}';
        final localFilePath = '${localFolder.path}/$uniqueFileName';
        await media.file.copy(localFilePath);
        additionalFiles.add(
          DocumentFile(
            filePath: localFilePath,
            fileSize: media.fileSize,
            fileType: media.fileType,
          ),
        );
      }

      final tagsList = _tagController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final link = _linkController.text.trim();
      var description = _descController.text.trim();
      if (link.isNotEmpty && !description.contains(link)) {
        description = description.isEmpty
            ? 'Linked URL: $link'
            : '$description\nLinked URL: $link';
      }

      await context.read<DocumentCubit>().addDocument(
        title: _titleController.text.trim(),
        categoryId: _selectedCategory,
        categoryName: _selectedCategory,
        folderId: _selectedFolderId,
        description: description,
        tags: tagsList,
        expirationDate: _selectedExpirationDate,
        fileSize: mainMedia.fileSize,
        fileType: mainMedia.fileType,
        filePath: mainLocalFilePath,
        isLocked: _isLocked,
        additionalFiles: additionalFiles,
      );

      if (_selectedExpirationDate != null) {
        final settingsState = context.read<SettingsCubit>().state;
        if (settingsState.isNotificationsEnabled) {
          final notificationId = DateTime.now().millisecondsSinceEpoch
              .remainder(100000);
          final reminderDate = _selectedExpirationDate!.subtract(
            Duration(days: settingsState.reminderDaysBefore),
          );
          final scheduledTime = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
            settingsState.notificationTimeHour,
            settingsState.notificationTimeMinute,
          );

          final localNotifier = sl<NotificationService>();
          final scheduled = await localNotifier.scheduleExpirationAlert(
            id: notificationId,
            title: 'Document Expiring Soon',
            body:
                'Your document "${_titleController.text}" will expire on ${DateFormat('yyyy-MM-dd').format(_selectedExpirationDate!)}.',
            scheduledDateTime: scheduledTime,
          );

          if (!scheduled && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Document saved, but reminder notification could not be scheduled.',
                ),
              ),
            );
          }
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving document: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addDocument)),
      body: BlocBuilder<DocumentCubit, DocumentState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilePickerDeck(l10n),
                  Gap(20.h),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.documentTitle),
                    validator: (v) => v == null || v.isEmpty
                        ? '${l10n.documentTitle} *'
                        : null,
                  ),
                  Gap(16.h),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(labelText: l10n.category),
                    dropdownColor: surfaceColor,
                    style: TextStyle(color: textColor, fontSize: 14.sp),
                    iconEnabledColor: textColor,
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  Gap(16.h),
                  if (state.folders.isNotEmpty) ...[
                    DropdownButtonFormField<String?>(
                      value: _selectedFolderId,
                      decoration: InputDecoration(labelText: l10n.moveToFolder),
                      dropdownColor: surfaceColor,
                      style: TextStyle(color: textColor, fontSize: 14.sp),
                      iconEnabledColor: textColor,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            l10n.noFolder,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        ...state.folders.map((folder) {
                          return DropdownMenuItem<String?>(
                            value: folder.id,
                            child: Text(
                              folder.name,
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedFolderId = val);
                      },
                    ),
                    Gap(16.h),
                  ],
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionOptional,
                    ),
                    maxLines: 2,
                  ),
                  Gap(16.h),
                  TextFormField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: l10n.linkedUrl,
                      hintText: 'https://example.com',
                      prefixIcon: const Icon(Icons.link_rounded),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  Gap(16.h),
                  TextFormField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: l10n.tagsOptional,
                      hintText: 'e.g. id, photo, qr',
                    ),
                  ),
                  Gap(16.h),
                  _buildDatePickerTile(context, l10n),
                  Gap(16.h),
                  _buildLockToggle(l10n),
                  Gap(30.h),
                  PrimaryButton(
                    text: l10n.saveToVault,
                    isLoading: state.status == DocumentStatus.loading,
                    onPressed: _saveDocument,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileItem(int index, ImportedMedia media, AppLocalizations l10n) {
    final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(media.fileType);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: isImage
                ? Image.file(
                    media.file,
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 50.w,
                    height: 50.h,
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      media.fileType == 'pdf'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.insert_drive_file_rounded,
                      color: media.fileType == 'pdf'
                          ? Colors.red
                          : AppColors.primary,
                      size: 28.r,
                    ),
                  ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Size: ${(media.fileSize / 1024).toStringAsFixed(1)} KB • Type: ${media.fileType.toUpperCase()}',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isImage)
            IconButton(
              onPressed: () => _editSelectedPhoto(index),
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              tooltip: l10n.editPhoto,
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMedias.removeAt(index);
              });
            },
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerDeck(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            if (_selectedMedias.isEmpty) ...[
              Icon(
                Icons.add_a_photo_outlined,
                size: 48.r,
                color: AppColors.primary,
              ),
              Gap(10.h),
              Text(
                l10n.noFileSelected,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              Gap(15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceIconBtn(
                    Icons.camera_alt_rounded,
                    l10n.takePhoto,
                    _importFromCamera,
                  ),
                  _buildSourceIconBtn(
                    Icons.photo_library_rounded,
                    l10n.gallery,
                    _importFromGallery,
                  ),
                  _buildSourceIconBtn(
                    Icons.qr_code_scanner_rounded,
                    l10n.scanQrCode,
                    _scanQrAndAttachPhoto,
                  ),
                  _buildSourceIconBtn(
                    Icons.file_present_rounded,
                    l10n.files,
                    _importFromFilePicker,
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Selected Files (${_selectedMedias.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: AppColors.primary,
                ),
              ),
              Gap(10.h),
              ...List.generate(
                _selectedMedias.length,
                (index) => _buildFileItem(index, _selectedMedias[index], l10n),
              ),
              const Divider(),
              Gap(5.h),
              Text(
                'Add More:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              Gap(5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniSourceBtn(
                    Icons.camera_alt_rounded,
                    _importFromCamera,
                  ),
                  _buildMiniSourceBtn(
                    Icons.photo_library_rounded,
                    _importFromGallery,
                  ),
                  _buildMiniSourceBtn(
                    Icons.qr_code_scanner_rounded,
                    _scanQrAndAttachPhoto,
                  ),
                  _buildMiniSourceBtn(
                    Icons.file_present_rounded,
                    _importFromFilePicker,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSourceBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.primary),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        padding: EdgeInsets.all(8.r),
      ),
    );
  }

  Widget _buildSourceIconBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: EdgeInsets.all(12.r),
            ),
          ),
          Gap(4.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerTile(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 36500)),
        );
        if (date != null) {
          setState(() => _selectedExpirationDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: l10n.expirationDateOptional),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedExpirationDate == null
                  ? l10n.noExpiryDate
                  : DateFormat('yyyy-MM-dd').format(_selectedExpirationDate!),
              style: TextStyle(
                color: _selectedExpirationDate == null
                    ? (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              ),
            ),
            Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockToggle(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: _isLocked
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: _isLocked
              ? AppColors.primary.withOpacity(0.2)
              : Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          l10n.lockDocument,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(l10n.lockDocumentSubtitle),
        value: _isLocked,
        activeColor: AppColors.primary,
        onChanged: (val) => setState(() => _isLocked = val),
      ),
    );
  }
}
