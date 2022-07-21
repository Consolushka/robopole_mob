import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:robopole_mob/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/utils.dart';

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
    var user = User.fromJson(await storage.read(key: "User") as String);

    final response =await http.get(
        Uri.parse("${Utils.uriAPI}field/get-field-data?fieldId=${widget.id.toString()}&year=2022"),
        headers: {
          "Authorization": user.Token as String,
        }
    );
    if (response.statusCode == 200) {
      Map<int, List<LatLng>> p = <int, List<LatLng>>{};
      print(response.body);
      var coords = json.decode(response.body);
      field = coords;

      var mapCenter = (coords["mapCenter"] as String).split(",");
      var numbers = [];
      mapCenter.forEach((element) {
        var str = element.substring(1,element.length-1).replaceAll(",", ".").trim();
        numbers.add(double.parse(str));
        print(str);
      });
      
      currentLatLng = new LatLng(numbers[0], numbers[1]);
      var cooooords = jsonDecode(coords["coordinates"])[0];
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
      return p;

    } else {
      // If that call was not successful, throw an error.

      print(response.body);
      throw Exception("asdasd");
    }
  }

  Widget FieldMap(){
    debugPrint(field["externalName"]);

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

  List<Widget> FieldInfo(){
    return [
      TextFormField(
        enabled: false,
        enableSuggestions: false,
        autocorrect: false,
        initialValue: utf8.decode(field["externalName"]),
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          hintText: 'Идентификатор',
          contentPadding: const EdgeInsets.all(10),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide:
              const BorderSide(color: Colors.black54, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                  color: Colors.deepOrangeAccent.withOpacity(0.5),
                  width: 2)),
        ),
      )
    ];
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
            body: Column(
              children: [
                FieldMap(),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Идентификатор", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: const TextStyle(fontSize: 20),
                        enabled: false,
                        initialValue: field["externalName"],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                              const BorderSide(color: Colors.black54, width: 2)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Colors.deepOrangeAccent.withOpacity(0.5),
                                  width: 2)),
                        ),
                      )
                    ],
                  ),
                )
              ],
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
