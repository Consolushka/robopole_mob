import 'dart:convert';

class User{
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

  Map toMap(){
    var res = Map();
    res["id"] = ID;
    res["name"] = Name;
    res["token"] = Token;
    res["roleID"] = RoleID;
    res["mobileAccess"] = MobileAccess;
    return res;
  }
  String toJson()=>jsonEncode(toMap());
}

class Partner{
  int? ID;
  String? Name;

  Partner(this.ID, this.Name){}

  Partner.fromMap(Map map){
    ID = map['id'];
    Name = map['name'];
  }

}

class Error{
  int? StatusCode;
  String? Message;
  String? Path;

  Error.fromResponse(response){
    Map parsed = jsonDecode(utf8.decode(response.bodyBytes));

    StatusCode = parsed["StatusCode"];
    Message = parsed["Message"];
    Path = parsed["Path"];
  }
}

class AgroCulture{
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