import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../document_manager/data/models/folder_model.dart';
import '../../../document_manager/presentation/cubit/document_cubit.dart';
import '../../../document_manager/presentation/cubit/document_state.dart';

class FolderDetailPage extends StatefulWidget {
  final FolderModel folder;

  const FolderDetailPage({super.key, required this.folder});

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  late FolderModel _folder;

  @override
  void initState() {
    super.initState();
    _folder = widget.folder;
  }

  void _renameFolder() {
    final controller = TextEditingController(text: _folder.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Name'),
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
                  context.read<DocumentCubit>().renameFolder(
                    _folder.id,
                    newName,
                  );
                  setState(() {
                    _folder = _folder.copyWith(name: newName);
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

  void _deleteFolder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Folder'),
          content: const Text(
            'Are you sure you want to delete this folder? '
            'Documents inside will NOT be deleted, they will be moved to "Uncategorized".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<DocumentCubit>().deleteFolder(_folder.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(this.context); // Exit page
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(_folder.iconCode, fontFamily: 'MaterialIcons'),
              color: Color(_folder.colorValue),
            ),
            Gap(10.w),
            Text(_folder.name),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<DocumentCubit>().toggleFavoriteFolder(_folder.id);
              setState(() {
                _folder = _folder.copyWith(isFavorite: !_folder.isFavorite);
              });
            },
            icon: Icon(
              _folder.isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _folder.isFavorite ? Color(_folder.colorValue) : null,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'rename') _renameFolder();
              if (val == 'delete') _deleteFolder();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete Folder',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<DocumentCubit, DocumentState>(
        builder: (context, state) {
          final folderDocs = state.documents
              .where((doc) => doc.folderId == _folder.id)
              .toList();

          if (folderDocs.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Color(_folder.colorValue).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(_folder.iconCode, fontFamily: 'MaterialIcons'),
                        size: 64.r,
                        color: Color(_folder.colorValue).withOpacity(0.4),
                      ),
                    ),
                    Gap(16.h),
                    Text(
                      'This folder is empty',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(6.h),
                    Text(
                      'Move documents to this folder when importing or editing.',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(20.r),
            itemCount: folderDocs.length,
            separatorBuilder: (_, __) => Gap(12.h),
            itemBuilder: (context, index) {
              final doc = folderDocs[index];

              IconData fileIcon = Icons.insert_drive_file_rounded;
              Color iconColor = AppColors.primary;

              if (doc.fileType == 'pdf') {
                fileIcon = Icons.picture_as_pdf_rounded;
                iconColor = Colors.red;
              } else if (doc.fileType == 'txt') {
                fileIcon = Icons.description_rounded;
                iconColor = Colors.amber;
              } else if (['jpg', 'png', 'webp'].contains(doc.fileType)) {
                fileIcon = Icons.image_rounded;
                iconColor = Colors.green;
              }

              return Card(
                elevation: 0,
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(fileIcon, color: iconColor, size: 24.r),
                  ),
                  title: Text(
                    doc.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${doc.categoryName} • ${doc.fileType.toUpperCase()}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (doc.isLocked)
                        Icon(
                          Icons.lock_rounded,
                          color: AppColors.warning,
                          size: 18.r,
                        ),
                      if (doc.isFavorite) ...[
                        Gap(8.w),
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18.r,
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.viewer,
                      arguments: doc,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
