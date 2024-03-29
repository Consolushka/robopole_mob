import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:robopole_mob/pages/measurementField.dart';
import 'package:robopole_mob/pages/measurementSelection.dart';
import 'package:robopole_mob/utils/storageUtils.dart';

class PassportField extends StatefulWidget {
  int id;
  bool? isMeasurement;
  PassportField({Key? key, required this.id, this.isMeasurement}) : super(key: key);

  @override
  State<PassportField> createState() => _PassportFieldState();
}

class _PassportFieldState extends State<PassportField> {
  Map<int, List<LatLng>> ass = <int, List<LatLng>>{};
  Map field = Map();

  LatLng currentLatLng = new LatLng(33,33);
  Completer<GoogleMapController> _controller = Completer();

  double highest = 0.0;
  double rightest = 0.0;
  double lowest = 0.0;
  double leftest = 0.0;

  List<Widget> appBarActions(){
    List<Widget> result = [];
    widget.isMeasurement = widget.isMeasurement==null?false:widget.isMeasurement;
    if(widget.isMeasurement!){
      result.add(IconButton(
        icon: const Icon(FontAwesomeIcons.magnifyingGlass),
        tooltip: 'Выбор поля',
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MeasurementSelection()),
                  (route) => true);
        },
      ));
    }
    result.add(IconButton(
      icon: const Icon(FontAwesomeIcons.rulerCombined),
      tooltip: 'Замер поля',
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MeasurementField(field: field)),
                (route) => true);
      },
    ));

    return result;
  }

  Future<Map<int, List<LatLng>>> fetchPost() async {
    var fields = await LocalStorage.Fields();
    Map<int, List<LatLng>> p = <int, List<LatLng>>{};
    for(int i=0;i<fields.length;i++){
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
                    actions: appBarActions(),
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
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [SpinKitRing(
                color: Colors.deepOrangeAccent,
                size: 100,
              )],

            ),
          );
        }
      },
    );
  }
}
