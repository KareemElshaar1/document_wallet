import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService(this._notificationsPlugin);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'document_wallet_reminders',
      'Document Expiration Reminders',
      description: 'Notifications sent before documents expire.',
      importance: Importance.high,
    );

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
  }

  void _configureLocalTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();

    try {
      if (minutes == 0) {
        final sign = hours >= 0 ? '-' : '+';
        tz.setLocalLocation(
          tz.getLocation('Etc/GMT$sign${hours.abs()}'),
        );
      } else {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<bool> scheduleExpirationAlert({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    await init();

    if (scheduledDateTime.isBefore(DateTime.now())) {
      await showImmediateAlert(id: id, title: title, body: body);
      return true;
    }

    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'document_wallet_reminders',
        'Document Expiration Reminders',
        channelDescription: 'Notifications sent before documents expire.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final scheduledTz = tz.TZDateTime.from(scheduledDateTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return true;
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTz,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        return true;
      } catch (_) {
        if (Platform.isAndroid || Platform.isIOS) {
          return false;
        }
        await showImmediateAlert(id: id, title: title, body: body);
        return true;
      }
    }
  }

  Future<void> showImmediateAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();

    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'document_wallet_reminders',
          'Document Expiration Reminders',
          channelDescription: 'Notifications sent before documents expire.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAlert(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllAlerts() async {
    await _notificationsPlugin.cancelAll();
  }
}
