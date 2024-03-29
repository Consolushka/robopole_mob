import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:robopole_mob/pages/measurementSelection.dart';
import 'package:robopole_mob/pages/passportField.dart';
import 'dart:convert';
import 'package:robopole_mob/utils/classes.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/pages/recorder.dart';
import 'package:robopole_mob/pages/camera_preview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:robopole_mob/utils/sofrware_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/APIUri.dart';
import '../utils/storageUtils.dart';
import '../utils/backgroundWorker.dart';
import '../utils/dialogs.dart';

@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "inspection":
        return await backgroundPostInspection(inputData);
      case "inventory":
        return await backgroundPostInventory(inputData);
      case "measurement":
        return await backgroundPostMeasurement(inputData);
      default:
        return Future.value(true);
    }
  });
}

String? selCulture = null;
String? selPartner = null;
String? comment = null;

List<String> invs = [];

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  User? user;

  Row? imagesRow = null;

  List<DropdownMenuItem<String>> culturesItems = [];
  List<DropdownMenuItem<String>> partnersItems = [];

  LatLng _userLocation = const LatLng(53.31, 38.1);

  @override
  void initState() {
    Workmanager().initialize(
        backgroundDispatcher // The top level function, aka callbackDispatcher
        );
    super.initState();

    _getUserLocation();
  }

  void _getUserLocation() async {
    final _locationData = await Software.getUserLocation();
    user = await LocalStorage.User();

    culturesItems = [];

    var availableCultures = await LocalStorage.Cultures();
    for (int i = 0; i < availableCultures.length; i++) {
      var element = availableCultures[i];
      if (element.ParentID == 0) {
        culturesItems.add(DropdownMenuItem(
          child: Text(element.Name!),
          value: "${element.ID}",
        ));
      }
    }

    var availablePartners = await LocalStorage.Partners();
    for (var partner in availablePartners) {
      partnersItems.add(DropdownMenuItem(
        child: Text(partner["name"]),
        value: "${partner["id"]}",
      ));
    }
    var check = await PH.Permission.microphone.status;
    if (check.isDenied) {
      final status = await PH.Permission.microphone.request();
      debugPrint(status.toString());
      if (status != PH.PermissionStatus.granted) {
        throw 'Microphone permission not granted';
      }
    }

    await recorder.openRecorder();
    isRecorderReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 1000));

    List<Container> images = [];
    for (int i = 0; i < imagePaths.length; i++) {
      images.add(Container(
        height: 75,
        width: 75,
        child: Image.file(File(imagePaths[i])),
      ));
    }
    for (int i = 0; i < videoPaths.length; i++) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoPaths[i],
          imageFormat: ImageFormat.JPEG,
          maxWidth: 75,
          quality: 100);
      images.add(Container(
          width: 75,
          height: 75,
          child: Stack(
            children: [
              Image.file(File(thumbnailPath!)),
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.grey,
                  size: 40,
                ),
              )
            ],
          )));
    }

    imagesRow = Row(
      children: images,
    );

    setState(() {
      _userLocation = LatLng(_locationData.latitude, _locationData.longitude);
    });
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
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

  Future<void> PostInventory(inv) async {
    showLoader(context);
    if (inv.PhotosNames.isNotEmpty) {
      var request =
          http.MultipartRequest('POST', Uri.parse(APIUri.Content.SavePhotos));
      request.headers.addAll({"Authorization": user!.Token as String});
      for (var image in inv.PhotosNames) {
        request.files.add(await http.MultipartFile.fromPath('picture', image));
      }

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if (responsed.statusCode != 200) {
        Navigator.pop(context);
        showErrorDialog(context, responsed.reasonPhrase);
        return;
      }
      final body =
          (json.decode(responsed.body) as List<dynamic>).cast<String>();
      inv.PhotosNames = body;
    }

    if (inv.VideoNames.isNotEmpty) {
      var request =
          http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveVideos));
      request.headers.addAll({"Authorization": user!.Token as String});
      for (var image in inv.VideoNames) {
        request.files.add(await http.MultipartFile.fromPath('file', image));
      }
      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if (responsed.statusCode != 200) {
        Navigator.pop(context);
        showErrorDialog(context, responsed.reasonPhrase);
        return;
      }
      final body =
          (json.decode(responsed.body) as List<dynamic>).cast<String>();
      inv.VideoNames = body;
    }

    if (inv.AudioName != null && inv.AudioName != "") {
      var request =
          http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveAudio));
      request.headers.addAll({"Authorization": user!.Token as String});
      request.files
          .add(await http.MultipartFile.fromPath('audio', inv.AudioName));

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);

      if (responsed.statusCode != 200) {
        Navigator.pop(context);
        showErrorDialog(context, responsed.reasonPhrase);
        return;
      }
      final body = responsed.body;
      inv.AudioName = body;
    }
    var jsoned = json.encode(inv);
    var response = await http.post(Uri.parse(APIUri.Inventory.AddInventory),
        headers: {
          "Content-Type": "application/json",
          "Authorization": user!.Token as String
        },
        body: jsoned);

    Navigator.pop(context);

    if (response.statusCode == 200) {
      showOKDialog(context, "Инвентаризация проведена", this.moveToFunctionalSelection);
    } else {
      var error = Error.fromResponse(response);
      var errorMessage = "${error.Message} при обращаении к ${error.Path}";
      showErrorDialog(context, errorMessage);
    }
  }

  void resetState() {
    imagePaths = [];
    videoPaths = [];
    audioPath = "";
    comment = null;
    setState(() {
      selCulture = null;
      imagesRow = Row(
        children: [],
      );
      audioDuration = "";
    });
  }

  void moveToFunctionalSelection(){
    imagePaths = [];
    videoPaths = [];
    audioPath = "";
    comment = null;
    selCulture = null;
    imagesRow = Row(
      children: [],
    );
    audioDuration = "";

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const FunctionalPage()),
            (route) => false);
  }

  Widget RecorderButton() {
    if (audioPath == "") {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black45,
        child: IconButton(
          icon: Icon(Icons.mic),
          iconSize: 35,
          color: Colors.white,
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Recorder(
                          page: "Inventory",
                        )));
          },
        ),
      );
    } else {
      return Text("Аудиофайл (${audioDuration} c)");
    }
  }

  Future record() async {
    if (!isRecorderReady) return;

    await recorder.startRecorder(toFile: "${user!.ID}.aac");
    setState(() {});
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();

    final audioFile = File(path!);

    audioPath = path;

    print("Recorder File in path: ${audioFile}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return partnersItems.length == 0
        ? SpinKitRing(
            color: Colors.deepOrangeAccent,
            size: 100,
          )
        : Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  title: const Text("Инвентаризация"),
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                bottomNavigationBar: BottomAppBar(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          resetState();
                        },
                        child: Icon(
                          Icons.delete,
                          size: 35,
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            backgroundColor: Colors.redAccent,
                            shape: CircleBorder()),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (selCulture == null) {
                            showErrorDialog(context, "Выберете культуру");
                            return;
                          }
                          if (selPartner == null) {
                            showErrorDialog(context, "Выберете хозяйство");
                            return;
                          }
                          final _locationData =
                              await Software.getUserLocation();
                          LocationInventory inv = LocationInventory(
                              0,
                              _locationData.latitude,
                              _locationData.longitude,
                              int.parse(selCulture!),
                              int.parse(selPartner!),
                              comment,
                              imagePaths,
                              audioPath,
                              videoPaths);
                          var encoded = jsonEncode(inv);
                          try {
                            await InternetAddress.lookup('example.com');
                            invs = [];

                            await PostInventory(inv);
                          } on SocketException catch (_) {
                            Workmanager().cancelByTag("inventory");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                margin: EdgeInsets.only(right: 100, left: 80),
                                content: const Text(
                                  'Инвентаризация проведется при подключении к интернету',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                // action: SnackBarAction(
                                //   label: 'Action',
                                //   onPressed: () {
                                //     // Code to execute.
                                //   },
                                // ),
                              ),
                            );
                            if (await LocalStorage.GetBooleanValue(
                                "isPostedInventoriesLengthIsNull")) {
                              invs = [];
                            }
                            invs.add(encoded);
                            var e = jsonEncode(invs);
                            var encodedInventories = Map();
                            encodedInventories["invs"] = e;
                            Workmanager().registerOneOffTask(
                                "${DateTime.now().microsecond}", "inventory",
                                existingWorkPolicy: ExistingWorkPolicy.replace,
                                tag: "inventory",
                                constraints: Constraints(
                                    networkType: NetworkType.connected),
                                inputData: {
                                  "Inventory": e,
                                  "UserToken": user!.Token
                                });
                            await LocalStorage.SetFalseValue(
                                "isPostedInventoriesLengthIsNull");
                            selCulture = null;
                            imagePaths = [];
                            videoPaths = [];
                            audioDuration = "";
                            audioPath = "";
                            comment = null;
                            // Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        child: Icon(
                          Icons.check,
                          size: 50,
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.all(20),
                            shape: CircleBorder()),
                      ),
                    ],
                  ),
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
                          )),
                      ListTile(
                        leading: const Icon(Icons.alt_route),
                        title: const Text('Выбор функционала'),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FunctionalPage()),
                              (route) => false);
                        },
                      ),
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
                                    builder: (context) =>
                                        const MeasurementSelection()),
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
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Выйти'),
                        onTap: () async {
                          await LocalStorage.ClearAll();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Auth()),
                              (route) => false);
                        },
                      ),
                      ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Обновить данные'),
                          onTap: () async {
                            showLoader(context);
                            await LocalStorage.RestoreData();
                            Navigator.pop(context);
                            setState(() {});
                          }),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
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
                              height: 15,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Выберете хозяйство",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selPartner,
                                items: partnersItems,
                                onChanged: (String? value) {
                                  setState(() {
                                    selPartner = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Выберете культуру",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selCulture,
                                items: culturesItems,
                                onChanged: (String? value) {
                                  setState(() {
                                    selCulture = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Добавте комментарий",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            TextFormField(
                              maxLines: null,
                              textInputAction: TextInputAction.go,
                              initialValue: comment==null?"":comment,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: "Комментарий",
                              ),
                              onChanged: (text) {
                                comment = text;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            imagesRow!,
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 100),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    width: 100,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CameraView("inventory")),
                                              (route) => false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black45
                                                .withOpacity(0.26)),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        )),
                                  ),
                                  RecorderButton()
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
