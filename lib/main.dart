import 'package:flutter/material.dart';
import 'package:robopole_mob/classes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/utils.dart';
import 'package:camera/camera.dart';
import 'package:robopole_mob/pages/auth.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {

  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  final storage = FlutterSecureStorage();

  final userJson = await storage.read(key: "User");
  debugPrint(userJson);
  if(userJson != null){
    var user = User.fromJson(userJson);
    final culturesStored = await storage.read(key: "Cultures");
    if(culturesStored == null){
      var response = await http.get(
          Uri.parse('${Utils.uriAPI}locationCulture/get-all-cultures'),
          headers: {
            "Authorization": user.Token as String
          }
      );
      if(response.statusCode == 200){
        await storage.write(key: "Cultures", value: response.body);
      }
    }
    if(user.ID != 0){
      debugPrint("correct user");
      runApp(Authed());
    }
  }
  else{
    print("null");
    runApp(NoAuthed());
  }
  // Get a specific camera from the list of available cameras.
}

class Authed extends StatelessWidget {
  const Authed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoogleMaps',
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
      title: 'GoogleMaps',
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const Auth(),
    );
  }
}