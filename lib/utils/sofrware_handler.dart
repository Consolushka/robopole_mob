import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:robopole_mob/utils/storageUtils.dart';
import 'package:location/location.dart';
import 'dart:convert';

class Software{
  static Future<Map> FindFieldByLocation () async {
    Map currentField = Map();

    Location location = Location();
    final userLocation = await location.getLocation();
    var fields = List.empty();
    try {
      fields = await LocalStorage.Fields();
    } catch (ex) {
      throw ex;
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
      });
      var j = polygonCoords.length - 1;
      for (int i = 0; i < polygonCoords.length; i++) {
        if ((polygonCoords[i].longitude < userLocation.longitude! &&
            polygonCoords[j].longitude >= userLocation.longitude! ||
            polygonCoords[j].longitude < userLocation.longitude! &&
                polygonCoords[i].longitude >= userLocation.longitude!) &&
            (polygonCoords[i].latitude +
                (userLocation.longitude! - polygonCoords[i].longitude) /
                    (polygonCoords[j].longitude -
                        polygonCoords[i].longitude) *
                    (polygonCoords[j].latitude -
                        polygonCoords[i].latitude) <
                userLocation.latitude!)) result = !result;
        j = i;
      }

      if (result) {
        currentField = field;
        currentField["coords"] = polygonCoords;
      }

    }
    return currentField;
  }


  static Future<LatLng> getUserLocation() async {
    Location location = Location();
    final _locationData = await location.getLocation();
    return LatLng(_locationData.latitude!, _locationData.longitude!);
  }
}