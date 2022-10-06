import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'classes.dart';


String APIHost = "http://devapi.robopole.ru";
// String APIHost = "http://192.168.1.10:7196";

String APIVersion = "/v1";
String UserController = "/user";
String PartnerController = "/partner";
String FieldController = "/field";
String InventoryController ="/locationinventory";
String FieldInspectionController = "/fieldinspection";
String ContentController = "/content";

class APIUri{
  static _UserController User= _UserController();
  static _PartnerController Partner = _PartnerController();
  static _FieldController Field = _FieldController();
  static _InventoryController Inventory = _InventoryController();
  static _FieldInspectionController Inspection = _FieldInspectionController();
  static _ContentController Content = _ContentController();
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
  String UpdateFields = "$route/update-fieldsCoords-byUser";
  // static String FieldData = "$route/"
}

class _InventoryController{
  static String route = "$APIHost$APIVersion$InventoryController";
  String AllCultures = "$route/get-all-cultures";
  String AddInventory = "$route/add-inventory";
}

class _FieldInspectionController{
  static String route = "$APIHost$APIVersion$FieldInspectionController";
  String AddInspection = "$route/add-inspection";
}

class _ContentController{
  static String route = "$APIHost$APIVersion$ContentController";
  String SavePhotos = "$route/save-photos";
  String SaveAudio = "$route/save-audio";
  String SaveVideos = "$route/save-videos";
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

Future<List> getFieldsFromStorage() async {
  final storage = const FlutterSecureStorage();
  var fieldsStorage = await storage.read(key: "Fields");
  var fields = jsonDecode(fieldsStorage as String) as List;
  return fields;
}

Future<List> requestForFields() async {
  final storage = const FlutterSecureStorage();
  var user = User.fromJson(await storage.read(key: "User") as String);

  var fieldsStorage = await storage.read(key: "Fields");
  String fieldsJson = "";

  if(fieldsStorage == null){
    debugPrint("empty storage");
    var availableFields = await http.get(
        Uri.parse(APIUri.Field.AvailableFields),
        headers: {
          HttpHeaders.authorizationHeader: user.Token as String,
        }
    );

    if(availableFields.statusCode != 200){
      var error = Error.fromResponse(availableFields);
      throw Exception(error);
    }

    fieldsJson = availableFields.body;
    await storage.write(key: "Fields", value: fieldsJson);
  }
  else{
    fieldsJson = fieldsStorage;
  }

  return jsonDecode(fieldsJson) as List;
}

void showLoader(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SpinKitRing(
            color: Colors.deepOrangeAccent,
            size: 100,
          )
        ],
      );
    },
  );
}



void showErrorDialog(context, errorMessage) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Ошибка"),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: const Text("Ok"))
        ],
      ));
}

void showOKDialog(context, message, setState) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("$message"),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState();
              },
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: const Text("Ok"))
        ],
      ));
}