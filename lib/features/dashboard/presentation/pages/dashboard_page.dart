import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helpers/icon_code_helper.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../document_manager/data/models/document_model.dart';
import '../../../document_manager/data/models/folder_model.dart';
import '../../../document_manager/presentation/pages/add_document_page.dart';
import '../../../document_manager/presentation/cubit/document_cubit.dart';
import '../../../document_manager/presentation/cubit/document_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// IDs of expiring docs the user has dismissed for this session
  final Set<String> _dismissedDocIds = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, l10n),
        tablet: _buildTabletDesktopLayout(context, l10n, isTablet: true),
        desktop: _buildTabletDesktopLayout(context, l10n, isTablet: false),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard',
        onPressed: () => Navigator.pushNamed(context, AppRouter.addDocument),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        if (state.status == DocumentStatus.loading && state.documents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final categoryCounts = _countByCategory(state.documents);
        final folderCounts = _countByFolder(state.documents);
        final warningBanner = _buildUrgentWarningBanner(
          context,
          state.documents,
          l10n,
          now,
        );

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<DocumentCubit>().loadAllData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: _buildHeader(context, l10n),
                  ),
                  Gap(20.h),
                  if (warningBanner != null) ...[warningBanner, Gap(20.h)],
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: _buildStorageStats(state.documents, l10n, now),
                  ),
                  Gap(25.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildQuickActions(context, l10n),
                  ),
                  Gap(25.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: _buildExpiringAlerts(
                      context,
                      state.documents,
                      l10n,
                      now,
                    ),
                  ),
                  Gap(25.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: _buildCategoriesSection(
                      context,
                      categoryCounts,
                      l10n,
                    ),
                  ),
                  Gap(25.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    child: _buildFoldersSection(
                      context,
                      state.folders,
                      folderCounts,
                      l10n,
                    ),
                  ),
                  Gap(25.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: _buildRecentDocuments(
                      context,
                      state.documents,
                      l10n,
                    ),
                  ),
                  Gap(80.h), // Spacer for fab
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletDesktopLayout(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isTablet,
  }) {
    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        final now = DateTime.now();
        final categoryCounts = _countByCategory(state.documents);
        final folderCounts = _countByFolder(state.documents);
        final warningBanner = _buildUrgentWarningBanner(
          context,
          state.documents,
          l10n,
          now,
        );

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeader(context, l10n),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.addDocument),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(l10n.addDocument),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(180.w, 48.h),
                      ),
                    ),
                  ],
                ),
                Gap(25.h),
                if (warningBanner != null) ...[warningBanner, Gap(25.h)],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Grid items (Stats, Quick actions)
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildStorageStats(state.documents, l10n, now),
                          Gap(25.h),
                          _buildQuickActions(context, l10n),
                          Gap(25.h),
                          _buildFoldersSection(
                            context,
                            state.folders,
                            folderCounts,
                            l10n,
                          ),
                        ],
                      ),
                    ),
                    Gap(30.w),
                    // Right Grid items (Expiring, categories, recents)
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildExpiringAlerts(
                            context,
                            state.documents,
                            l10n,
                            now,
                          ),
                          Gap(25.h),
                          _buildCategoriesSection(
                            context,
                            categoryCounts,
                            l10n,
                          ),
                          Gap(25.h),
                          _buildRecentDocuments(context, state.documents, l10n),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.secureVault,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              l10n.welcomeBack,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.setting),
              icon: const Icon(Icons.settings_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- DOCUMENT OVERVIEW ---
  Map<String, int> _countByCategory(List<DocumentModel> docs) {
    final counts = <String, int>{};
    for (final doc in docs) {
      counts.update(doc.categoryId, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Map<String, int> _countByFolder(List<DocumentModel> docs) {
    final counts = <String, int>{};
    for (final doc in docs) {
      final folderId = doc.folderId;
      if (folderId == null) continue;
      counts.update(folderId, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Widget _buildStorageStats(
    List<DocumentModel> docs,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final total = docs.length;
    final favorites = docs.where((d) => d.isFavorite).length;
    final locked = docs.where((d) => d.isLocked).length;
    final expiringSoon = docs.where((d) {
      if (d.expirationDate == null) return false;
      final diff = d.expirationDate!.difference(now).inDays;
      return diff >= 0 && diff <= 30;
    }).length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_special_rounded,
                color: Colors.white70,
                size: 18.r,
              ),
              Gap(8.w),
              Text(
                l10n.documents,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewStat(
                Icons.description_rounded,
                total.toString(),
                l10n.totalFiles,
              ),
              _buildOverviewStat(
                Icons.star_rounded,
                favorites.toString(),
                l10n.favorites,
              ),
              _buildOverviewStat(
                Icons.lock_rounded,
                locked.toString(),
                l10n.lock,
              ),
              _buildOverviewStat(
                Icons.warning_amber_rounded,
                expiringSoon.toString(),
                l10n.expiringSoon,
                highlight: expiringSoon > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(
    IconData icon,
    String count,
    String label, {
    bool highlight = false,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: highlight
                ? Colors.amber.withOpacity(0.3)
                : Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18.r),
        ),
        Gap(6.h),
        Text(
          count,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- QUICK ACTIONS ---
  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        Gap(12.h),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                context,
                icon: Icons.camera_alt_rounded,
                label: l10n.takePhoto,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.addDocument,
                  arguments: AddDocumentLaunchMode.camera,
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: _buildActionTile(
                context,
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.scanQrCode,
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.addDocument,
                  arguments: AddDocumentLaunchMode.qr,
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: _buildActionTile(
                context,
                icon: Icons.add_photo_alternate_rounded,
                label: l10n.importImage,
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.addDocument,
                  arguments: AddDocumentLaunchMode.gallery,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28.r),
              Gap(8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- URGENT WARNING BANNER ---
  Widget? _buildUrgentWarningBanner(
    BuildContext context,
    List<DocumentModel> docs,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final urgentDocs = <DocumentModel>[];

    for (final doc in docs) {
      if (doc.expirationDate == null) continue;
      final difference = doc.expirationDate!.difference(now).inDays;

      // We treat expired (difference < 0) or expiring today (difference == 0) as urgent
      if (difference <= 0) {
        urgentDocs.add(doc);
      }
    }

    if (urgentDocs.isEmpty) return null;

    // Sort so expired docs come first, then expiring today
    urgentDocs.sort((a, b) {
      if (a.expirationDate == null || b.expirationDate == null) return 0;
      return a.expirationDate!.compareTo(b.expirationDate!);
    });

    final doc = urgentDocs.first;
    final diff = doc.expirationDate!.difference(now).inDays;
    final isExpired = diff < 0;

    final bannerColor = isExpired ? AppColors.error : AppColors.warning;

    // Construct message: "Warning: 'ID Card' expired!" or "Warning: 'ID Card' expires today!"
    final message = isExpired
        ? '${l10n.warning}: "${doc.title}" ${l10n.expired.toLowerCase()}!'
        : '${l10n.warning}: "${doc.title}" ${l10n.expiresToday.toLowerCase()}!';

    final subtitle = isExpired ? l10n.pleaseRenew : l10n.pleaseCheck;

    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bannerColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: bannerColor.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              isExpired
                  ? Icons.error_outline_rounded
                  : Icons.warning_amber_rounded,
              color: bannerColor,
              size: 28.r,
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: bannerColor,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: bannerColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Gap(8.w),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.viewer, arguments: doc);
              },
              style: TextButton.styleFrom(
                foregroundColor: bannerColor,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: bannerColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                l10n.view,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EXPIRING ALERTS ---
  Widget _buildExpiringAlerts(
    BuildContext context,
    List<DocumentModel> docs,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final expiredDocs = <DocumentModel>[];
    final todayDocs = <DocumentModel>[];
    final weekDocs = <DocumentModel>[];
    final monthDocs = <DocumentModel>[];

    for (final doc in docs) {
      if (doc.expirationDate == null) continue;
      final difference = doc.expirationDate!.difference(now).inDays;

      if (difference < 0) {
        expiredDocs.add(doc);
      } else if (difference == 0) {
        todayDocs.add(doc);
      } else if (difference <= 7) {
        weekDocs.add(doc);
      } else if (difference <= 30) {
        monthDocs.add(doc);
      }
    }

    final totalAlerts =
        expiredDocs.length +
        todayDocs.length +
        weekDocs.length +
        monthDocs.length;
    if (totalAlerts == 0) {
      return Card(
        elevation: 0,
        color: AppColors.accent.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.accent,
                size: 24.r,
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.allSecure,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      l10n.allSecureSubtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.accent.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasExpired = expiredDocs.isNotEmpty;
    final warningColor = hasExpired ? AppColors.error : AppColors.warning;

    return Card(
      elevation: 0,
      color: warningColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: warningColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasExpired
                      ? Icons.error_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: warningColor,
                  size: 24.r,
                ),
                Gap(10.w),
                Text(
                  '${l10n.expirationAlerts} ($totalAlerts)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: warningColor,
                  ),
                ),
              ],
            ),
            Gap(10.h),
            if (expiredDocs.isNotEmpty)
              _buildExpiringCategoryItem(
                context,
                l10n.expired,
                expiredDocs,
                AppColors.error,
              ),
            if (todayDocs.isNotEmpty)
              _buildExpiringCategoryItem(
                context,
                l10n.expiresToday,
                todayDocs,
                AppColors.error,
              ),
            if (weekDocs.isNotEmpty)
              _buildExpiringCategoryItem(
                context,
                l10n.expiresThisWeek,
                weekDocs,
                AppColors.warning,
              ),
            if (monthDocs.isNotEmpty)
              _buildExpiringCategoryItem(
                context,
                l10n.expiresThisMonth,
                monthDocs,
                Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringCategoryItem(
    BuildContext context,
    String label,
    List<DocumentModel> docs,
    Color color,
  ) {
    // Filter out dismissed docs
    final visible = docs
        .where((d) => !_dismissedDocIds.contains(d.id))
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      children: visible.map((doc) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            doc.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${AppLocalizations.of(context).category}: ${doc.categoryName}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Gap(4.w),
              // Dismiss button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _dismissedDocIds.add(doc.id);
                  });
                },
                child: Tooltip(
                  message: 'Dismiss',
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16.r,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, AppRouter.viewer, arguments: doc);
          },
        );
      }).toList(),
    );
  }

  // --- CATEGORIES SECTION ---
  Widget _buildCategoriesSection(
    BuildContext context,
    Map<String, int> categoryCounts,
    AppLocalizations l10n,
  ) {
    final categories = [
      {
        'name': l10n.categoryPersonal,
        'id': AppStrings.categoryPersonal,
        'icon': Icons.person_rounded,
        'color': AppColors.primary,
      },
      {
        'name': l10n.categoryEducation,
        'id': AppStrings.categoryEducation,
        'icon': Icons.school_rounded,
        'color': AppColors.secondary,
      },
      {
        'name': l10n.categoryMedical,
        'id': AppStrings.categoryMedical,
        'icon': Icons.medical_services_rounded,
        'color': AppColors.accent,
      },
      {
        'name': l10n.categoryFinance,
        'id': AppStrings.categoryFinance,
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppColors.warning,
      },
      {
        'name': l10n.categoryWork,
        'id': AppStrings.categoryWork,
        'icon': Icons.business_center_rounded,
        'color': Colors.indigo,
      },
      {
        'name': l10n.categoryVehicle,
        'id': AppStrings.categoryVehicle,
        'icon': Icons.directions_car_rounded,
        'color': Colors.teal,
      },
      {
        'name': l10n.categoryWarranty,
        'id': AppStrings.categoryWarranty,
        'icon': Icons.verified_rounded,
        'color': Colors.deepOrange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categories,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        Gap(12.h),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catName = cat['name'] as String;
              final catId = cat['id'] as String;
              final count = categoryCounts[catId] ?? 0;

              return Card(
                elevation: 0,
                margin: EdgeInsets.only(right: 12.w),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.categoryDetail,
                      arguments: catId,
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 110.w,
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                          size: 26.r,
                        ),
                        const Spacer(),
                        Text(
                          catName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$count ${l10n.documents.toLowerCase()}',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- FOLDERS SECTION ---
  Widget _buildFoldersSection(
    BuildContext context,
    List<FolderModel> folders,
    Map<String, int> folderCounts,
    AppLocalizations l10n,
  ) {
    if (folders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.folders,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        Gap(12.h),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final count = folderCounts[folder.id] ?? 0;

              return Card(
                elevation: 0,
                color: Color(folder.colorValue).withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: Color(folder.colorValue).withOpacity(0.2),
                  ),
                ),
                margin: EdgeInsets.only(right: 12.w),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.folderDetail,
                      arguments: folder,
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 140.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconCodeHelper.folderIcon(folder.iconCode),
                          color: Color(folder.colorValue),
                          size: 28.r,
                        ),
                        Gap(10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                folder.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$count ${l10n.documents.toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- RECENT DOCUMENTS ---
  Widget _buildRecentDocuments(
    BuildContext context,
    List<DocumentModel> docs,
    AppLocalizations l10n,
  ) {
    if (docs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentDocuments,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          Gap(12.h),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Container(
                    height: 120.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.folder_open_rounded, size: 48),
                  ),
                  Gap(12.h),
                  Text(
                    l10n.noDocuments,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final recentDocs = docs.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final limitDocs = recentDocs.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentDocuments,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        Gap(12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: limitDocs.length,
          separatorBuilder: (_, __) => Gap(10.h),
          itemBuilder: (context, index) {
            final doc = limitDocs[index];
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
                trailing: const Icon(Icons.chevron_right_rounded),
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
        ),
      ],
    );
  }
}
