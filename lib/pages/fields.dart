import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:robopole_mob/pages/measurementSelection.dart';
import 'package:robopole_mob/utils/classes.dart';
import 'dart:convert';
import 'package:robopole_mob/main.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/utils/sofrware_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:robopole_mob/pages/passportField.dart';

import '../utils/storageUtils.dart';
import '../utils/dialogs.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedPartnerId = 0;

  int loadedFiledsPercentage = 0;
  User user = User(0, "", false, 0, "");
  Set<FieldCoords> _allPolygons = {};
  Set<Polygon> _activePolygons = {};
  List fields = [];
  List partners = [];
  List<ListTile> partnersListTiles = [];
  double highest = 0.0;
  double rightest = 0.0;
  double lowest = 0.0;
  double leftest = 0.0;

  @override
  void initState(){
    createPolygons();

    super.initState();
  }

  void filterPolygonsByPartner(int partnerId) async {
    if (partnerId == 0) {
      selectedPartnerId = 0;
    } else {
      selectedPartnerId = partnerId;
    }

    partnersListTiles = [];

    partnersListTiles.add(ListTile(
      leading: const Icon(Icons.alt_route),
      title: const Text('Выбор функционала'),
      onTap: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FunctionalPage()),
                (route) => false);
      },
    ));
    partnersListTiles.add(
      ListTile(
        leading: const Icon(FontAwesomeIcons.rulerCombined),
        title: const Text('Замер поля'),
        onTap: () async {
          showLoader(context);
          var field = await Software.FindFieldByLocation();
          if (field.isEmpty) {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const MeasurementSelection()),
                    (route) => false);
          } else {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PassportField(
                      id: field["id"],
                      isMeasurement: true,
                    )),
                    (route) => true);
          }
        },
      ),
    );
    partnersListTiles.add(ListTile(
      title: const Text("Показать все"),
      tileColor: selectedPartnerId == 0
          ? Colors.deepOrangeAccent.withOpacity(0.5)
          : null,
      onTap: () {
        filterPolygonsByPartner(0);
      },
    ));
    for (var partner in await LocalStorage.Partners()) {
      partnersListTiles.add(ListTile(
        title: Text(partner['name']),
        tileColor: partner['id'] == selectedPartnerId
            ? Colors.deepOrangeAccent.withOpacity(0.5)
            : null,
        onTap: () {
          filterPolygonsByPartner(partner['id']);
        },
      ));
    }

    _activePolygons = {};
    _allPolygons.forEach((field) {
      if(field.PartnerId==selectedPartnerId || selectedPartnerId==0){
        var color = Color(0xffffb74d);
        var zIndex = 3;
        switch(field.LayerId){
          case 1:
            color = Colors.white70;
            zIndex = 1;
            break;
          case 3:
            color = Color(0xffd50000);
            zIndex = 3;
            break;
        }
        _activePolygons.add(
            Polygon(
              polygonId: PolygonId('${field.ID}'),
              points: field.Coords,
              strokeWidth: 1,
              strokeColor: color,
              fillColor: color.withOpacity(0.5),
              consumeTapEvents: true,
              zIndex: zIndex
            )
        );
      }
    });
    setState(() {});
  }

  Future loadPartners() async {
    partnersListTiles.add(ListTile(
      leading: const Icon(Icons.alt_route),
      title: const Text('Выбор функционала'),
      onTap: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const FunctionalPage()),
            (route) => false);
      },
    ));
    partnersListTiles.add(
      ListTile(
        leading: const Icon(FontAwesomeIcons.rulerCombined),
        title: const Text('Замер поля'),
        onTap: () async {
          showLoader(context);
          var field = await Software.FindFieldByLocation();
          if (field.isEmpty) {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const MeasurementSelection()),
                (route) => false);
          } else {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PassportField(
                          id: field["id"],
                          isMeasurement: true,
                        )),
                (route) => true);
          }
        },
      ),
    );
    partnersListTiles.add(ListTile(
      title: const Text("Показать все"),
      tileColor: selectedPartnerId == 0
          ? Colors.deepOrangeAccent.withOpacity(0.5)
          : null,
      onTap: () {
        filterPolygonsByPartner(0);
      },
    ));


    for (var partner in await LocalStorage.Partners()) {
      partnersListTiles.add(ListTile(
        title: Text(partner['name']),
        tileColor: partner['id'] == selectedPartnerId
            ? Colors.deepOrangeAccent.withOpacity(0.5)
            : null,
        onTap: () {
          filterPolygonsByPartner(partner['id']);
        },
      ));
    }
  }

  Future loadFields() async {
    user = await LocalStorage.User();
    try {
      fields = await LocalStorage.Fields();
    } catch (ex) {
      showErrorDialog(context, ex.toString());
    }
  }

  void createPolygons() async {
    if (partnersListTiles.length <= 2) {
      await loadPartners();
    }

    if (_allPolygons.isEmpty) {
      await loadFields();
    }
    Set<FieldCoords> localPolygons = {};

    for (int i = 0; i < fields.length; i++) {
      var field = fields[i];
      try {
        var utfed = field["coordinates"];
        var cors = jsonDecode(utfed) as List;
        var cooooords = cors[0];
        if(cooooords.length==1){
          cooooords = cooooords[0];
        }
        List<LatLng> polygonCoords = [];
        cooooords.forEach((element) {
          var c = element;
          if (element[0] is double) {
            polygonCoords.add(LatLng(c[1], c[0]));
          } else {
            c = element[0];
            polygonCoords.add(LatLng(c[1], c[0]));
          }
        });

        var fieldCoord = new FieldCoords(field["id"], field["partnerID"], field["layerID"], polygonCoords);
        switch(field["layerID"]){
          case 1:
            fieldCoord.Coords.add(fieldCoord.Coords[0]);
            localPolygons.add(fieldCoord);
            _activePolygons.add(Polygon(
              polygonId: PolygonId('${field["id"]}'),
              points: polygonCoords,
              strokeWidth: 1,
              strokeColor: Colors.white60,
              fillColor: Colors.white60.withOpacity(0.5),
              consumeTapEvents: true,
              zIndex: 1
            ));
            break;
          case 2:
            localPolygons.add(fieldCoord);
            _activePolygons.add(Polygon(
                polygonId: PolygonId('${field["id"]}'),
                points: polygonCoords,
                strokeWidth: 1,
                strokeColor: Color(0xffffb74d),
                fillColor: Color(0xffffb74d).withOpacity(0.5),
                consumeTapEvents: true,
                zIndex: 3,
                onTap: () {
                  Navigator.of(context).push(_createRoute(field["id"]));
                }));
            break;
          case 3:
            localPolygons.add(fieldCoord);
            _activePolygons.add(Polygon(
                polygonId: PolygonId('${field["id"]}'),
                points: polygonCoords,
                strokeWidth: 1,
                strokeColor: Colors.red,
                fillColor: Colors.red.withOpacity(0.5),
                consumeTapEvents: true,
                zIndex: 2
            ));
            break;
          default:
            continue;
        }
      } catch (e) {
        debugPrint("Caused error with field ${field["id"]}. ${e.toString()}");
      }
    }
    //TODO: ON RELOADING BY PARTNERS - ADD LISTENER ON CLICK
    setState(() {
      _allPolygons = localPolygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_allPolygons.isEmpty){
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Робополе 2022"),
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
                )),
            Column(
              children: List.unmodifiable(partnersListTiles),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: () async {
                await LocalStorage.ClearAll();
                partners = [];
                fields = [];
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NoAuthed()),
                        (route) => false);
              },
            ),
            ListTile(
                leading: Icon(Icons.restore_from_trash),
                title: Text('Обновить данные'),
                onTap: () async {
                  partnersListTiles = [];
                  _allPolygons = {};
                  partners = [];
                  fields = [];
                  showLoader(context);
                  await LocalStorage.RestoreData();
                  Navigator.pop(context);
                  setState(() {});
                }),
          ],
        ),
      ),
      body: GoogleMap(
        polygons: _activePolygons,
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
}

Route _createRoute(int id) {
  return PageRouteBuilder(
    pageBuilder: (BuildContext context,
        Animation<double> animation, //
        Animation<double> secondaryAnimation) {
      return PassportField(id: id);
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation, //
        Animation<double> secondaryAnimation,
        Widget child) {
      return child;
    },
  );
}
