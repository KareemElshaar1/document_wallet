import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../authentication/presentation/cubit/auth_state.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../../document_manager/presentation/cubit/document_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- SECURITY ACTIONS ---
  Future<void> _toggleAppLock(bool enabled) async {
    if (enabled) {
      Navigator.pushNamed(context, AppRouter.setupPin).then((_) {
        if (!context.mounted) return;
        final authState = context.read<AuthCubit>().state;
        if (authState is! AuthSuccess) {
          context.read<AuthCubit>().checkAuthStatus();
        }
      });
    } else {
      _confirmAndTurnOffLock();
    }
  }

  void _confirmAndTurnOffLock() {
    final controller = TextEditingController();
    final parentContext = this.context;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deactivateAppLock),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              hintText: l10n.enterPin,
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final pin = controller.text.trim();
                final success = await parentContext.read<AuthCubit>().verifyPin(
                  pin,
                );
                if (success) {
                  await parentContext.read<AuthCubit>().factoryReset();
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(content: Text(l10n.appLockDeactivated)),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(
                    parentContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.invalidPin)));
                  controller.clear();
                }
              },
              child: Text(
                l10n.deactivate,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- BACKUP & RESTORE ---
  Future<void> _exportBackup(BuildContext context) async {
    AppLocalizations.of(context);
    try {
      final folders = HiveStorage.getFolders();
      final docs = HiveStorage.getDocuments();

      final backupData = {'version': 1, 'folders': folders, 'documents': docs};

      final jsonString = jsonEncode(backupData);

      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/document_wallet_backup.json');
      await backupFile.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(backupFile.path)],
          text: 'Document Wallet Backup Metadata JSON',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup failed: ${e.toString()}')));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final cubit = context.read<DocumentCubit>();
    AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);

        final List rawFolders = data['folders'] ?? [];
        final List rawDocs = data['documents'] ?? [];

        final folders = rawFolders
            .map((f) => Map<String, dynamic>.from(f))
            .toList();
        final documents = rawDocs
            .map((d) => Map<String, dynamic>.from(d))
            .toList();

        await cubit.restoreBackup(folders: folders, documents: documents);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup Imported Successfully')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: ${e.toString()}')));
    }
  }

  // --- FACTORY RESET ---
  void _showFactoryResetDialog(BuildContext context) {
    final controller = TextEditingController();
    final parentContext = this.context;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.factoryResetTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.factoryResetMessage),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: l10n.enterPinToConfirm,
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final pin = controller.text.trim();
                final success = await parentContext.read<AuthCubit>().verifyPin(
                  pin,
                );
                if (!success) {
                  ScaffoldMessenger.of(
                    parentContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.invalidPin)));
                  controller.clear();
                  return;
                }

                // Delete actual local documents from disk
                final docs = parentContext
                    .read<DocumentCubit>()
                    .state
                    .documents;
                for (final doc in docs) {
                  try {
                    final file = File(doc.filePath);
                    if (await file.exists()) {
                      await file.delete();
                    }
                  } catch (_) {}
                }

                // Clear Hive boxes and reset settings
                await HiveStorage.clearAll();
                await sl<SecureStorage>().clearSecureData();
                await sl<NotificationService>().cancelAllAlerts();

                if (mounted) {
                  Navigator.of(parentContext).pop();
                  await parentContext.read<AuthCubit>().checkAuthStatus();
                  parentContext.read<DocumentCubit>().loadAllData();

                  if (Navigator.of(parentContext).canPop()) {
                    Navigator.of(
                      parentContext,
                    ).popUntil((route) => route.isFirst);
                  }
                }
              },
              child: Text(
                l10n.eraseAll,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectNotificationTime(
    BuildContext context,
    SettingsState state,
  ) async {
    AppLocalizations.of(context);
    final initialTime = TimeOfDay(
      hour: state.notificationTimeHour,
      minute: state.notificationTimeMinute,
    );
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null && mounted) {
      context.read<SettingsCubit>().changeNotificationTime(
        pickedTime.hour,
        pickedTime.minute,
      );
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
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final isAppLockEnabled = authState is! AuthSetupRequired;

              return ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                children: [
                  _buildSectionHeader(l10n.appearance),
                  SwitchListTile(
                    title: Text(l10n.darkMode),
                    subtitle: Text(l10n.darkModeSubtitle),
                    value: settingsState.isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      context.read<SettingsCubit>().toggleDarkMode(val);
                    },
                  ),
                  ListTile(
                    title: Text(l10n.language),
                    subtitle: Text(
                      settingsState.languageCode == 'ar'
                          ? 'العربية'
                          : 'English',
                    ),
                    trailing: DropdownButton<String>(
                      value: settingsState.languageCode,
                      underline: const SizedBox.shrink(),
                      dropdownColor: surfaceColor,
                      style: TextStyle(color: textColor, fontSize: 14.sp),
                      iconEnabledColor: textColor,
                      onChanged: (val) {
                        if (val != null) {
                          context.read<SettingsCubit>().changeLanguage(val);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            l10n.english,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text(
                            l10n.arabic,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  _buildSectionHeader(l10n.securitySettings),
                  SwitchListTile(
                    title: Text(l10n.appLockPin),
                    subtitle: Text(l10n.appLockPinSubtitle),
                    value: isAppLockEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: _toggleAppLock,
                  ),
                  const Divider(),

                  _buildSectionHeader(l10n.notificationSettings),
                  SwitchListTile(
                    title: Text(l10n.notifications),
                    subtitle: Text(l10n.notificationTimeSubtitle),
                    value: settingsState.isNotificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      context.read<SettingsCubit>().toggleNotifications(val);
                    },
                  ),
                  ListTile(
                    title: Text(l10n.reminderDays),
                    subtitle: Text('${settingsState.reminderDaysBefore} Days'),
                    trailing: DropdownButton<int>(
                      value: settingsState.reminderDaysBefore,
                      underline: const SizedBox.shrink(),
                      dropdownColor: surfaceColor,
                      style: TextStyle(color: textColor, fontSize: 14.sp),
                      iconEnabledColor: textColor,
                      onChanged: (val) {
                        if (val != null) {
                          context.read<SettingsCubit>().changeReminderDays(val);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            '1 Day',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text(
                            '3 Days',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 7,
                          child: Text(
                            '7 Days',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 14,
                          child: Text(
                            '14 Days',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.notificationTime),
                    subtitle: Text(l10n.notificationTimeSubtitle),
                    trailing: TextButton(
                      onPressed: () =>
                          _selectNotificationTime(context, settingsState),
                      child: Text(
                        '${settingsState.notificationTimeHour.toString().padLeft(2, '0')}:${settingsState.notificationTimeMinute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),

                  _buildSectionHeader(l10n.backupRestore),
                  ListTile(
                    leading: const Icon(
                      Icons.download_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.exportBackup),
                    subtitle: Text(l10n.exportBackupSubtitle),
                    onTap: () => _exportBackup(context),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.upload_rounded,
                      color: AppColors.secondary,
                    ),
                    title: Text(l10n.importBackup),
                    subtitle: Text(l10n.importBackupSubtitle),
                    onTap: () => _importBackup(context),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      l10n.factoryReset,
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text(l10n.factoryResetSubtitle),
                    onTap: () => _showFactoryResetDialog(context),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
