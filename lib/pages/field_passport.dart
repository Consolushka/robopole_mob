import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  double highest = 0.0;
  double rightest = 0.0;
  double lowest = 0.0;
  double leftest = 0.0;

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
        double? lat;
        double? lng;
        if(element[0] is double){
          lat = c[1];
          lng = c[0];
          polygonCoords.add(LatLng(c[1], c[0]));
        }
        else{
          c=element[0];
          lat = c[1];
          lng = c[0];
          polygonCoords.add(LatLng(c[1], c[0]));
        }
        if(polygonCoords.length==1){
          highest = lat!;
          lowest = lat;
          rightest = lng!;
          leftest = lng;
        }
        if(lat!>highest){
          highest = lat;
        }
        else{
          if(lat<lowest){
            lowest = lat;
          }
        }
        if(lng!>rightest){
          rightest = lng;
        }
        else{
          if(lng<leftest){
            leftest = lng;
          }
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
          cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                  northeast: LatLng(highest, rightest),
                  southwest: LatLng(lowest, leftest)
              )
          ),
          initialCameraPosition: CameraPosition(target: LatLng(54.3, 38.4), zoom: 13),
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
    // res.add(
    //   ElevatedButton(
    //       onPressed: () async {
    //       },
    //       style: ElevatedButton.styleFrom(
    //           primary: Colors.green,
    //           padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(30))),
    //       child: const Text(
    //         "Подтвердить культуру",
    //         style: TextStyle(fontSize: 20),
    //       )),
    // );
    // res.add(
    //   SizedBox(height: 20)
    // );
    return res;
  }

  @override
  Widget build(BuildContext context) {
    Future<Map<int, List<LatLng>>> poly = fetchPost();

    return FutureBuilder(
      future: poly,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return
              Scaffold(
                  appBar: AppBar(
                    title: Text("Поле ${widget.id}"),
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  body: Stack(
                    children: [
                      Positioned(
                        child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 200,),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                  children: FieldInfo()
                              ),
                            )
                          ],
                        ),
                      ),
                      ),
                      FieldMap()
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
