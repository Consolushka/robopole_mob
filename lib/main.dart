import 'package:flutter/material.dart';
import 'package:robopole_mob/classes.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/utils.dart';

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
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => const FunctionalPage()), (
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
