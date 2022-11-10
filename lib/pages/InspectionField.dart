import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:robopole_mob/utils/classes.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:robopole_mob/pages/auth.dart';
import 'package:robopole_mob/pages/functionalSelection.dart';
import 'package:robopole_mob/pages/recorder.dart';
import 'package:robopole_mob/utils/storageUtils.dart';
import 'package:robopole_mob/pages/camera_preview.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:workmanager/workmanager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/APIUri.dart';
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
String comment = "";
List<String> insps = [];

class InspectionField extends StatefulWidget {
  const InspectionField({Key? key}) : super(key: key);

  @override
  State<InspectionField> createState() => _InspectionFieldState();
}

class _InspectionFieldState extends State<InspectionField> {
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  final storage = const FlutterSecureStorage();

  Map currentField = Map();

  User? user;

  double highest = 0.0;
  double rightest = 0.0;
  double lowest = 0.0;
  double leftest = 0.0;

  Row? imagesRow = null;

  @override
  void initState() {
    Workmanager().initialize(
      backgroundDispatcher, // The top level function, aka callbackDispatcher
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

    await recorder.openRecorder();
    isRecorderReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  Future findField() async {
    var location = await getUserLocation();
    var fields = List.empty();
    try{
      fields = await requestForFields();
    }
    catch(ex){
      showErrorDialog(context, ex.toString());
    }
    for (int i = 0; i < fields.length; i++) {
      var field = fields[i];
      bool result = false;
      var cooooords = [];
      try {
        cooooords = jsonDecode(field["coordinates"])[0];
      } catch (ex) {
        continue;
      }
      List<LatLng> polygonCoords = [];
      cooooords.forEach((element) {
        var c = element;
        double? lat;
        double? lng;
        if (element[0] is double) {
          lat = c[1];
          lng = c[0];
          polygonCoords.add(LatLng(c[1], c[0]));
        } else {
          c = element[0];
          lat = c[1];
          lng = c[0];
          polygonCoords.add(LatLng(c[1], c[0]));
        }
        if (polygonCoords.length == 1) {
          highest = lat!;
          lowest = lat;
          rightest = lng!;
          leftest = lng;
        }
        if (lat! > highest) {
          highest = lat;
        } else {
          if (lat < lowest) {
            lowest = lat;
          }
        }
        if (lng! > rightest) {
          rightest = lng;
        } else {
          if (lng < leftest) {
            leftest = lng;
          }
        }
      });
      var j = polygonCoords.length - 1;
      for (int i = 0; i < polygonCoords.length; i++) {
        if ((polygonCoords[i].longitude < location.longitude &&
                    polygonCoords[j].longitude >= location.longitude ||
                polygonCoords[j].longitude < location.longitude &&
                    polygonCoords[i].longitude >= location.longitude) &&
            (polygonCoords[i].latitude +
                    (location.longitude - polygonCoords[i].longitude) /
                        (polygonCoords[j].longitude -
                            polygonCoords[i].longitude) *
                        (polygonCoords[j].latitude -
                            polygonCoords[i].latitude) <
                location.latitude)) result = !result;
        j = i;
      }

      if (result) {
        currentField = field;
        currentField["coords"] = polygonCoords;
        break;
      }
    }
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
                child: Icon(Icons.play_arrow, color: Colors.grey, size: 40,),
              )
            ],
          )
      ));
    }

    imagesRow = Row(
      children: images,
    );
  }

  Row findImage() {
    return imagesRow!;
  }

  Widget RecorderButton() {
    if (audioPath == "" || audioPath == null) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black45,
        child: IconButton(
          icon: Icon(Icons.mic),
          iconSize: 35,
          color: Colors.white,
          onPressed: () async{
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Recorder(page: "Inspection")));
          },
        ),
      );
    } else {
      return Text("Аудиофайл (${audioDuration} c)");
    }
  }

  Future record() async {
    if (!isRecorderReady) {
      return;
    }

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

  Widget FieldMap() {
    return Container(
      height: 300,
      child: GoogleMap(
          polygons: <Polygon>{
            Polygon(
                polygonId: PolygonId("${currentField["id"]}"),
                points: currentField["coords"] as List<LatLng>,
                strokeWidth: 1,
                strokeColor: Colors.deepOrangeAccent,
                fillColor: Colors.amberAccent.withOpacity(0.5),
                consumeTapEvents: true)
          },
          mapType: MapType.hybrid,
          cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              northeast: LatLng(highest, rightest),
              southwest: LatLng(lowest, leftest))),
          initialCameraPosition:
              CameraPosition(target: LatLng(54.3, 38.4), zoom: 16),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true),
    );
  }

  Future<void> PostInspection(insp) async {
    showLoader(context);
    if (insp.PhotosNames.isNotEmpty) {
      var request =
          http.MultipartRequest('POST', Uri.parse(APIUri.Content.SavePhotos));
      request.headers.addAll({"Authorization": user!.Token as String});
      for (var image in insp.PhotosNames) {
        request.files.add(await http.MultipartFile.fromPath('picture', image));
      }

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if(responsed.statusCode!=200){
        Navigator.pop(context);
        showErrorDialog(context, responsed.reasonPhrase);
        return;
      }
      final body =
          (json.decode(responsed.body) as List<dynamic>).cast<String>();
      insp.PhotosNames = body;
    }


    if (insp.VideoNames.isNotEmpty) {
      var request =
      http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveVideos));
      request.headers.addAll({"Authorization": user!.Token as String});
      for (var image in insp.VideoNames) {
        request.files.add(await http.MultipartFile.fromPath('file', image));
      }
      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if(responsed.statusCode!=200){
        Navigator.pop(context);
        showErrorDialog(context, responsed.reasonPhrase);
        return;
      }
      final body =
      (json.decode(responsed.body) as List<dynamic>).cast<String>();
      insp.VideoNames = body;
    }

    if (insp.AudioName != null && insp.AudioName != "") {
      var request =
          http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveAudio));
      request.headers.addAll({"Authorization": user!.Token as String});
      request.files
          .add(await http.MultipartFile.fromPath('audio', insp.AudioName));

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if(responsed.statusCode!=200){
        Navigator.pop(context);
        showErrorDialog(context, responsed.reasonPhrase);
        return;
      }
      final body = responsed.body;
      insp.AudioName = body;
    }
    var jsoned = json.encode(insp);
    var response = await http.post(Uri.parse(APIUri.Inspection.AddInspection),
        headers: {
          "Content-Type": "application/json",
          "Authorization": user!.Token as String
        },
        body: jsoned);

    Navigator.pop(context);

    if (response.statusCode == 200) {
      showOKDialog(context, "Осмотр поля проведен", this.resetState);
    } else {
      var error = Error.fromResponse(response);
      var errorMessage = "${error.Message} при обращаении к ${error.Path}";
      showErrorDialog(context, errorMessage);
    }
  }

  void resetState(){
    imagePaths = [];
    videoPaths = [];
    audioPath = "";
    audioDuration = "";
    comment = "";
    setState((){});
  }

  Future<LatLng> getUserLocation() async {
    Location location = Location();
    user = User.fromJson(await storage.read(key: "User") as String);

    final _locationData = await location.getLocation();

    return LatLng(_locationData.latitude!, _locationData.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: findField(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if(currentField.isEmpty){
            return Scaffold(
              appBar: AppBar(
                title: Text("Осмотр поля"),
                backgroundColor: Colors.deepOrangeAccent,
              ),
              body: AlertDialog(
                title: const Text("Не найдено поле по вашей геопозиции"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FunctionalPage()),
                                (route) => false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text("Ok"))
                ],
              ),
            );
          }
          else{
            return Stack(
              children: [
                Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    title: Text("Осмотр поля ${currentField["id"]}"),
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  bottomNavigationBar: BottomAppBar(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            imagePaths = [];
                            videoPaths = [];
                            audioDuration = "";
                            comment = "";
                            audioPath = "";
                            setState(() {});
                          },
                            child: Icon(Icons.delete, size: 35,),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                              backgroundColor: Colors.redAccent,
                              shape: CircleBorder()),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Location location = Location();
                            final _locationData = await location.getLocation();
                            Inspection insp = Inspection(
                                0,
                                _locationData.latitude!,
                                _locationData.longitude!,
                                currentField["id"],
                                comment,
                                imagePaths,
                                audioPath,
                                videoPaths);
                            var encoded = jsonEncode(insp);
                            try {
                              await InternetAddress.lookup('example.com');
                              insps = [];
                              await PostInspection(insp);
                            } on SocketException catch (_) {
                              Workmanager().cancelByTag("inspection");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  margin: EdgeInsets.only(right: 100, left: 80),
                                  content: const Text(
                                    'Осмотр поля проведется при подключении к интернету',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              if (await storage.read(
                                  key: "isPostedInspectionsLengthIsNull") ==
                                  "1") {
                                insps = [];
                              }
                              insps.add(encoded);
                              var e = jsonEncode(insps);
                              var encodedInventories = Map();
                              encodedInventories["invs"] = e;

                              Workmanager().registerOneOffTask(
                                  "${DateTime.now()}", "inspection",
                                  existingWorkPolicy: ExistingWorkPolicy.replace,
                                  tag: "inspection",
                                  constraints: Constraints(
                                      networkType: NetworkType.connected),
                                  inputData: {
                                    "Inspections": e,
                                    "UserToken": user!.Token
                                  });
                              await storage.write(
                                  key: "isPostedInspectionsLengthIsNull",
                                  value: "0");
                              imagePaths = [];
                              videoPaths = [];
                              audioDuration = "";
                              audioPath = "";
                              comment = "";
                              setState(() {});
                            }
                          },
                          child: Icon(Icons.check, size: 50,),
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
                              var availableFields = await http.post(
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
                              var part = await http.get(
                                  Uri.parse(APIUri.Partner.AvailablePartners),
                                  headers: {
                                    HttpHeaders.authorizationHeader: user!.Token as String,
                                  });
                              if(part.statusCode==200){
                                await storage.write(key: "Partners", value: part.body);
                              }

                              var response = await http.get(Uri.parse(APIUri.Cultures.AllCultures),
                                  headers: {"Authorization": user!.Token as String});
                              if (response.statusCode == 200) {
                                await storage.write(key: "Cultures", value: response.body);
                              }
                              Navigator.pop(context);
                              setState(() {});
                            }),
                      ],
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        // SizedBox(height: 300,),
                        FieldMap(),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
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
                              SizedBox(
                                height: 15,
                              ),
                              findImage(),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 100),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      width: 100,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => CameraView(
                                                    "InspectionField")
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black45.withOpacity(0.26)
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 40,
                                          )),
                                    ),
                                    RecorderButton()
                                  ],
                                ),
                              )
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
