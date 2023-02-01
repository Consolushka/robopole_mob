import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Field {
  late int LogId;
  late int LogYear;
  late int Id;
  late int PartnerId;
  late int UsingByPartnerId;
  late String PartnerName;
  late String UsingByPartnerName;
  late int LayerId;
  late String Name;
  late List<LatLng> Coords;
  late String KadastrNumber;
  late String ExternalName;
  late String GeoMesto;
  late String GeoStatus;
  late String GeoUsage;
  late String? GeoAction;
  late String GeoNote;
  late int AgroCultureId;
  late String AgroCultureName;
  late String PrevAgroCultureName;
  late bool IsActive;
  late double AgroSize;
  late double MapSize;
  late double CalculatedArea;
  late int KadastrFieldId;
  late int ForeignId;
  late String MapCenter;
  late String MapDate;
  late String LastUpdate;
  late int UserId;

  List? Works;
  List? DateSnapshots;
  List? Inspections;
  List? Measurements;

  Field(this.Id, this.PartnerId, this.LayerId, this.Coords);

  Field.fromJson(Map<String, dynamic> parsed){

    LogId = parsed["logID"];
    LogYear = int.parse(parsed["logYear"]);
    Id = parsed["id"];
    PartnerId = parsed["partnerID"];
    UsingByPartnerId = parsed["usingByPartnerID"];
    PartnerName = parsed["partnerName"];
    UsingByPartnerName = parsed["usingByPartnerName"];
    LayerId = parsed["layerID"];
    Name = parsed["name"];
    KadastrNumber = parsed["kadastrNumber"];
    ExternalName = parsed["externalName"];
    GeoMesto = parsed["geoMesto"];
    GeoStatus = parsed["geoStatus"];
    GeoUsage = parsed["geoUsage"];
    GeoAction = parsed["geoAction"];
    GeoNote = parsed["geoNote"];
    AgroCultureId = parsed["agroCultureID"];
    AgroCultureName = parsed["agroCultureName"];
    PrevAgroCultureName = parsed["prevAgroCultureName"];
    IsActive = parsed["isActive"];
    AgroSize = parsed["agroSize"];
    MapSize = parsed["mapSize"];
    CalculatedArea = parsed["calculatedArea"];
    KadastrFieldId = parsed["kadastrFieldID"];
    ForeignId = parsed["foreignID"];
    MapCenter = parsed["mapCenter"];
    MapDate = parsed["mapDate"];
    LastUpdate = parsed["lastUpdate"];
    UserId = parsed["userID"];

    var utfed = parsed["coordinates"];
    var cors = jsonDecode(utfed) as List;
    var cooooords = cors[0];
    if(cooooords.length==1){
      cooooords = cooooords[0];
    }
    Coords = [];
    cooooords.forEach((element) {
      var c = element;
      if (element[0] is double) {
        Coords.add(LatLng(c[1], c[0]));
      } else {
        c = element[0];
        Coords.add(LatLng(c[1], c[0]));
      }
    });
  }
}

class User {
  int? ID;
  String? Name;
  String? Token;
  bool? MobileAccess;
  int? RoleID;

  User(this.ID, this.Name, this.MobileAccess, this.RoleID, this.Token);

  User.fromJson(String json){
    final parsed = jsonDecode(json);

    ID = parsed['id'];
    Name = parsed['name'];
    RoleID = parsed['roleID'];
    MobileAccess = parsed["mobileAccess"];
    Token = parsed['token'];
  }

  Map toMap() {
    var res = Map();
    res["id"] = ID;
    res["name"] = Name;
    res["token"] = Token;
    res["roleID"] = RoleID;
    res["mobileAccess"] = MobileAccess;
    return res;
  }

  String toJson() => jsonEncode(toMap());
}

class Partner {
  int? ID;
  String? Name;

  Partner(this.ID, this.Name) {}

  Partner.fromMap(Map map){
    ID = map['id'];
    Name = map['name'];
  }

}

class Error {
  int? StatusCode;
  String? Message;
  String? Path;

  Error.fromResponse(response){
    try{
      Map parsed = jsonDecode(utf8.decode(response.bodyBytes));
      StatusCode = parsed["StatusCode"];
      Message = parsed["Message"];
      Path = parsed["Path"];
    }
    catch(e){
      Path = response.request!.url.path;

      Message = response.reasonPhrase;
    }
  }
}

