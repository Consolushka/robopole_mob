import 'package:flutter/material.dart';
import 'package:robopole_mob/classes.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoogleMaps',
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = FlutterSecureStorage();

  Future getUser() async {
    final userJson = await storage.read(key: "User");
    debugPrint(userJson);
    if(userJson != null){
      var user = User.fromJson(userJson);
      if(user.ID != 0){
        debugPrint("correct user");
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => const MapSample()), (
                route) => false);
      }
    }
    else{
      debugPrint("null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUser(),
        builder: (ctx, snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                leading: const Icon(FontAwesomeIcons.mobileScreen),
                title: const Text("РобоПоле"),
                backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),
              ),
              body: const Auth(),
            );
          }
          else{
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Align(
                alignment: Alignment.center,
                child: Icon(FontAwesomeIcons.solidSun, size: 100, color: Colors.deepOrangeAccent,),
              ),
            );
          }
        }
    );
  }
  }
