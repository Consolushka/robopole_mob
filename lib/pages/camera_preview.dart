import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:robopole_mob/pages/fieldInspection.dart';
import 'package:robopole_mob/pages/inventory.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

List<String> imagePaths = [];
List<String> videoPaths = [];


class CameraView extends StatefulWidget {
  String page;

  CameraView(this.page);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool isVideo = false;
  bool _isLoading = true;
  bool _isRecording = false;
  CameraLensDirection direction = CameraLensDirection.back;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future _initCamera() async {
    final cameras = await availableCameras();
    final front =
        cameras.firstWhere((camera) => camera.lensDirection == direction);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    if (_isRecording) {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
    }
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        builder: (_) => VideoPage(filePath: file.path, page: widget.page),
      );
      Navigator.push(context, route);
    } else {
      setState(() => _isRecording = true);
    }
  }

  List<Widget> getButtons() {
    if (isVideo) {
      return [
        Padding(
          padding: EdgeInsets.only(bottom: 40, left: 10),
          child: SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              heroTag: 'switch',
              onPressed: () {
                if (direction == CameraLensDirection.back) {
                  direction = CameraLensDirection.front;
                } else {
                  direction = CameraLensDirection.back;
                }
                setState(() {});
              },
              backgroundColor: Colors.grey,
              child: const Icon(
                Icons.flip_camera_ios_outlined,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: SizedBox(
            height: 100,
            width: 100,
            child: FloatingActionButton(
              heroTag: 'video',
              elevation: 0,
              onPressed: () => _recordVideo(),
              backgroundColor: Color.fromRGBO(24, 233, 111, 0),
              child: Icon(
                _isRecording ? Icons.stop : Icons.videocam,
                size: 60,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 40, left: 10),
          child: SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              heroTag: 'camera',
              onPressed: () {
                isVideo = false;
                setState(() {});
              },
              backgroundColor: Colors.grey,
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 20,
              ),
            ),
          ),
        ),
      ];
    } else {
      return [
        Padding(
          padding: EdgeInsets.only(bottom: 40, left: 10),
          child: SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              heroTag: 'switch',
              onPressed: () {
                if (direction == CameraLensDirection.back) {
                  direction = CameraLensDirection.front;
                } else {
                  direction = CameraLensDirection.back;
                }
                setState(() {});
              },
              backgroundColor: Colors.grey,
              child: const Icon(
                Icons.flip_camera_ios_outlined,
                size: 20,
              ),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SizedBox(
              height: 100,
              width: 100,
              child: FloatingActionButton(
                heroTag: 'camera',
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  final image = await _cameraController.takePicture();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          DisplayPictureScreen(widget.page, image.path),
                    ),
                  );
                },
                backgroundColor: Color.fromRGBO(24, 233, 111, 0),
                elevation: 0,
                child: const Icon(Icons.photo_camera, size: 60),
              ),
            )),
        Padding(
          padding: const EdgeInsets.only(bottom: 40, left: 10),
          child: SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              heroTag: 'video',
              onPressed: () {
                isVideo = true;
                setState(() {});
              },
              backgroundColor: Colors.grey,
              child: const Icon(Icons.videocam_outlined, size: 20),
            ),
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initCamera(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CameraPreview(_cameraController),
                ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height - 100,
                      left: MediaQuery.of(context).size.width / 2 - 100),
                  children: getButtons(),
                )
              ],
            ),
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

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  DisplayPictureScreen(this.page, this.imagePath);

  final String imagePath;
  final String page;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Проверьте фотографию"),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          // The image is stored as a file on the device. Use the `Image.file`
          // constructor with the given path to display the image.
          body: Column(
            children: [
              Image.file(File(imagePath)),
            ],
          ),
        ),
        Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, left: 15),
              child: FloatingActionButton(
                heroTag: "close",
                onPressed: () {
                  if (page == "inventory") {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Inventory()),
                        (route) => false);
                  } else {
                    if (page == "fieldInspection") {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FieldInspection()),
                          (route) => false);
                    }
                  }
                },
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.close),
              ),
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, right: 15),
              child: FloatingActionButton(
                heroTag: "fine",
                onPressed: () {
                  imagePaths.add(imagePath);
                  if (page == "inventory") {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Inventory()),
                        (route) => false);
                  } else {
                    if (page == "fieldInspection") {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FieldInspection()),
                          (route) => false);
                    }
                  }
                },
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
              ),
            ))
      ],
    );
  }
}

class VideoPage extends StatefulWidget {
  final String filePath;
  final String page;

  const VideoPage({Key? key, required this.filePath, required this.page}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(false);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Проверьте видеозапись"),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          body: FutureBuilder(
            future: _initVideoPlayer(),
            builder: (context, state) {
              if (state.connectionState == ConnectionState.waiting) {
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
              } else {
                return VideoPlayer(_videoPlayerController);
              }
            },
          ),
        ),
        Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, left: 15),
              child: FloatingActionButton(
                heroTag: "close",
                onPressed: () {
                  if (widget.page == "inventory") {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Inventory()),
                            (route) => false);
                  } else {
                    if (widget.page == "fieldInspection") {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FieldInspection()),
                              (route) => false);
                    }
                  }
                },
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.close),
              ),
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 30, right: 15),
              child: FloatingActionButton(
                heroTag: "fine",
                onPressed: () {
                  videoPaths.add(widget.filePath);
                  debugPrint('$videoPaths');
                  if (widget.page == "inventory") {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Inventory()),
                            (route) => false);
                  } else {
                    if (widget.page == "fieldInspection") {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FieldInspection()),
                              (route) => false);
                    }
                  }
                },
                backgroundColor: Colors.green,
                child: Icon(Icons.check),
              ),
            ))
      ],
    );
  }
}
