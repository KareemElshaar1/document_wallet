import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../document_manager/presentation/cubit/document_cubit.dart';
import '../../../document_manager/presentation/cubit/document_state.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: BlocBuilder<DocumentCubit, DocumentState>(
        builder: (context, state) {
          final categoryDocs = state.documents
              .where((doc) => doc.categoryId == categoryName)
              .toList();

          if (categoryDocs.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder_open_rounded,
                        size: 64.r,
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                    Gap(16.h),
                    Text(
                      'No documents here',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(6.h),
                    Text(
                      'Any documents you add to $categoryName will appear here.',
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
            itemCount: categoryDocs.length,
            separatorBuilder: (_, __) => Gap(12.h),
            itemBuilder: (context, index) {
              final doc = categoryDocs[index];

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
                  subtitle: Text(doc.fileType.toUpperCase()),
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
