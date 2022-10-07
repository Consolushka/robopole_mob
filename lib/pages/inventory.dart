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
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:video_thumbnail/video_thumbnail.dart';

String? selCulture = null;
String? selPartner = null;
int audioDuration = 0;
String? audioPath = null;
String comment = "";
NotificationService _notificationService = NotificationService();
List<String> invs = [];

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var userToken = inputData!["UserToken"] as String;
    List inentory = jsonDecode(inputData["Inventory"]) as List;
    for (String invetn in inentory) {
      LocationInventory inv = LocationInventory.fromJson(jsonDecode(invetn));
      if (inv.PhotosNames!.isNotEmpty) {
        var request =
            http.MultipartRequest('POST', Uri.parse(APIUri.Content.SavePhotos));
        request.headers.addAll({"Authorization": userToken});
        for (var image in inv.PhotosNames!) {
          request.files
              .add(await http.MultipartFile.fromPath('picture', image));
        }

        var res = await request.send();
        var responsed = await http.Response.fromStream(res);
        final body =
            (json.decode(responsed.body) as List<dynamic>).cast<String>();
        inv.PhotosNames = body;
      }

      if (inv.VideoNames!.isNotEmpty) {
        var request =
        http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveVideos));
        request.headers.addAll({"Authorization": userToken});
        for (var image in inv.VideoNames!) {
          request.files.add(await http.MultipartFile.fromPath('file', image));
        }
        var res = await request.send();
        var responsed = await http.Response.fromStream(res);
        if (responsed.statusCode != 200) {
          var error = Error.fromResponse(responsed);
          await _notificationService.showNotifications(
              "Ошибка при проведении инвентаризации. ${error.Message}");
          return Future.value(false);
        }
        final body =
        (json.decode(responsed.body) as List<dynamic>).cast<String>();
        inv.VideoNames = body;
      }

      if (inv.AudioName != null && inv.AudioName != "") {
        var request =
            http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveAudio));
        request.headers.addAll({"Authorization": userToken});
        request.files
            .add(await http.MultipartFile.fromPath('audio', inv.AudioName!));

        var res = await request.send();
        var responsed = await http.Response.fromStream(res);
        final body = responsed.body;
        inv.AudioName = body;
      }
      var jsoned = json.encode(inv);

      var response = await http.post(Uri.parse(APIUri.Inventory.AddInventory),
          headers: {
            "Content-Type": "application/json",
            "Authorization": userToken
          },
          body: jsoned);

      if (response.statusCode == 200) {
        final storage = const FlutterSecureStorage();
        storage.write(key: "isPostedInventoriesLengthIsNull", value: "1");
        await _notificationService.showNotifications("Инвентаризация пройдена");
      } else {
        var error = Error.fromResponse(response);
        await _notificationService.showNotifications(
            "Ошибка при проведении инвентаризации. ${error.Message}");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  User? user;

  String? selectedValue = null;
  Row? imagesRow = null;

  List<DropdownMenuItem<String>> culturesItems = [];
  List<DropdownMenuItem<String>> partnersItems = [];

  final storage = const FlutterSecureStorage();
  LatLng _userLocation = const LatLng(53.31, 38.1);

  @override
  void initState() {
    Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
    );
    super.initState();

    initRecorder();
  }

  Future initRecorder() async {
    var check = await PH.Permission.microphone.status;
    if (check.isDenied) {
      final status = await PH.Permission.microphone.request();
      debugPrint(status.toString());
      if (status != PH.PermissionStatus.granted) {
        throw 'Microphone permission not granted';
      }
    }

    var culturesStored = await storage.read(key: "Cultures");
    String culturesJson = "";
    user = User.fromJson(await storage.read(key: "User") as String);
    if (culturesStored == null) {
      var response = await http.get(Uri.parse(APIUri.Inventory.AllCultures),
          headers: {"Authorization": user!.Token as String});
      if (response.statusCode == 200) {
        culturesJson = response.body;
        await storage.write(key: "Cultures", value: response.body);
      }
    } else {
      culturesJson = culturesStored;
    }

    List<AgroCulture> availableCultures = [];
    (jsonDecode(culturesJson) as List).forEach((element) {
      availableCultures.add(AgroCulture.fromMap(element));
    });
    culturesItems = [];

    for (int i = 0; i < availableCultures.length - 1; i++) {
      var element = availableCultures[i];
      if (element.ParentID == 0) {
        culturesItems.add(DropdownMenuItem(
          child: Text(element.Name!),
          value: "${element.ID}",
        ));
      }
    }

    var partnersStorage = await storage.read(key: "Partners");
    String partnersJson = "";

    if (partnersStorage == null) {
      var part =
          await http.get(Uri.parse(APIUri.Partner.AvailablePartners), headers: {
        HttpHeaders.authorizationHeader: user!.Token as String,
      });
      if (part.statusCode == 200) {
        partnersJson = part.body;
        await storage.write(key: "Partners", value: part.body);
      } else {
        var error = Error.fromResponse(part);
      }
    } else {
      partnersJson = partnersStorage;
    }

    var decodedPartners = jsonDecode(partnersJson) as List;

    for (var partner in decodedPartners) {
      partnersItems.add(DropdownMenuItem(
        child: Text(partner["name"]),
        value: "${partner["id"]}",
      ));
    }

    await recorder.openRecorder();
    isRecorderReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  Future<LatLng> getUserLocation() async {
    if (user == null) {
      user = User.fromJson(await storage.read(key: "User") as String);
    }
    Location location = Location();

    final _locationData = await location.getLocation();
    _userLocation = LatLng(_locationData.latitude!, _locationData.longitude!);

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
      showOKDialog(context, "Инвентаризация проведена", this.resetState);
    } else {
      var error = Error.fromResponse(response);
      var errorMessage = "${error.Message} при обращаении к ${error.Path}";
      showErrorDialog(context, errorMessage);
    }
  }

  void resetState() {
    selCulture = null;
    imagePaths = [];
    videoPaths = [];
    audioDuration = 0;
    audioPath = "";
    comment = "";
    setState(() {});
  }

  Widget AudioDuration() {
    if (audioPath == "" || audioPath == null) {
      return StreamBuilder<RecordingDisposition>(
          stream: recorder.onProgress,
          builder: (context, snapshot) {
            if (audioDuration == 0) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              audioDuration = duration.inSeconds;
              return Text('${duration.inSeconds} c');
            } else {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              if (audioDuration + 1 == duration.inSeconds) {
                audioDuration = duration.inSeconds;
                return Text('${duration.inSeconds} c');
              } else {
                return Text('$audioDuration c');
              }
            }
          });
    } else {
      return Text("Звуковой файл (${audioDuration}c)");
    }
  }

  Widget RecorderButton() {
    if (audioPath == "" || audioPath == null) {
      return SizedBox(
        height: 60,
        width: 60,
        child: ElevatedButton(
          onPressed: () async {
            debugPrint("pressed");
            if (recorder.isRecording) {
              await stop();
            } else {
              await record();
            }
          },
          child: Icon(
            recorder.isRecording ? Icons.stop : Icons.mic,
            size: 30,
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(60.0),
            ),
          ),
        ),
      );
    } else {
      return Text("");
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
    return FutureBuilder(
      future: getUserLocation(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: true,
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
                        leading: const Icon(Icons.logout),
                        title: const Text('Выйти'),
                        onTap: () async {
                          await storage.delete(key: "User");
                          await storage.delete(key: "Partners");
                          await storage.delete(key: "Fields");
                          await storage.delete(key: "Cultures");
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
                            await storage.delete(key: "selectedPartnerId");
                            await storage.delete(key: "Partners");
                            var availableFields = await http.get(
                                Uri.parse(APIUri.Field.UpdateFields),
                                headers: {
                                  HttpHeaders.authorizationHeader:
                                      user!.Token as String,
                                });

                            if (availableFields.statusCode != 200) {
                              var error = Error.fromResponse(availableFields);
                              Navigator.pop(context);
                              showErrorDialog(context, error);
                            }

                            await storage.write(
                                key: "Fields", value: availableFields.body);
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
                              initialValue: comment,
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
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 40,
                                        )),
                                  ),
                                  AudioDuration(),
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
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 15),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: FloatingActionButton(
                        heroTag: "confirm",
                        elevation: 2,
                        onPressed: () async {
                          if (selCulture == null) {
                            showErrorDialog(context, "Выберете культуру");
                            return;
                          }
                          if (selPartner == null) {
                            showErrorDialog(context, "Выберете хозяйство");
                            return;
                          }
                          Workmanager().cancelAll();
                          Location location = Location();
                          final _locationData = await location.getLocation();
                          LocationInventory inv = LocationInventory(
                              0,
                              _locationData.latitude!,
                              _locationData.longitude!,
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
                            if (await storage.read(
                                    key: "isPostedInventoriesLengthIsNull") ==
                                "1") {
                              invs = [];
                            }
                            invs.add(encoded);
                            var e = jsonEncode(invs);
                            var encodedInventories = Map();
                            encodedInventories["invs"] = e;
                            Workmanager().registerOneOffTask(
                                "${DateTime.now()}", "${DateTime.now()}",
                                existingWorkPolicy: ExistingWorkPolicy.append,
                                constraints: Constraints(
                                    networkType: NetworkType.connected),
                                inputData: {
                                  "Inventory": e,
                                  "UserToken": user!.Token
                                });
                            await storage.write(
                                key: "isPostedInventoriesLengthIsNull",
                                value: "0");
                            selCulture = null;
                            imagePaths = [];
                            videoPaths = [];
                            audioDuration = 0;
                            audioPath = "";
                            comment = "";
                            // Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.check,
                          size: 40,
                        ),
                      ),
                    )),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 15),
                  child: FloatingActionButton(
                    heroTag: "clearData",
                    onPressed: () {
                      selCulture = null;
                      selPartner = null;
                      imagePaths = [];
                      videoPaths = [];
                      audioDuration = 0;
                      audioPath = "";
                      comment = "";
                      setState(() {});
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
              children: const [
                SpinKitRing(
                  color: Colors.deepOrangeAccent,
                  size: 100,
                )
              ],
            ),
          );
        }
      },
    );
  }
}
