import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:robopole_mob/utils/classes.dart';
import 'package:robopole_mob/pages/measurementComplete.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MeasurementField extends StatefulWidget {
  Map? field;

  MeasurementField({Key? key, this.field}) : super(key: key);

  @override
  State<MeasurementField> createState() => _MeasurementFieldState();
}

class _MeasurementFieldState extends State<MeasurementField> {
  LatLng? _userLocation = null;
  final Set<Polyline> _polyline = Set();
  final Set<Polygon> _polygon = Set();

  User? user;

  StreamSubscription<LocationData>? locationSubscription = null;

  @override
  void initState() {
    _getUserLocation();

    if (widget.field != null) {
      var cooooords = jsonDecode(widget.field!["coordinates"])[0];
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
      });

      _polygon.add(Polygon(
          polygonId: PolygonId('asd'),
          points: polygonCoords,
          strokeWidth: 1,
          strokeColor: Colors.deepOrangeAccent,
          fillColor: Colors.amberAccent.withOpacity(0.5),
          consumeTapEvents: true));
    }
    super.initState();
  }

  void _getUserLocation() async {
    Location location = Location();
    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (locationSubscription != null) {
      locationSubscription!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Замер поля ${widget.field == null ? "" : widget.field!["id"]}"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: _userLocation == null
          ? SpinKitRing(
              color: Colors.deepOrangeAccent,
              size: 100,
            )
          : GoogleMap(
              mapType: MapType.hybrid,
              polylines: _polyline,
              polygons: _polygon,
              initialCameraPosition:
                  CameraPosition(target: _userLocation!, zoom: 16),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false),
      floatingActionButton: locationSubscription == null
          ? FloatingActionButton(
              heroTag: "start",
              onPressed: () async {
                _polyline.add(Polyline(
                    polylineId: PolylineId("asdsd"),
                    width: 3,
                    color: Colors.blueAccent,
                    visible: true,
                    points: <LatLng>[]));
                Location location = Location();
                locationSubscription = location.onLocationChanged
                    .listen((LocationData locationData) {
                  var latlng =
                      LatLng(locationData.latitude!, locationData.longitude!);
                  if (!_polyline.first.points.contains(latlng)) {
                    _polyline.first.points.add(latlng);
                    setState(() {});
                  }
                });
                // locationSubscription.resume();
                setState(() {});
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.play_arrow, size: 35),
            )
          : FloatingActionButton(
              heroTag: "stop",
              onPressed: () async {
                locationSubscription!.cancel();
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
  }
}
