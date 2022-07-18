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

  Map toJson()=>{
    "ID": ID,
    "Name": Name,
    "RoleId": RoleID,
    "MobileAccess": MobileAccess
  };
}

class Partner{
  int ID;
  String Name;

  Partner(this.ID, this.Name){}
}