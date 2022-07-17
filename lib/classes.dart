import 'dart:convert';

class User{
  int? ID;
  String? Name;
  bool? IsActive;
  String? Login;
  String? Password;
  int? RoleId;
  bool? MobileAccess;

  User(String json){
    try{
      Map parsed = jsonDecode(jsonDecode(json));

      ID = parsed["ID"];
      Name = parsed["Name"];
      IsActive = parsed["IsActive"];
      Login = parsed["Login"];
      Password = parsed["Password"];
      RoleId = parsed["RoleID"];
      MobileAccess = parsed["MobileAccess"];
    }
    catch(e){
      return;
    }
  }

  User.fromJson(string){
    Map parsed = jsonDecode(string);


    ID = parsed["ID"];
    Name = parsed["Name"];
    IsActive = parsed["IsActive"];
    Login = parsed["Login"];
    Password = parsed["Password"];
    RoleId = parsed["RoleID"];
    MobileAccess = parsed["MobileAccess"];
  }

  Map toJson()=>{
    "ID": ID,
    "Name": Name,
    "IsActive": IsActive,
    "Login": Login,
    "Password": Password,
    "RoleId": RoleId,
    "MobileAccess": MobileAccess
  };
}

class Partner{
  int ID;
  String Name;

  Partner(this.ID, this.Name){}
}