import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:robopole_mob/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/utils.dart';
import 'package:robopole_mob/pages/camera_preview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:workmanager/workmanager.dart';

String? selValue = null;
String comment = "";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var userToken = inputData!["UserToken"] as String;
    var decodedMap = jsonDecode(inputData["Inventory"]);

    var inv = LocationInventory.fromJson(decodedMap);
    List<String> imagesPaths = inputData["Images"].cast<String>();
    if(imagesPaths.isNotEmpty){
      var request = http.MultipartRequest('POST', Uri.parse(APIUri.Inventory.SavePhotos));
      request.headers.addAll({"Authorization":  userToken});
      for(var image in imagesPaths){
        request.files.add(await http.MultipartFile.fromPath('picture', image));
      }

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      final body = (json.decode(responsed.body) as List<dynamic>).cast<String>();
      inv.PhotosNames = body;
    }
    var jsoned = json.encode(inv);

    var response = await http.post(
        Uri.parse(APIUri.Inventory.AddInventory),
        headers: {
          "Content-Type": "application/json",
          "Authorization": userToken
        },
        body: jsoned);

    if(response.statusCode == 200){
      return Future.value(true);
    }
    else{
      return Future.value(false);
      // var error = Error.fromResponse(response);
      // var errorMessage = "${error.Message} при обращаении к ${error.Path}";
      // showErrorDialog(errorMessage);
    }
    Workmanager().cancelAll();
    return Future.value(true);
  });
}

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late bool _locationServiceEnabled;
  late PermissionStatus _locationPermissionGranted;
  User? user;

  List<AgroCulture> availableCultures = [];

  String? selectedValue = null;
  List<DropdownMenuItem<String>> dropitems = [];

  final storage = const FlutterSecureStorage();
  LatLng _userLocation = const LatLng(53.31, 38.1);

  Future<LatLng> getUserLocation() async {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    Location location = Location();
    var culturesStored = await storage.read(key: "Cultures");
    String culturesJson = "";
    user = User.fromJson(await storage.read(key: "User") as String);
    if (culturesStored == null) {
      var response = await http.get(
          Uri.parse(APIUri.Inventory.AllCultures),
          headers: {"Authorization": user!.Token as String});
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
          child: Text(element.Name!),
          value: "${element.ID}",
        ));
      }
    }
    // Check if location service is enable
    _locationServiceEnabled = await location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await location.requestService();
      if (!_locationServiceEnabled) {
        return const LatLng(54.86, 38.2);
      }
    }

    // Check if permission is granted
    _locationPermissionGranted = await location.hasPermission();
    if (_locationPermissionGranted == PermissionStatus.denied) {
      _locationPermissionGranted = await location.requestPermission();
      if (_locationPermissionGranted != PermissionStatus.granted) {
        return const LatLng(54.86, 38.2);
      }
    }

    final _locationData = await location.getLocation();
    _userLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    return LatLng(_locationData.latitude!, _locationData.longitude!);
  }

  Widget findImage() {
    List<Container> images = [];
    for (int i = 0; i < imagePaths.length; i++) {
      images.add(Container(
        height: 75,
        width: 75,
        child: Image.file(File(imagePaths[i])),
      ));
    }
    return Row(
      children: images,
    );
  }

  void showLoader(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [SpinKitRing(
            color: Colors.deepOrangeAccent,
            size: 100,
          )],
        );
      },
    );
  }

  void showErrorDialog(errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text("Ошибка"),
              content: Text(errorMessage),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.red
                    ),
                    child: const Text("Ok"))
              ],
            )
    );
  }

  void showOKDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text("Инвентаризация проведена"),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green
                    ),
                    child: const Text("Ok"))
              ],
            )
    );
  }

  Future<void> PostInventory () async{
    showLoader();
    Location location = Location();
    final _locationData = await location.getLocation();
    LocationInventory inv = LocationInventory(0, _locationData.latitude!, _locationData.longitude!, int.parse(selValue!), comment, [""]);
    if(imagePaths.isNotEmpty){
      var request = http.MultipartRequest('POST', Uri.parse(APIUri.Inventory.SavePhotos));
      request.headers.addAll({"Authorization": user!.Token as String});
      for(var image in imagePaths){
        request.files.add(await http.MultipartFile.fromPath('picture', image));
      }

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      final body = (json.decode(responsed.body) as List<dynamic>).cast<String>();
      inv.PhotosNames = body;
    }
    var jsoned = json.encode(inv);

    var response = await http.post(
        Uri.parse(APIUri.Inventory.AddInventory),
        headers: {
          "Content-Type": "application/json",
          "Authorization": user!.Token as String
        },
        body: jsoned);

    Navigator.pop(context);

    if(response.statusCode == 200){
      showOKDialog();
    }
    else{
      var error = Error.fromResponse(response);
      var errorMessage = "${error.Message} при обращаении к ${error.Path}";
      showErrorDialog(errorMessage);
    }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserLocation(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: const Text("Инвентаризация"),
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
                              "${user!.Name}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          )
                      ),
                      ListTile(
                        leading: const Icon(Icons.alt_route),
                        title: const Text('Выбор функционала'),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) => const FunctionalPage()), (route) => false);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Выйти'),
                        onTap: () async {
                          await storage.delete(key: "User");
                          await storage.delete(key: "Partners");
                          await storage.delete(key: "Fields");
                          await storage.delete(key: "Cultures");
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) => const Auth()), (route) => false);
                        },
                      ),
                      ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Обновить данные'),
                          onTap: () async {
                          }
                      ),
                    ],
                  ),
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
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Выбирете культуру"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selValue,
                              items: dropitems,
                              onChanged: (String? value) {
                                selValue = value;
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Добавте комментарий"),
                          ),
                          TextFormField(
                            maxLines: null,
                            initialValue: comment,
                            style: const TextStyle(fontSize: 20),
                            decoration: const InputDecoration(
                              hintText: "Комментарий",
                            ),
                            onChanged: (text) {
                              comment = text;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          findImage(),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const CameraView()),
                                          (route) => false);
                                },
                                child: const Icon(Icons.add)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15, right: 15),
                  child: FloatingActionButton(
                  heroTag: "confirm",
                  onPressed: () async {
                    if(selValue==null){
                      showErrorDialog("Выберете культуру");
                    }
                    else{
                      Workmanager().cancelAll();
                      Location location = Location();
                      final _locationData = await location.getLocation();
                      LocationInventory inv = LocationInventory(0, _locationData.latitude!, _locationData.longitude!, int.parse(selValue!), comment, []);
                      var encoded = jsonEncode(inv);
                      var decodedMap = jsonDecode(encoded);

                      var i = LocationInventory.fromJson(decodedMap);
                      try {
                        await InternetAddress.lookup('example.com');
                      } on SocketException catch (_) {
                        showErrorDialog("Отстуствует соеденение с интернетом. Инвентаризация проведется с появлением соединения");
                      }
                      Workmanager().initialize(
                          callbackDispatcher, // The top level function, aka callbackDispatcher
                          isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
                      );
                      Workmanager().registerOneOffTask(
                          "posting-inventory",
                          "simpleTask",
                        constraints: Constraints(networkType: NetworkType.connected),
                        inputData: {
                            "Inventory": encoded,
                            "Images": imagePaths,
                            "UserToken": user!.Token
                        }
                      );
                    }
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check),
                ),),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15, left: 15),
                  child: FloatingActionButton(
                    heroTag: "clearData",
                    onPressed: () {
                      selValue = null;
                      imagePaths = [];
                      comment = "";
                      setState((){});
                    },
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.delete),
                  ),
        ),
              ),
            ],
          );
        } else {
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
