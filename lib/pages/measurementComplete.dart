import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as MapTools;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:robopole_mob/utils/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/pages/measurementField.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/APIUri.dart';
import '../utils/dialogs.dart';

class MeasurementComplete extends StatefulWidget {
  Map? field;
  final List<LatLng> measurement;

  MeasurementComplete(
      {Key? key, this.field, required this.measurement})
      : super(key: key);

  @override
  State<MeasurementComplete> createState() => _MeasurementCompleteState();
}

class _MeasurementCompleteState extends State<MeasurementComplete> {
  Map<int, List<LatLng>> ass = <int, List<LatLng>>{};
  final storage = const FlutterSecureStorage();

  LatLng currentLatLng = new LatLng(33, 33);
  User? user;

  double highest = 0.0;
  double rightest = 0.0;
  double lowest = 0.0;
  double leftest = 0.0;
  Map field = Map();
  late List<LatLng> measurement;

  @override
  void initState() {
    super.initState();

    if(widget.field!=null){
      field = widget.field!;
    }

    measurement = widget.measurement;

    getPolygonCoords();
  }

  Future getUser() async{
    user = User.fromJson(await storage.read(key: "User") as String);
  }

  void getPolygonCoords() {
    highest = measurement[0].latitude;
    lowest = measurement[0].latitude;
    rightest = measurement[0].longitude;
    leftest = measurement[0].longitude;
    measurement.forEach((element) {
      if (element.latitude > highest) {
        highest = element.latitude;
      } else {
        if (element.latitude < lowest) {
          lowest = element.latitude;
        }
      }
      if (element.longitude > rightest) {
        rightest = element.longitude;
      } else {
        if (element.longitude < leftest) {
          leftest = element.longitude;
        }
      }
    });
    if(field.isEmpty){
      field["id"] = 0;
      return;
    }
    var cooooords = jsonDecode(field["coordinates"])[0];
    List<LatLng> polygonCoords = [];
    cooooords.forEach((element) {
      var c = element;
      double? lat;
      double? lng;
      if (element[0] is double) {
        lat = c[1];
        lng = c[0];
        polygonCoords.add(LatLng(c[1], c[0]));
      } else {
        c = element[0];
        lat = c[1];
        lng = c[0];
        polygonCoords.add(LatLng(c[1], c[0]));
      }
    });
    ass[field["id"]] = polygonCoords;
    currentLatLng =
        LatLng(polygonCoords[0].latitude, polygonCoords[0].longitude);
  }

