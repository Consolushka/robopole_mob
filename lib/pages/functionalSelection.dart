import 'package:flutter/material.dart';
import 'package:robopole_mob/main.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:robopole_mob/pages/inventory.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart' as PH;

class FunctionalPage extends StatefulWidget {
  const FunctionalPage({Key? key}) : super(key: key);

  @override
  State<FunctionalPage> createState() => _FunctionalPageState();
}

class _FunctionalPageState extends State<FunctionalPage> {
  final storage = FlutterSecureStorage();

  @override
  void initState(){
    initLocation();
    super.initState();
  }

  Future initLocation() async {
    var check = await PH.Permission.location.status;
    if(check.isDenied){
      final status = await PH.Permission.location.request();
      debugPrint(status.toString());
      if (status != PH.PermissionStatus.granted) {
        throw 'Microphone permission not granted';
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          appBar: AppBar(
            title: const Text("Робополе 2022"),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          body: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(2));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                      height: 180,
                        width: 300,
                        padding: EdgeInsets.only(left: 20),
                      child: Row(
                        children: const [
                          Icon(Icons.add_business, size: 50,color: Colors.black54,),
                          SizedBox(width: 20,),
                          Text(
                            "Инвентаризация",
                            style: TextStyle(fontSize: 26,color: Colors.black54),
                          )
                        ],
                      )
                    )),
                ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(1));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                        height: 180,
                        width: 300,
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, size: 50,color: Colors.black54,),
                            SizedBox(width: 20,),
                            Text(
                              "Информация",
                              style: TextStyle(fontSize: 26,color: Colors.black54),
                            )
                          ],
                        )
                    )),
                ElevatedButton(
                    onPressed: ()async {
                      await storage.delete(key: "User");
                      await storage.delete(key: "Partners");
                      await storage.delete(key: "Fields");
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => const NoAuthed()), (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                        height: 180,
                        width: 300,
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: const [
                            Icon(Icons.logout, size: 50,color: Colors.black54,),
                            SizedBox(width: 20,),
                            Text(
                              "Выйти",
                              style: TextStyle(fontSize: 26,color: Colors.black54),
                            )
                          ],
                        )
                    ))
              ],
            ),
          ),
        );
  }
}

Route _createRoute(int functionalId) {
  if(functionalId == 1){
    return PageRouteBuilder(
      pageBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation) {
        return const MapSample();
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation,
          Widget child) {
        return child;
      },
    );
  }
  else{
    return PageRouteBuilder(
      pageBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation) {
        return const Inventory();
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation,
          Widget child) {
        return child;
      },
    );
  }
  switch(functionalId){
    case 1:
  }
}
