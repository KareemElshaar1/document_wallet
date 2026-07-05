import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/service_locator.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _keyDarkMode = 'setting_dark_mode';
  static const String _keyLanguage = 'setting_language';
  static const String _keyReminderDays = 'setting_reminder_days';
  static const String _keyNotifications = 'setting_notifications_enabled';
  static const String _keyNotificationHour = 'setting_notification_hour';
  static const String _keyNotificationMinute = 'setting_notification_minute';

  SettingsCubit() : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isDark = HiveStorage.getSetting(_keyDarkMode, defaultValue: true) as bool;
    final lang = HiveStorage.getSetting(_keyLanguage, defaultValue: 'en') as String;
    final days = HiveStorage.getSetting(_keyReminderDays, defaultValue: 7) as int;
    final notifications = HiveStorage.getSetting(_keyNotifications, defaultValue: true) as bool;
    final hour = HiveStorage.getSetting(_keyNotificationHour, defaultValue: 9) as int;
    final minute = HiveStorage.getSetting(_keyNotificationMinute, defaultValue: 0) as int;

    // Read biometric preference from secure storage
    final bioEnabled = await sl<SecureStorage>().isBiometricEnabled();

    emit(SettingsState(
      isDarkMode: isDark,
      languageCode: lang,
      reminderDaysBefore: days,
      isNotificationsEnabled: notifications,
      isBiometricEnabled: bioEnabled,
      notificationTimeHour: hour,
      notificationTimeMinute: minute,
    ));
  }

  Future<void> toggleDarkMode(bool value) async {
    await HiveStorage.saveSetting(_keyDarkMode, value);
    emit(state.copyWith(isDarkMode: value));
  }

  Future<void> changeLanguage(String code) async {
    await HiveStorage.saveSetting(_keyLanguage, code);
    emit(state.copyWith(languageCode: code));
  }

  Future<void> changeReminderDays(int days) async {
    await HiveStorage.saveSetting(_keyReminderDays, days);
    emit(state.copyWith(reminderDaysBefore: days));
  }

  Future<void> changeNotificationTime(int hour, int minute) async {
    await HiveStorage.saveSetting(_keyNotificationHour, hour);
    await HiveStorage.saveSetting(_keyNotificationMinute, minute);
    emit(state.copyWith(notificationTimeHour: hour, notificationTimeMinute: minute));
  }

  Future<void> toggleNotifications(bool value) async {
    await HiveStorage.saveSetting(_keyNotifications, value);
    emit(state.copyWith(isNotificationsEnabled: value));
  }

  Future<void> toggleBiometric(bool value) async {
    await sl<SecureStorage>().setBiometricEnabled(value);
    emit(state.copyWith(isBiometricEnabled: value));
  }
}

