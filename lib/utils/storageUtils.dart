import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'classes.dart';
import 'APIUri.dart';

Future<List> getFieldsFromStorage() async {
  final storage = const FlutterSecureStorage();
  var fieldsStorage = await storage.read(key: "Fields");
  var fields = jsonDecode(fieldsStorage as String) as List;
  return fields;
}

Future<List> requestForFields() async {
  final storage = const FlutterSecureStorage();
  var user = User.fromJson(await storage.read(key: "User") as String);

  var fieldsStorage = await storage.read(key: "Fields");
  String fieldsJson = "";

  if(fieldsStorage == null){
    debugPrint("empty storage");
    var availableFields = await http.get(
        Uri.parse(APIUri.Field.AvailableFields),
        headers: {
          HttpHeaders.authorizationHeader: user.Token as String,
        }
    );

    if(availableFields.statusCode != 200){
      var error = Error.fromResponse(availableFields);
      throw Exception(error);
    }

    fieldsJson = availableFields.body;
    await storage.write(key: "Fields", value: fieldsJson);
  }
  else{
    fieldsJson = fieldsStorage;
  }

  return jsonDecode(fieldsJson) as List;
}

Future<LatLng> getUserLocation() async {
  Location location = Location();
  final _locationData = await location.getLocation();
  return LatLng(_locationData.latitude!, _locationData.longitude!);
}

Future<Map> findField(LatLng userLocation) async {
  Map currentField = Map();

  var fields = List.empty();
  try {
    fields = await requestForFields();
  } catch (ex) {
    throw ex;
  }
  bool isFounded = false;
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
      if ((polygonCoords[i].longitude < userLocation.longitude &&
          polygonCoords[j].longitude >= userLocation.longitude ||
          polygonCoords[j].longitude < userLocation.longitude &&
              polygonCoords[i].longitude >= userLocation.longitude) &&
          (polygonCoords[i].latitude +
              (userLocation.longitude - polygonCoords[i].longitude) /
                  (polygonCoords[j].longitude -
                      polygonCoords[i].longitude) *
                  (polygonCoords[j].latitude -
                      polygonCoords[i].latitude) <
              userLocation.latitude)) result = !result;
      j = i;
    }

    if (result) {
      currentField = field;
      currentField["coords"] = polygonCoords;
      isFounded = true;
      // Future.microtask(() => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => PassportField(currentField["id"]))));
    }

  }
  return currentField;
}