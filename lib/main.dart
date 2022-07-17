import 'package:flutter/material.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  Future getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final int? counter = prefs.getInt('userId');
    if (counter != 0) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => const MapSample()), (
              route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future login = getUser();

    return FutureBuilder(
        future: login,
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
