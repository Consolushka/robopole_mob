import 'dart:convert';
import 'dart:async';
import 'package:robopole_mob/utils/classes.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'APIUri.dart';
import 'notifications.dart';

Future backgroundPostInspection(inputData) async {
  List inspections = jsonDecode(inputData["Inspections"]) as List;
  NotificationService _notificationService = NotificationService();
  var userToken = inputData!["UserToken"] as String;
  for (String inspection in inspections) {
    Inspection insp = Inspection.fromJson(jsonDecode(inspection));
    if (insp.PhotosNames!.isNotEmpty) {
      var request =
      http.MultipartRequest('POST', Uri.parse(APIUri.Content.SavePhotos));
      request.headers.addAll({"Authorization": userToken});
      for (var image in insp.PhotosNames!) {
        request.files
            .add(await http.MultipartFile.fromPath('picture', image));
      }

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if (responsed.statusCode != 200) {
        var error = Error.fromResponse(responsed);
        await _notificationService.showNotifications(
            "Ошибка при осмотре поля. ${error.Message}", NotificationService.Inspection);
        return Future.value(false);
      }
      final body =
      (json.decode(responsed.body) as List<dynamic>).cast<String>();
      insp.PhotosNames = body;
    }

    if (insp.VideoNames!.isNotEmpty) {
      var request =
      http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveVideos));
      request.headers.addAll({"Authorization": userToken});
      for (var image in insp.VideoNames!) {
        request.files.add(
            await http.MultipartFile.fromPath('file', image));
      }
      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if (responsed.statusCode != 200) {
        var error = Error.fromResponse(responsed);
        await _notificationService.showNotifications(
            "Ошибка при осмотре поля. ${error.Message}", NotificationService.Inspection);
        return Future.value(false);
      }
      final body =
      (json.decode(responsed.body) as List<dynamic>).cast<String>();
      insp.VideoNames = body;
    }

    if (insp.AudioName != null && insp.AudioName != "") {
      var request =
      http.MultipartRequest('POST', Uri.parse(APIUri.Content.SaveAudio));
      request.headers.addAll({"Authorization": userToken});
      request.files
          .add(
          await http.MultipartFile.fromPath('audio', insp.AudioName!));

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if (responsed.statusCode != 200) {
        var error = Error.fromResponse(responsed);
        await _notificationService.showNotifications(
            "Ошибка при осмотре поля. ${error.Message}", NotificationService.Inspection);
        return Future.value(false);
      }
      final body = responsed.body;
      insp.AudioName = body;
    }
    var jsoned = json.encode(insp);

    var response = await http.post(
        Uri.parse(APIUri.Inspection.AddInspection),
        headers: {
          "Content-Type": "application/json",
          "Authorization": userToken
        },
        body: jsoned);

    if (response.statusCode == 200) {
      final storage = const FlutterSecureStorage();
      storage.write(key: "isPostedInspectionsLengthIsNull", value: "1");
      await _notificationService.showNotifications(
          "Осмотр поля ${insp.FieldID} от ${insp.Date!.day.toString()}.${insp.Date!.month.toString()}.${insp.Date!.year.toString()} проведен", NotificationService.Inspection);
    } else {
      var error = Error.fromResponse(response);
      await _notificationService.showNotifications(
          "Ошибка при проведении осмотра поля. ${error.Message}", NotificationService.Inspection);
      return Future.value(false);
    }
  }
  return Future.value(true);
}

Future backgroundPostInventory(inputData) async {
  List inentory = jsonDecode(inputData["Inventory"]) as List;
  NotificationService _notificationService = NotificationService();
  var userToken = inputData!["UserToken"] as String;
  for (String invetn in inentory) {
    LocationInventory inv = LocationInventory.fromJson(
        jsonDecode(invetn));
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
        request.files.add(
            await http.MultipartFile.fromPath('file', image));
      }
      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      if (responsed.statusCode != 200) {
        var error = Error.fromResponse(responsed);
        await _notificationService.showNotifications(
            "Ошибка при проведении инвентаризации. ${error.Message}", NotificationService.Inventory);
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
          .add(
          await http.MultipartFile.fromPath('audio', inv.AudioName!));

      var res = await request.send();
      var responsed = await http.Response.fromStream(res);
      final body = responsed.body;
      inv.AudioName = body;
    }
    var jsoned = json.encode(inv);

    var response = await http.post(
        Uri.parse(APIUri.Inventory.AddInventory),
        headers: {
          "Content-Type": "application/json",
          "Authorization": userToken
        },
        body: jsoned);

    if (response.statusCode == 200) {
      final storage = const FlutterSecureStorage();
      storage.write(key: "isPostedInventoriesLengthIsNull", value: "1");
      await _notificationService.showNotifications(
          "Инвентаризация от ${inv.Date!.day.toString()}.${inv.Date!.month.toString()}.${inv.Date!.year.toString()} пройдена", NotificationService.Inventory);
    } else {
      var error = Error.fromResponse(response);
      await _notificationService.showNotifications(
          "Ошибка при проведении инвентаризации. ${error.Message}", NotificationService.Inventory);
      return Future.value(false);
    }
  }
  return Future.value(true);
}

Future backgroundPostMeasurement(inputData) async {
  List measurements = jsonDecode(inputData["Measurements"]) as List;
  NotificationService _notificationService = NotificationService();
  var userToken = inputData!["UserToken"] as String;
  for (String measureJson in measurements) {
    FieldMeasurement measure = FieldMeasurement.fromJson(
        jsonDecode(measureJson));

    var jsoned = json.encode(measure);

    var response = await http.post(
        Uri.parse(APIUri.Measurement.AddMeasurement),
        headers: {
          "Content-Type": "application/json",
          "Authorization": userToken
        },
        body: jsoned);

    if (response.statusCode == 200) {
      final storage = const FlutterSecureStorage();
      storage.write(key: "isPostedMeasurementsLengthIsNull", value: "1");
      await _notificationService.showNotifications(
          "Замер поля ${measure.FieldID} от ${measure.Date!.day.toString()}.${measure.Date!.month.toString()}.${measure.Date!.year.toString()} проведен", NotificationService.Measurement);
    } else {
      var error = Error.fromResponse(response);
      await _notificationService.showNotifications(
          "Ошибка при замере поля. ${error.Message}", NotificationService.Measurement);
      return Future.value(false);
    }
  }

  return Future.value(true);
}