class SettingsState {
  final bool isDarkMode;
  final String languageCode;
  final int reminderDaysBefore;
  final bool isNotificationsEnabled;
  final bool isBiometricEnabled;
  final int notificationTimeHour;
  final int notificationTimeMinute;

  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
    required this.reminderDaysBefore,
    required this.isNotificationsEnabled,
    this.isBiometricEnabled = false,
    this.notificationTimeHour = 9,
    this.notificationTimeMinute = 0,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isDarkMode: true,
      languageCode: 'en',
      reminderDaysBefore: 7,
      isNotificationsEnabled: true,
      isBiometricEnabled: false,
      notificationTimeHour: 9,
      notificationTimeMinute: 0,
    );
  }

  SettingsState copyWith({
    bool? isDarkMode,
    String? languageCode,
    int? reminderDaysBefore,
    bool? isNotificationsEnabled,
    bool? isBiometricEnabled,
    int? notificationTimeHour,
    int? notificationTimeMinute,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      notificationTimeHour: notificationTimeHour ?? this.notificationTimeHour,
      notificationTimeMinute: notificationTimeMinute ?? this.notificationTimeMinute,
    );
  }
}
