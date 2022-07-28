import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:robopole_mob/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/utils.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
      var resp = await http.post(
        Uri.parse("${Utils.uriAPI}field/confirm-field-culture"),
          headers: {
            "Authorization": inputData!['token'] as String,
            "Content-Type": "application/json"
          },
          body: jsonEncode(
          {'fieldId': inputData['fieldId'], 'fieldCultureId': inputData['cultureId']})
      );
      debugPrint(resp.body);
      debugPrint("Confirmed");
      Workmanager().cancelAll();
    return Future.value(true);
  });
}

class FieldPassport extends StatefulWidget {
  int id;
  FieldPassport(this.id);

  @override
  State<FieldPassport> createState() => _FieldPassportState();
}

class _FieldPassportState extends State<FieldPassport> {
  Map<int, List<LatLng>> ass = <int, List<LatLng>>{};
  Map field = Map();
  final storage = const FlutterSecureStorage();

  LatLng currentLatLng = new LatLng(33,33);
  Completer<GoogleMapController> _controller = Completer();

  Future<Map<int, List<LatLng>>> fetchPost() async {
    var fieldsStorage = await storage.read(key: "Fields");
    var fields = jsonDecode(fieldsStorage as String) as List;
    Map<int, List<LatLng>> p = <int, List<LatLng>>{};
    for(int i=0;i<fields.length-1;i++){
      if(fields[i]["id"] ==widget.id){
        field = fields[i];
      }
    }
      var cooooords = jsonDecode(field["coordinates"])[0];
      List<LatLng> polygonCoords = [];
      cooooords.forEach((element) {
        var c = element;
        if(element[0] is double){
          polygonCoords.add(LatLng(c[1], c[0]));
        }
        else{
          c=element[0];
          polygonCoords.add(LatLng(c[1], c[0]));
        }
      });
      ass[widget.id] = polygonCoords;
      currentLatLng = LatLng(polygonCoords[0].latitude, polygonCoords[0].longitude);

      return p;
  }

  Widget FieldMap(){
    debugPrint(field["externalName"]);
    // setState((){
    //   WiFiForIoTPlugin.setEnabled(false);
    // });
    return Container(
      height: 200,
      child: GoogleMap(
          polygons: <Polygon>{
            Polygon(
                polygonId: PolygonId("${widget.id}"),
                points: ass[widget.id] as List<LatLng>,
                strokeWidth: 1,
                strokeColor: Colors.deepOrangeAccent,
                fillColor: Colors.amberAccent.withOpacity(0.5),
                consumeTapEvents: true)
          },
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(target: currentLatLng, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
          },
          zoomControlsEnabled: true
      ),);
  }

  List<Widget> createInput(String jsonProperty, String propertyName){
    var prop = field[jsonProperty].toString();

    return [
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(propertyName, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
      ),
      TextFormField(
      enabled: false,
      enableSuggestions: false,
      autocorrect: false,
      initialValue: prop,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: propertyName,
        contentPadding: const EdgeInsets.all(10),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide:
            BorderSide(color: Colors.black54.withOpacity(0.5), width: 1))
      ),
    )];
  }

  List<Widget> FieldInfo(){
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    List<Widget> res = [
      const SizedBox(height: 20)
    ];
    createInput("externalName", "Идентификатор").forEach((element) {
      res.add(element);
    });
    createInput("partnerName", "Владелец").forEach((element) {
      res.add(element);
    });
    createInput("usingByPartnerName", "Пользователь").forEach((element) {
      res.add(element);
    });
    createInput("agroSize", "Площадь от агронома").forEach((element) {
      res.add(element);
    });
    createInput("calculatedArea", "Расчитанная площадь").forEach((element) {
      res.add(element);
    });
    res.add(SizedBox(height: 30,));
    createInput("agroCultureName", "Культура").forEach((element) {
      res.add(element);
    });
    res.add(
      ElevatedButton(

          onPressed: () async {
            var user = User.fromJson(await storage.read(key: "User") as String);
            Workmanager().cancelAll();
            Workmanager().registerPeriodicTask(
                "per-task.20.25",
                "per-task.20.11-18.40",
                initialDelay: Duration(seconds: 1),
                inputData: <String, dynamic>{
                      "fieldId": widget.id,
                      "cultureId": 232,
                      "token": user.Token
                },
                constraints: Constraints(networkType: NetworkType.connected));
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.green,
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: const Text(
            "Подтвердить культуру",
            style: TextStyle(fontSize: 20),
          )),
    );
    res.add(
      SizedBox(height: 20)
    );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    Future<Map<int, List<LatLng>>> poly = fetchPost();

    return FutureBuilder(
      future: poly,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return Scaffold(
            appBar: AppBar(
              title: Text("Поле ${widget.id}"),
              backgroundColor: Colors.deepOrangeAccent,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  FieldMap(),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                        children: FieldInfo()
                    ),
                  )
                ],
              ),
            )
          );
        }
        else{
          return const Text("......");
        }
      },
    );
  }
}
