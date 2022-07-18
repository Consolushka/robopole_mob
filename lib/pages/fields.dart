import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:robopole_mob/classes.dart';
import 'dart:convert';
import 'package:robopole_mob/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:robopole_mob/pages/field_passport.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int loadedFiledsPercentage = 0;
  User user = User.fromJson("");
  Set<Polygon> _polygons = {};
  List<int> fields = [920, 1390, 1907,1909,1911,1912,1913,1914,1915,1917,1918,1919,1923,1924,1925,1926,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,1952,1953,1954,1956,1957,1958,1960,1962,1964,1969,1971,1973,1974,1976,1977,1982,1984,1985,1991,1996,1997,1998,2001,2002,2004,2005,2008,2009,2010,2015,2018,2024,2025,2026,2027,2029,2030,2031,2032,2033,2045,2086,2087,2088,2089,2091,2092,2098,2101,2103,2105,2116,2122,2123,2124,2125,2130,2136,2137,2138,2139,2140,2141,2142,2143,2144,2146,2147,2150,2151,2153,2168,2171, 944];
  List<ListTile> partners = [];

  Future<Set<Polygon>> loadFields() async{
    final prefs = await SharedPreferences.getInstance();
    final String userJson = prefs.getString('user') as String;
    final List<Partner> parts =[Partner(1, "Озеры"),Partner(2, "Городище"), Partner(3, "СПК")];

    user = User.fromJson(userJson);
    partners = [];
    parts.forEach((element) {
      partners.add(ListTile(
        title: Text(element.Name),
      ));
    });
    print(user.toJson());

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

    print(_polygons.length);
    print(partners.length);
    return _polygons;
  }

  @override
  Widget build(BuildContext context) {
    Future<Set<Polygon>> polys = loadFields();


    return FutureBuilder(
      future: polys,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          // return Test();
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: ()=> _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text("Робополе 2022"),
              backgroundColor: Colors.deepOrangeAccent,
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
                       '${user.Name}',
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 24,
                       ),
                     ),
                    )
                  ),
                  Column(
                    children: List.unmodifiable(partners),
                  ),

                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Выйти'),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt("userId", 0);
                      final int? counter = prefs.getInt('userId');
                      print(counter);
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => const Home()), (route) => false);
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ],
              ),
            ),
            body: GoogleMap(
              polygons: _polygons,
              mapType: MapType.hybrid,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: LatLng(54.8561, 38.2930),
                zoom: 10.0,
              ),
            ),
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
