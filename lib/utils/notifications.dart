import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static AndroidNotificationDetails Inventory = AndroidNotificationDetails(
    '1',
    'Инвентаризация',
    channelDescription: 'Канал уведомлений для инвентаризации',
    playSound: true,
  );

  static AndroidNotificationDetails Inspection = AndroidNotificationDetails(
    '2',
    'Осмотр поля',
    channelDescription: 'Канал уведомлений для осмотра полей',
    playSound: true,
  );

  static AndroidNotificationDetails Measurement = AndroidNotificationDetails(
    '3',
    'Замер полей',
    channelDescription: 'Канал уведомлений для замера полей',
    playSound: true,
  );

  //NotificationService a singleton object
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static const channelId = '123';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future<void> showNotifications(message, AndroidNotificationDetails details) async {
    var id =DateTime.now().millisecondsSinceEpoch-1668000000000;
    await flutterLocalNotificationsPlugin.show(
      id,
      details.channelName,
      message,
      NotificationDetails(android: details),
    );
  }

  Future<void> scheduleNotifications() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Notification Title",
        "This is the Notification Body!",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        NotificationDetails(android: Inventory),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

void selectNotification(String? payload) async {
  //handle your logic here
}
