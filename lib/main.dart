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
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{

  void getUser() async{
    final prefs = await SharedPreferences.getInstance();
    final int? counter = prefs.getInt('userId');
    if(counter != 0){
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => MapSample()), (route) => false);
    }
  }

  @override
  void initState(){
    getUser();
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: Icon(FontAwesomeIcons.mobileScreen),
        title: Text("РобоПоле"),
        backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),
      ),
      body: Auth(),
    );
  }
}
