import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:robopole_mob/utils/classes.dart';
import 'dart:io';

import 'classes.dart' as CL;
import 'APIUri.dart';

class LocalStorage{
  static final storage = const FlutterSecureStorage();

  static Future<CL.User> User () async {
    return CL.User.fromJson(await storage.read(key: "User") as String);
  }

  static Future WriteUser(CL.User user) async {
    await storage.write(key: "User", value: user.toJson());
  }

  static Future<List> Fields() async {
    var user = await User();

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

  static Future<List> UpdateFields() async {
    var user = await User();

    var fieldsStorage = await storage.read(key: "Fields");
    String fieldsJson = "";

    var availableFields = await http.post(
        Uri.parse(APIUri.Field.UpdateFields),
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

    return jsonDecode(fieldsJson) as List;
  }

  static Future<List> Cultures () async {
    var user = await User();

    var culturesStored = await storage.read(key: "Cultures");
    String culturesJson = "";
    if (culturesStored == null) {
      var response = await http.get(Uri.parse(APIUri.Cultures.AllCultures),
          headers: {"Authorization": user.Token as String});
      if (response.statusCode == 200) {
        culturesJson = response.body;
        await storage.write(key: "Cultures", value: response.body);
      }
      else{
          var error = Error.fromResponse(response);
          throw Exception(error);
      }
    } else {
      culturesJson = culturesStored;
    }

    List<AgroCulture> availableCultures = [];
    (jsonDecode(culturesJson) as List).forEach((element) {
      availableCultures.add(AgroCulture.fromMap(element));
    });

    return availableCultures;
  }

  static Future<List> Partners () async {
    var partnersStorage = await storage.read(key: "Partners");
    String partnersJson = "";
    var user = await User();

    if (partnersStorage == null) {
      var part =
      await http.get(Uri.parse(APIUri.Partner.AvailablePartners), headers: {
        HttpHeaders.authorizationHeader: user.Token as String,
      });
      if (part.statusCode == 200) {
        partnersJson = part.body;
        await storage.write(key: "Partners", value: part.body);
      } else {
        var error = Error.fromResponse(part);
        throw Exception(error.Message);
      }
    } else {
      partnersJson = partnersStorage;
    }

    return jsonDecode(partnersJson) as List;
  }

  static Future ClearAll() async {
    await storage.delete(key: "User");
    await storage.delete(key: "Partners");
    await storage.delete(key: "Cultures");
    await storage.delete(key: "Fields");
  }

  static Future RestoreData() async {
    await storage.delete(key: "Partners");
    await storage.delete(key: "Cultures");
    await storage.delete(key: "Fields");
    await UpdateFields();
    await Cultures();
    await Partners();
  }

  static Future<bool> GetBooleanValue (String key) async {
    return await storage.read(
        key: key) ==
        "1";
  }

  static Future SetTrueValue(String key) async {
    await storage.write(
        key: key,
        value: "1");
  }

  static Future SetFalseValue (String key) async {
    await storage.write(
        key: key,
        value: "0");
  }
}