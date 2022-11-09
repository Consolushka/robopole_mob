import 'package:flutter/material.dart';
import 'package:robopole_mob/utils/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:camera/camera.dart';
import 'package:robopole_mob/pages/auth.dart';

import 'utils/notifications.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {

  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();

  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  final storage = FlutterSecureStorage();

  final userJson = await storage.read(key: "User");
  debugPrint(userJson);
  if(userJson != null){
    var user = User.fromJson(userJson);
    if(user.ID != 0){
      debugPrint("correct user");
      runApp(Authed());
    }
  }
  else{
    runApp(NoAuthed());
  }
  // Get a specific camera from the list of available cameras.
}

class Authed extends StatelessWidget {
  const Authed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Робополе',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const FunctionalPage(),
    );
  }
}

class NoAuthed extends StatelessWidget {
  const NoAuthed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Робополе',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const Auth(),
    );
  }
}