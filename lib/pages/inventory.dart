import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:robopole_mob/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/utils.dart';
import 'package:workmanager/workmanager.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  List<AgroCulture> availableCultures = [];

  String? selectedValue = null;
  List<DropdownMenuItem<String>> dropitems = [];

  final storage = const FlutterSecureStorage();
  LatLng _userLocation = const LatLng(53.31, 38.1);

  Future<LatLng> getUserLocation() async {
    Location location = Location();
    var culturesStored = await storage.read(key: "Cultures");
    String culturesJson = "";
    if (culturesStored == null) {
      var user = User.fromJson(await storage.read(key: "User") as String);
      var response = await http.get(
          Uri.parse('${Utils.uriAPI}locationCulture/get-all-cultures'),
          headers: {"Authorization": user.Token as String});
      if (response.statusCode == 200) {
        culturesJson = response.body;
        await storage.write(key: "Cultures", value: response.body);
      }
    } else {
      culturesJson = culturesStored;
    }

    availableCultures = [];
    (jsonDecode(culturesJson) as List).forEach((element) {
      availableCultures.add(AgroCulture.fromMap(element));
    });
    dropitems = [];

    for (int i = 0; i < availableCultures.length - 1; i++) {
      var element = availableCultures[i];
      if (element.ParentID == 0) {
        dropitems.add(DropdownMenuItem(
          child: Text(element.Name!), value: "${element.ID}",));
      }
    }
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return const LatLng(54.86, 38.2);
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return const LatLng(54.86, 38.2);
      }
    }

    final _locationData = await location.getLocation();
    _userLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    return LatLng(_locationData.latitude!, _locationData.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    Future<LatLng> getLocation = getUserLocation();
    return FutureBuilder(
      future: getLocation,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text("Инвентаризация"),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                          mapType: MapType.hybrid,
                          initialCameraPosition:
                          CameraPosition(target: _userLocation, zoom: 18),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [const SizedBox(height: 20,),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Выбирете культуру"),
                          ),
                          const SizedBox(height: 10,),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedValue,
                                items: dropitems,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedValue = value;
                                  });
                                },
                              ),),
                          const SizedBox(height: 20,),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Добавте комментарий"),
                          ),
                          TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (text){

                              debugPrint(text);
                            },
                          ),],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    debugPrint("confirm");
                  },
                  child: const Icon(Icons.check),
                  backgroundColor: Colors.green,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: () {
                    debugPrint("not sure");
                    Workmanager().cancelAll();
                  },
                  child: const Icon(Icons.question_mark),
                  backgroundColor: Colors.grey,
                ),
              )
            ],
          );
        } else {
          return const Text("......");
        }
      },
    );
  }
}
