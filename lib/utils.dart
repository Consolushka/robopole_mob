import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


// String APIHost = "http://devapi.robopole.ru";
String APIHost = "http://192.168.1.10:7196";
String APIVersion = "/v1";
String UserController = "/user";
String PartnerController = "/partner";
String FieldController = "/field";
String InventoryController ="/locationinventory";

class APIUri{
  static _UserController User= _UserController();
  static _PartnerController Partner = _PartnerController();
  static _FieldController Field = _FieldController();
  static _InventoryController Inventory = _InventoryController();
}

class _UserController{
  static String route = "$APIHost$APIVersion$UserController";
  String Authenticate = "$route/authenticate";
}

class _PartnerController{
  static String route = "$APIHost$APIVersion$PartnerController";
  String AvailablePartners = "$route/get-available-partners";
}

class _FieldController{
  static String route = "$APIHost$APIVersion$FieldController";
  String AvailableFields = "$route/get-available-fieldsCoords-byUser";
  // static String FieldData = "$route/"
}

class _InventoryController{
  static String route = "$APIHost$APIVersion$InventoryController";
  String AllCultures = "$route/get-all-cultures";
  String SavePhotos = "$route/save-photos";
  String SaveAudio = "$route/save-audio";
  String AddInventory = "$route/add-inventory";
}

class NotificationService {
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

  AndroidNotificationDetails _androidNotificationDetails =
  AndroidNotificationDetails(
    'channel ID',
    'channel name',
    channelDescription: 'channel description',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotifications(message) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      "Робополе",
      message,
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  Future<void> scheduleNotifications() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Notification Title",
        "This is the Notification Body!",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        NotificationDetails(android: _androidNotificationDetails),
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