  Widget FieldMap() {
    debugPrint(field["externalName"]);
    Set<Polygon> polygons = Set();
    if(field["id"]!=0){
      polygons.add(Polygon(
          polygonId: PolygonId("${field["id"]}"),
          points: ass[field["id"]] as List<LatLng>,
          strokeWidth: 1,
          strokeColor: Colors.deepOrangeAccent,
          fillColor: Colors.amberAccent.withOpacity(0.5),
          consumeTapEvents: true),);
      highest = measurement[0].latitude;
      leftest = measurement[0].longitude;
      rightest = measurement[0].longitude;
      lowest = measurement[0].latitude;
    }

    polygons.add(
        Polygon(
            polygonId: PolygonId("measure"),
            points: widget.measurement,
            strokeWidth: 1,
            strokeColor: Colors.blueAccent,
            fillColor: Colors.lightBlueAccent.withOpacity(0.5),
            consumeTapEvents: true));
    return Container(
      height: 200,
      child: GoogleMap(
          polygons: polygons,
          mapType: MapType.hybrid,
          cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              northeast: LatLng(highest, rightest),
              southwest: LatLng(lowest, leftest))),
          initialCameraPosition:
              CameraPosition(target: LatLng(54.3, 38.4), zoom: 13),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true),
    );
  }

  List<Widget> createInput(String jsonProperty, String propertyName) {
    var prop = field[jsonProperty].toString();
    if(prop == "null"){
      return List<Widget>.empty();
    }
    return [
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          propertyName,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
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
                borderSide: BorderSide(
                    color: Colors.black54.withOpacity(0.5), width: 1))),
      )
    ];
  }

  List<Widget> FieldInfo() {
    List<Widget> res = [const SizedBox(height: 20)];
    res.addAll(createInput("externalName", "Идентификатор"));
    res.addAll(createInput("partnerName", "Владелец"));
    res.addAll(createInput("usingByPartnerName", "Пользователь"));
    res.addAll(createInput("agroSize", "Площадь от агронома"));
    res.addAll(createInput("calculatedArea", "Расчитанная площадь"));
    List<MapTools.LatLng> mpCoordiantes = [];
    measurement.forEach((element) {
      mpCoordiantes.add(MapTools.LatLng(element.latitude, element.longitude));
    });
    var area = (MapTools.SphericalUtil.computeArea(mpCoordiantes) / 10000)
        .toStringAsFixed(10);
    res.addAll([
      const SizedBox(
        height: 20,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Замеренная площадь",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
      ),
      TextFormField(
        enabled: false,
        enableSuggestions: false,
        autocorrect: false,
        initialValue: area,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
            hintText: "",
            contentPadding: const EdgeInsets.all(10),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                    color: Colors.black54.withOpacity(0.5), width: 1))),
      )
    ]);
    res.add(SizedBox(
      height: 30,
    ));
    createInput("agroCultureName", "Культура").forEach((element) {
      res.add(element);
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Замер поля ${field["id"]}"),
                  backgroundColor: Colors.deepOrangeAccent,
                  actions: [IconButton(onPressed: () {Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MeasurementField(field: widget.field)),
                          (route) => false);}, icon: Icon(Icons.refresh))],
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.deepOrangeAccent,
                          ),
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "${user!.Name}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          )),
                      ListTile(
                        leading: const Icon(Icons.alt_route),
                        title: const Text('Выбор функционала'),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FunctionalPage()),
                                  (route) => false);
                        },
                      ),
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.rulerCombined),
                        title: const Text('Замер поля'),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FunctionalPage()),
                                  (route) => false);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Выйти'),
                        onTap: () async {
                          await storage.delete(key: "User");
                          await storage.delete(key: "Partners");
                          await storage.delete(key: "Fields");
                          await storage.delete(key: "Cultures");
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Auth()),
                                  (route) => false);
                        },
                      ),
                      ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Обновить данные'),
                          onTap: () async {
                            var availableFields = await http.post(
                                Uri.parse(APIUri.Field.UpdateFields),
                                headers: {
                                  HttpHeaders.authorizationHeader:
                                  user!.Token as String,
                                });

                            if (availableFields.statusCode != 200) {
                              var error = Error.fromResponse(availableFields);
                              Navigator.pop(context);
                              showErrorDialog(context, error);
                            }

                            await storage.write(
                                key: "Fields", value: availableFields.body);
                            var part = await http.get(
                                Uri.parse(APIUri.Partner.AvailablePartners),
                                headers: {
                                  HttpHeaders.authorizationHeader:
                                  user!.Token as String,
                                });
                            if (part.statusCode == 200) {
                              await storage.write(
                                  key: "Partners", value: part.body);
                            }

                            var response = await http.get(
                                Uri.parse(APIUri.Cultures.AllCultures),
                                headers: {
                                  "Authorization": user!.Token as String
                                });
                            if (response.statusCode == 200) {
                              await storage.write(
                                  key: "Cultures", value: response.body);
                            }
                            Navigator.pop(context);
                            setState(() {});
                          }),
                    ],
                  ),
                ),
                body: Stack(
                  children: [
                    Positioned(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Column(children: FieldInfo()),
                            )
                          ],
                        ),
                      ),
                    ),
                    FieldMap()
                  ],
                ));
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SpinKitRing(
                    color: Colors.deepOrangeAccent,
                    size: 100,
                  )
                ],
              ),
            );
          }
        });
  }
}
