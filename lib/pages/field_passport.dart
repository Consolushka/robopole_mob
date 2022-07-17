import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class FieldPassport extends StatefulWidget {
  int id;
  FieldPassport(this.id);

  @override
  State<FieldPassport> createState() => _FieldPassportState();
}

class _FieldPassportState extends State<FieldPassport> {
  Map<int, List<LatLng>> ass = new Map<int, List<LatLng>>();

  LatLng currentLatLng = new LatLng(33,33);
  Completer<GoogleMapController> _controller = Completer();

  Future<Map<int, List<LatLng>>> fetchPost() async {

    final response =
    await http.get(Uri.parse('http://portal.robopole.ru/data/getgeobyyear/${widget.id}?year=2022'));

    if (response.statusCode == 200) {
      Map<int, List<LatLng>> p = new Map<int, List<LatLng>>();
      print(response.body);
      var coords = json.decode(response.body);

      var mapCenter = (coords["features"][0]["properties"]["mapCenter"] as String).split(",");
      var numbers = [];
      mapCenter.forEach((element) {
        var str = element.substring(1,element.length-1).replaceAll(",", ".").trim();
        numbers.add(double.parse(str));
        print(str);
      });
      
      currentLatLng = new LatLng(numbers[0], numbers[1]);


      Iterable feut = coords["features"][0]["geometry"]["coordinates"][0];
      List<LatLng> polygonCoords = [];
      feut.forEach((element) {
        polygonCoords.add(LatLng(element[1], element[0]));
      });
      ass[widget.id] = polygonCoords;
      return p;

    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState(){


    super.initState();
    Geolocator.getCurrentPosition().then((currLocation){
      setState((){
        currentLatLng = new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
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
              leading: Icon(FontAwesomeIcons.sunPlantWilt),
              title: Text("Поле"),
              backgroundColor: Colors.deepOrangeAccent,
            ),
            body: GoogleMap(
              polygons: Set<Polygon>.of([
                Polygon(
                    polygonId: PolygonId("${widget.id}"),
                    points: ass[widget.id] as List<LatLng>,
                    strokeWidth: 1,
                    strokeColor: Colors.deepOrangeAccent,
                    fillColor: Colors.amberAccent.withOpacity(0.5),
                    consumeTapEvents: true)
              ]),
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
        else{
          return Text("......");
        }
      },
    );
  }
}
