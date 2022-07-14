import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geojson/geojson.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:robopole_mob/pages/field_passport.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController _mapController;
  Set<Polygon> _polygons = {};
  List<int> fields = [920, 1390, 1907,1909,1911,1912,1913,1914,1915,1917,1918,1919,1923,1924,1925,1926,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1956,1957,1958,1960,1962,1964,1969,1971,1973,1974,1976,1977,1982,1984,1985,1991,1996,1997,1998,2001,2002,2004,2005,2008,2009,2010,2015,2018,2024,2025,2026,2027,2029,2030,2031,2032,2033,2045,2086,2087,2088,2089,2091,2092,2098,2101,2103,2105,2116,2122,2123,2124,2125,2130,2136,2137,2138,2139,2140,2141,2142,2143,2144,2146,2147,2150,2151,2153,2168,2171, 944];

  Future<Set<Polygon>> loadFields() async{
    for(int i=0;i<fields.length;i++){
      var fieldId = fields[i];
      final response =
      await http.get(Uri.parse(
          'http://portal.robopole.ru/data/getgeobyyear/$fieldId?year=2022'));

      if (response.statusCode == 200) {
        print("Response status: ${response.statusCode}");
        var coords = json.decode(response.body);
        try{
          Iterable feut = coords["features"][0]["geometry"]["coordinates"][0];
          List<LatLng> polygonCoords = [];
          feut.forEach((element) {
            polygonCoords.add(LatLng(element[1], element[0]));
          });
          _polygons.add(Polygon(
              polygonId: PolygonId('$fieldId'),
              points: polygonCoords,
              strokeWidth: 1,
              strokeColor: Colors.deepOrangeAccent,
              fillColor: Colors.amberAccent.withOpacity(0.5),
              consumeTapEvents: true,
              onTap: () {
                Navigator.of(context).push(_createRoute(fieldId));
              }));
        }
        catch(e){
          continue;
        }
      }
      else{
        throw Exception("ex");
      }
    }

    return _polygons;
  }

  @override
  Widget build(BuildContext context) {
    Future<Set<Polygon>> polys = loadFields();


    return FutureBuilder(
      future: polys,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return GoogleMap(
            polygons: _polygons,
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("LOADING")
            ],
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(leading: Icon(FontAwesomeIcons.mobileScreen), title: Text("Робополе" ), backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),),
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        initialCameraPosition: const CameraPosition(
          target: LatLng(54.8561, 38.2930),
          zoom: 12.0,
        ),
        onMapCreated: (GoogleMapController googleMapController) {
          setState(() {

          });
        },
        polygons: _polygons,
      ),
    );
  }
}

Route _createRoute(int id) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context,
        Animation<double> animation, //
        Animation<double> secondaryAnimation) {
      return FieldPassport(id);
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation, //
        Animation<double> secondaryAnimation,
        Widget child) {
      return child;
    },
  );
}
