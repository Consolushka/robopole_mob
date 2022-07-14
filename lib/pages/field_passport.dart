import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FieldPassport extends StatefulWidget {
  int id;
  FieldPassport(this.id);

  @override
  State<FieldPassport> createState() => _FieldPassportState();
}

class _FieldPassportState extends State<FieldPassport> {
  List<Polygon> _polygons = [];
  Map<int, List<LatLng>> ass = new Map<int, List<LatLng>>();
  bool loading = true;
  bool hasError = false;

  Future<Map<int, List<LatLng>>> fetchPost() async {
    final response =
    await http.get(Uri.parse('http://portal.robopole.ru/data/getgeobyyear/${widget.id}?year=2022'));

    if (response.statusCode == 200) {
      Map<int, List<LatLng>> p = new Map<int, List<LatLng>>();
      print(response.body);
      var coords = json.decode(response.body);
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
  Widget build(BuildContext context) {
    Future<Map<int, List<LatLng>>> poly = fetchPost();

    return FutureBuilder(
      future: poly,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return GoogleMap(
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
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(54.8561, 38.2930),
              zoom: 10.0,
            ),
          );
        }
        else{
          return Text("......");
        }
      },
    );
      return GoogleMap(
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
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(54.8561, 38.2930),
                    zoom: 10.0,
                  ),
                );
  }

  @override
  void initState() {
    fetchPost();
  }
  //   return GoogleMap(
  //               polygons: Set<Polygon>.of(_polygons),
  //               mapType: MapType.hybrid,
  //               myLocationEnabled: true,
  //               myLocationButtonEnabled: true,
  //               zoomControlsEnabled: true,
  //               initialCameraPosition: const CameraPosition(
  //                 target: LatLng(54.8561, 38.2930),
  //                 zoom: 10.0,
  //               ),
  //             );
  // }
}


// class FieldPassport extends StatelessWidget {
//   FieldPassport(this.id);
//
//   final int id;
//   Set<Polygon> _polygons = {};
//
//   Widget build(BuildContext context) {
//     http.get(Uri.parse('http://portal.robopole.ru/data/getgeobyyear/$id?year=2022')).then((response) {
//       print("Response status: ${response.statusCode}");
//       var coords = json.decode(response.body);
//       Iterable feut = coords["features"][0]["geometry"]["coordinates"][0];
//       List<LatLng> polygonCoords = [];
//       feut.forEach((element) {
//         polygonCoords.add(LatLng(element[1], element[0]));
//       });
//       _polygons.add(Polygon(
//           polygonId: PolygonId('$id'),
//           points: polygonCoords,
//           strokeWidth: 1,
//           strokeColor: Colors.deepOrangeAccent,
//           fillColor: Colors.amberAccent.withOpacity(0.5),
//           consumeTapEvents: true));
//     }).catchError((error){
//       print("Error: $error");
//     });
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Паспорт поля ${this.id}"),
//           backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),
//         ),
//         body: Column(
//           children: [
//             Container(
//               child: GoogleMap(
//                 polygons: _polygons,
//                 mapType: MapType.hybrid,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 zoomControlsEnabled: true,
//                 initialCameraPosition: const CameraPosition(
//                   target: LatLng(54.8561, 38.2930),
//                   zoom: 10.0,
//                 ),
//               ),
//               height: 200,
//             )
//           ],
//         )
//     );
//   }
// }
