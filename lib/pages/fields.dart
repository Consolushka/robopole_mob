import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:robopole_mob/classes.dart';
import 'dart:convert';
import 'package:robopole_mob/main.dart';
import 'package:robopole_mob/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:robopole_mob/pages/field_passport.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = FlutterSecureStorage();
  int loadedFiledsPercentage = 0;
  User user = User(0,"",false,0,"");
  Set<Polygon> _polygons = {};
  List fields = [];
  List<ListTile> partnersListTiles = [];

  void showError(Error error){
    showDialog(
        context: context,
        builder: (BuildContext context)=>AlertDialog(
          title: const Text("Ошибка"),
          content: Text(error.Message as String),
          actions: [
            ElevatedButton(
                onPressed: ()=>Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    primary: Colors.red
                ),
                child: const Text("Ok"))
          ],
        )
    );
  }

  Future<Set<Polygon>> loadFields() async{
    var partnersStorage = await storage.read(key: "Partners");
    String partnersJson = "";
    user = User.fromJson(await storage.read(key: "User") as String);

    if(partnersStorage == null){
      var part = await http.get(
          Uri.parse("${Utils.uriAPI}partner/availablepartners"),
          headers: {
            HttpHeaders.authorizationHeader: user.Token as String,
          });
      if(part.statusCode==200){
        partnersJson = part.body;
        await storage.write(key: "Partners", value: part.body);
      }
      else{
        var error = Error.fromResponse(part);
        showError(error);
        return _polygons;
      }
    }
    else{
      partnersJson = partnersStorage;
    }


    var decodedPartners = jsonDecode(partnersJson) as List;
    partnersListTiles = [];
    decodedPartners.forEach((partner) {
      partnersListTiles.add(ListTile(
        title: Text(partner['name']),
        onTap: (){
          debugPrint(partner['id']);
        },
      ));
    });

    debugPrint(user.Token);
    
    var availableFields = await http.get(
        Uri.parse("${Utils.uriAPI}field/fieldsCoordinatesByUser"),
        headers: {
          HttpHeaders.authorizationHeader: user.Token as String,
        }
    );

    if(availableFields.statusCode != 200){
      var error = Error.fromResponse(availableFields);
      showError(error);
      return _polygons;
    }

    fields = jsonDecode(availableFields.body) as List;

    for(int i=0;i<fields.length;i++){
      var field = fields[i];
      try{
        var utfed = field["coordinates"];
        var cors = jsonDecode(utfed) as List;
        var cooooords = cors[0];
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
        _polygons.add(Polygon(
            polygonId: PolygonId('${field["fieldId"]}'),
            points: polygonCoords,
            strokeWidth: 1,
            strokeColor: Colors.deepOrangeAccent,
            fillColor: Colors.amberAccent.withOpacity(0.5),
            consumeTapEvents: true,
            onTap: () {
              Navigator.of(context).push(_createRoute(field));
            }));
        print("object");
      }
      catch(e){
        print(e.toString());
      }
    }

    print(_polygons.length);
    print(partnersListTiles.length);
    return _polygons;
  }

  @override
  Widget build(BuildContext context) {
    Future<Set<Polygon>> polys = loadFields();


    return FutureBuilder(
      future: polys,
      builder: (ctx, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return SafeArea(
              child: Scaffold(
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
                        children: List.unmodifiable(partnersListTiles),
                      ),

                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Выйти'),
                        onTap: () async {
                          await storage.delete(key: "User");
                          await storage.delete(key: "Partners");
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