class AgroCulture {
  int? ID;
  String? Name;
  bool? IsActive;
  String? Color;
  int? ParentID;
  int? Level;
  int? Order;

  AgroCulture.fromJson(json){
    Map parsed = jsonDecode(json);
    ID = parsed["id"];
    Name = parsed["name"];
    IsActive = parsed["isActive"];
    Color = parsed["color"];
    ParentID = parsed["parentID"];
    Level = parsed["level"];
    Order = parsed["order"];
  }

  AgroCulture.fromMap(map){
    ID = map["id"];
    Name = map["name"];
    IsActive = map["isActive"];
    Color = map["color"];
    ParentID = map["parentID"];
    Level = map["level"];
    Order = map["order"];
  }
}

class LocationInventory {
  int? ID;
  double? Lat;
  double? Lng;
  int? AgroCultureID;
  int? PartnerID;
  String? Comment;
  List<String>? PhotosNames;
  List<String>? VideoNames;
  String? AudioName;
  DateTime? Date;

  LocationInventory(this.ID, this.Lat, this.Lng, this.AgroCultureID, this.PartnerID,
      this.Comment, this.PhotosNames, this.AudioName, this.VideoNames){
    Date = DateTime.now();
  }

  Map toJson() {
    var encDate = Date!.toIso8601String();
    return {
      "id": ID,
      "lat": Lat,
      "lng": Lng,
      "agroCultureID": AgroCultureID,
      "partnerID": PartnerID,
      "comment": Comment,
      "photosNames": PhotosNames,
      "videoNames": VideoNames,
      "audioName": AudioName,
      "date": encDate
    };
  }

  LocationInventory.fromJson(Map<String, dynamic> json){
    ID=json["id"];
    Lat = json["lat"];
    Lng = json["lng"];
    AgroCultureID = json["agroCultureID"];
    PartnerID = json["partnerID"];
    Comment = json["comment"];
    // List<String> lst = List<String>.filled(1, "");
    PhotosNames = json["photosNames"].cast<String>();
    VideoNames = json["videoNames"].cast<String>();
    AudioName = json["audioName"];
    Date = DateTime.parse(json["date"]);
  }
}

class Inspection {
  int? ID;
  double? Lat;
  double? Lng;
  int? FieldID;
  String? Comment;
  List<String>? PhotosNames;
  List<String>? VideoNames;
  String? AudioName;
  DateTime? Date;

  Inspection(this.ID, this.Lat, this.Lng, this.FieldID,
      this.Comment, this.PhotosNames, this.AudioName, this.VideoNames){
    Date = DateTime.now();
  }

  Map toJson() {
    var encDate = Date!.toIso8601String();
    return {
      "id": ID,
      "lat": Lat,
      "lng": Lng,
      "fieldID": FieldID,
      "comment": Comment,
      "photosNames": PhotosNames,
      "audioName": AudioName,
      "videoNames": VideoNames,
      "date": encDate
    };
  }

  Inspection.fromJson(Map<String, dynamic> json){
    ID=json["id"];
    Lat = json["lat"];
    Lng = json["lng"];
    FieldID = json["fieldID"];
    Comment = json["comment"];
    // List<String> lst = List<String>.filled(1, "");
    PhotosNames = json["photosNames"].cast<String>();
    VideoNames = json["videoNames"].cast<String>();
    AudioName = json["audioName"];
    Date = DateTime.parse(json["date"]);
  }
}



class FieldMeasurement {
  int? ID;
  int? FieldID;
  List<LatLng>? CoordinatesList;
  double? Area;
  DateTime? Date;

  FieldMeasurement(this.ID, this.FieldID, this.CoordinatesList, this.Area){
    Date = DateTime.now();
  }

  Map toJson() {
    var encDate = Date!.toIso8601String();
    return {
      "id": ID,
      "fieldID": FieldID,
      "coordinatesList": CoordinatesList,
      "area": Area,
      "date": encDate
    };
  }

  FieldMeasurement.fromJson(Map<String, dynamic> json){
    ID=json["id"];
    FieldID = json["fieldID"];
    Area = json["area"];

    var lst = [];
    json["coordinatesList"].forEach((el)=>{
      lst.add(LatLng(el[0], el[1]))
    });
    CoordinatesList = lst.cast<LatLng>();
    Date = DateTime.parse(json["date"]);
  }
}