import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:robopole_mob/utils/classes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:robopole_mob/pages/measurementComplete.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MeasurementField extends StatefulWidget {
  Map? field;

  MeasurementField({Key? key, this.field}) : super(key: key);

  @override
  State<MeasurementField> createState() => _MeasurementFieldState();
}

class _MeasurementFieldState extends State<MeasurementField> {
  LatLng _userLocation = LatLng(55, 38);
  final Set<Polyline> _polyline = Set();
  final Set<Polygon> _polygon = Set();

  User? user;
  final storage = FlutterSecureStorage();

  late StreamSubscription<LocationData> locationSubscription;

  Future getUserLocation() async {
    if (_polyline.length > 0) {
      return;
    }
    user = User.fromJson(await storage.read(key: "User") as String);
    var u = _polyline;

    Location location = Location();
    locationSubscription =
        location.onLocationChanged.listen((LocationData locationData) {
      var latlng = LatLng(locationData.latitude!, locationData.longitude!);
      if (!_polyline.first.points.contains(latlng)) {
        _polyline.first.points.add(latlng);
        setState(() {});
      }
    });

    final _locationData = await location.getLocation();
    locationSubscription.pause();
    _userLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription.pause();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    "Замер поля ${widget.field == null ? "" : widget.field!["id"]}"),
                backgroundColor: Colors.deepOrangeAccent,
              ),
              body: GoogleMap(
                  mapType: MapType.hybrid,
                  polylines: _polyline,
                  polygons: _polygon,
                  initialCameraPosition:
                      CameraPosition(target: _userLocation, zoom: 16),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false),
              floatingActionButton: locationSubscription.isPaused
                  ? FloatingActionButton(
                      heroTag: "start",
                      onPressed: () async {
                        _polyline.add(Polyline(
                            polylineId: PolylineId("asdsd"),
                            width: 3,
                            color: Colors.blueAccent,
                            visible: true,
                            points: <LatLng>[]));
                        locationSubscription.resume();
                        setState((){});
                      },
                      backgroundColor: Colors.green,
                      child: Icon(Icons.play_arrow, size: 35),
                    )
                  : FloatingActionButton(
                      heroTag: "stop",
                      onPressed: () async {
                        locationSubscription.cancel();
                        var points = _polyline.first.points;
                        points.add(points.first);
                        _polyline.clear();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeasurementComplete(
                                      field: widget.field,
                                      measurement: points,
                                    )),
                            (route) => false);
                      },
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.stop, size: 35),
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
        });
  }
}
