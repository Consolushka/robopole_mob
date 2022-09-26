import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:robopole_mob/pages/fieldInspection.dart';
import 'package:robopole_mob/pages/inventory.dart';

import '../main.dart';

List<String> imagePaths = [];

class CameraView extends StatefulWidget {
  String page;

  CameraView(this.page);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras[0],
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    // imagePaths = [];
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.deepOrangeAccent,
                ));
              }
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: SizedBox(
              height: 80,
              width: 80,
              child: FloatingActionButton(
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await _controller.takePicture();
                    // GallerySaver.saveImage(image.path);
                    if (!mounted) return;

                    // If the picture was taken, display it on a new screen.
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          widget.page,
                          image.path,
                        ),
                      ),
                    );
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                  }
                },
                backgroundColor: Colors.deepOrangeAccent,
                child: const Icon(Icons.camera_alt),
              ),
            )
          ),
        ),
      ],
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
