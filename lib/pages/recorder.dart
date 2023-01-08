import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:permission_handler/permission_handler.dart';
import 'package:robopole_mob/pages/InspectionField.dart';
import 'package:robopole_mob/pages/inventory.dart';

String audioPath = "";
String audioDuration = "";

class Recorder extends StatefulWidget {
  final String page;

  const Recorder({Key? key, required this.page}) : super(key: key);

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  final recorder = FlutterSoundRecorder();
  final player = ap.AudioPlayer();
  String fileName = "";
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((event) {
      setState((){
        duration = event;
      });
    });

    player.onPositionChanged.listen((event) {
      setState((){
        position = event;
      });
    });
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.dispose();

    super.dispose();
  }

  String formatTime (Duration duration){
    String twoDigits(int n)=>n.toString().padLeft(2,'0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds)}";
  }

  Widget getRecordButton(){
    if(fileName==""){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<RecordingDisposition>(
            stream: recorder.onProgress,
            builder: (context, snapshot) {
              final duration = snapshot.hasData
                  ? snapshot.data!.duration
                  : Duration.zero;

              audioDuration = formatTime(duration);

              return Text(
                '${duration.inSeconds} c',
                style: TextStyle(fontSize: 22),
              );
            },
          ),
          const SizedBox(
            height: 32,
          ),
          SizedBox(
            height: 110,
            width: 110,
            child: ElevatedButton(
                child: Icon(
                  recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 80,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(55),
                  ),
                ),
                onPressed: () async {
                  if (recorder.isRecording) {
                    await stop();
                  } else {
                    await record();
                  }

                  setState(() {});
                }),
          )
        ],
      );
    }
    else{
      return SizedBox();
    }
  }

  Widget getPlayer() {
    if (fileName != "") {
      player.setSourceUrl(fileName);
      return Column(
        children: [
          Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            activeColor: Colors.black.withOpacity(0.7),
            inactiveColor: Colors.black12,
            thumbColor: Colors.black87,
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await player.seek(position);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration-position))
              ],
            ),),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: Icon(
                isPlaying? Icons.pause : Icons.play_arrow
              ),
              iconSize: 50,
              color: Colors.white,
              onPressed: () async{
                if(isPlaying){
                  await player.pause();
                  setState((){
                    isPlaying = false;
                  });
                }
                else{
                  await player.resume();
                  setState((){
                    isPlaying = true;
                  });
                }
              },
            ),
          )
        ],
      );
    } else {
      return SizedBox();
    }
  }

  Widget? getBottomBar(){
    if(fileName == ""){
      return null;
    }
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.delete,
              size: 35,
            ),
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(10), backgroundColor: Colors.redAccent,
                shape: CircleBorder()),
          ),
          ElevatedButton(
            onPressed: () {
              audioPath = fileName;
              if(widget.page == "Inventory"){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Inventory()),
                        (route) => false);
              }
              else{
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InspectionField()),
                        (route) => false);
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
    );
  }

  Future initRecorder() async {
    var check = await Permission.microphone.status;
    if (check.isDenied) {
      final status = await Permission.microphone.request();
      debugPrint(status.toString());
      if (status != PermissionStatus.granted) {
        throw 'Microphone permission not granted';
      }
    }

    await recorder.openRecorder();

    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    fileName = File(path!).path;

    debugPrint("FileName: ${fileName}");
  }

  Future record() async {
    await recorder.startRecorder(toFile: "audio.aac");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              leading: Text(""),
              title: Text("Запись аудиосообщения"),
              backgroundColor: Colors.deepOrangeAccent,
            ),
            bottomNavigationBar: getBottomBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: getRecordButton()
                ),
                Center(
                  child: getPlayer(),
                )
              ],
            ),
        ),
      ],
    );
  }
}
