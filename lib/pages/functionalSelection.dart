import 'package:flutter/material.dart';
import 'package:robopole_mob/pages/InspectionField.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:robopole_mob/pages/inventory.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:robopole_mob/pages/measurementSelection.dart';
import 'package:robopole_mob/pages/passportField.dart';
import 'package:robopole_mob/utils/sofrware_handler.dart';

import '../utils/dialogs.dart';

class FunctionalPage extends StatefulWidget {
  const FunctionalPage({Key? key}) : super(key: key);

  @override
  State<FunctionalPage> createState() => _FunctionalPageState();
}

class _FunctionalPageState extends State<FunctionalPage> {

  @override
  void initState(){
    initLocation();
    super.initState();
  }

  Future initLocation() async {
    var locationPermission = await PH.Permission.location.status;
    if(locationPermission.isDenied){
      final status = await PH.Permission.location.request();
      debugPrint(status.toString());
      if (status != PH.PermissionStatus.granted) {
        throw 'Location permission not granted';
      }
    }

    var notificationPermission = await PH.Permission.location.status;
    if(notificationPermission.isDenied){
      final status = await PH.Permission.location.request();
      debugPrint(status.toString());
      // if (status != PH.PermissionStatus.granted) {
      //   throw ' permission not granted';
      // }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
          appBar: AppBar(
            title: const Text("Робополе 2023"),
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
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                      height: 160,
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
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                        height: 160,
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
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(3));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                        height: 160,
                        width: 300,
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: const [
                            Icon(FontAwesomeIcons.mapLocationDot, size: 50,color: Colors.black54,),
                            SizedBox(width: 20,),
                            Text(
                              "Осмотр поля",
                              style: TextStyle(fontSize: 26,color: Colors.black54),
                            )
                          ],
                        )
                    )),
                ElevatedButton(
                    onPressed: () async{
                      showLoader(context);
                      var field = await Software.FindFieldByLocation();
                      if(field.isEmpty){
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MeasurementSelection()),
                                (route) => false);
                      }
                      else{
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PassportField(id: field["id"], isMeasurement: true,)),
                                (route) => true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Container(
                        height: 160,
                        width: 300,
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          children: const [
                            Icon(FontAwesomeIcons.rulerCombined, size: 50,color: Colors.black54,),
                            SizedBox(width: 20,),
                            Text(
                              "Замер поля",
                              style: TextStyle(fontSize: 26,color: Colors.black54),
                            )
                          ],
                        )
                    )),
              ],
            ),
          ),
        );
  }
}

Route _createRoute(int functionalId) {
  switch(functionalId){
    case 1:
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
    case 2:
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
    case 3:
      return PageRouteBuilder(
        pageBuilder: (BuildContext context,
            Animation<double> animation, //
            Animation<double> secondaryAnimation) {
          return const InspectionField();
        },
        transitionsBuilder: (BuildContext context,
            Animation<double> animation, //
            Animation<double> secondaryAnimation,
            Widget child) {
          return child;
        },
      );
    default:
      return PageRouteBuilder(
        pageBuilder: (BuildContext context,
            Animation<double> animation, //
            Animation<double> secondaryAnimation) {
          return const MeasurementSelection();
        },
        transitionsBuilder: (BuildContext context,
            Animation<double> animation, //
            Animation<double> secondaryAnimation,
            Widget child) {
          return child;
        },
      );

  }
}
