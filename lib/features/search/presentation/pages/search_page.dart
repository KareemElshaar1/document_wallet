import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../document_manager/data/models/document_model.dart';
import '../../../document_manager/presentation/cubit/document_cubit.dart';
import '../../../document_manager/presentation/cubit/document_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedFileType;
  String _sortBy = 'newest'; // newest, oldest, name, size

  final List<String> _fileTypes = ['pdf', 'jpg', 'png', 'webp', 'txt'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentModel> _filterAndSort(List<DocumentModel> docs) {
    var filtered = docs.where((doc) {
      final q = _searchQuery.toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          doc.title.toLowerCase().contains(q) ||
          doc.description.toLowerCase().contains(q) ||
          doc.tags.any((t) => t.toLowerCase().contains(q));

      final matchesCategory =
          _selectedCategory == null || doc.categoryId == _selectedCategory;
      final matchesType =
          _selectedFileType == null || doc.fileType == _selectedFileType;

      return matchesQuery && matchesCategory && matchesType;
    }).toList();

    if (_sortBy == 'newest') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'oldest') {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortBy == 'name') {
      filtered.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (_sortBy == 'size') {
      filtered.sort((a, b) => b.fileSize.compareTo(a.fileSize));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final categories = [
      {
        'name': l10n.categoryPersonal,
        'id': AppStrings.categoryPersonal,
        'icon': Icons.person_rounded,
      },
      {
        'name': l10n.categoryEducation,
        'id': AppStrings.categoryEducation,
        'icon': Icons.school_rounded,
      },
      {
        'name': l10n.categoryMedical,
        'id': AppStrings.categoryMedical,
        'icon': Icons.medical_services_rounded,
      },
      {
        'name': l10n.categoryFinance,
        'id': AppStrings.categoryFinance,
        'icon': Icons.account_balance_wallet_rounded,
      },
      {
        'name': l10n.categoryWork,
        'id': AppStrings.categoryWork,
        'icon': Icons.business_center_rounded,
      },
      {
        'name': l10n.categoryVehicle,
        'id': AppStrings.categoryVehicle,
        'icon': Icons.directions_car_rounded,
      },
      {
        'name': l10n.categoryWarranty,
        'id': AppStrings.categoryWarranty,
        'icon': Icons.verified_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.search), centerTitle: true),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: l10n.searchDocs,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          // Filters and Sorting Toolbar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.sortBy,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox.shrink(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (val) {
                    if (val != null) setState(() => _sortBy = val);
                  },
                  items: [
                    DropdownMenuItem(value: 'newest', child: Text(l10n.newest)),
                    DropdownMenuItem(value: 'oldest', child: Text(l10n.oldest)),
                    DropdownMenuItem(value: 'name', child: Text(l10n.nameAZ)),
                    DropdownMenuItem(value: 'size', child: Text(l10n.sizeDesc)),
                  ],
                ),
              ],
            ),
          ),

          // Category filter list
          SizedBox(
            height: 36.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategory == null;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(l10n.allTypes),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                  );
                }
                final cat = categories[index - 1];
                final id = cat['id'] as String;
                final name = cat['name'] as String;
                final isSelected = _selectedCategory == id;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = id),
                  ),
                );
              },
            ),
          ),
          Gap(8.h),

          // File Type filter list
          SizedBox(
            height: 36.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _fileTypes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedFileType == null;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(l10n.allTypes),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedFileType = null),
                    ),
                  );
                }
                final type = _fileTypes[index - 1];
                final isSelected = _selectedFileType == type;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(type.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFileType = type),
                  ),
                );
              },
            ),
          ),
          Gap(12.h),

          // Results List
          Expanded(
            child: BlocBuilder<DocumentCubit, DocumentState>(
              builder: (context, state) {
                final results = _filterAndSort(state.documents);

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64.r,
                          color: Colors.grey,
                        ),
                        Gap(16.h),
                        Text(
                          l10n.noDocuments,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => Gap(12.h),
                  itemBuilder: (context, index) {
                    final doc = results[index];
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
                              const Icon(
                                Icons.lock_rounded,
                                color: AppColors.warning,
                                size: 16,
                              ),
                            if (doc.isFavorite)
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
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
          ),
        ],
      ),
    );
  }
}
