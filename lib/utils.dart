String APIHost = "http://devapi.robopole.ru";
String APIVersion = "/v1";
String UserController = "/user";
String PartnerController = "/partner";
String FieldController = "/field";
String InventoryController ="/locationinventory";

class APIUri{
  static _UserController User= _UserController();
  static _PartnerController Partner = _PartnerController();
  static _FieldController Field = _FieldController();
  static _InventoryController Inventory = _InventoryController();
}

class _UserController{
  static String route = "$APIHost$APIVersion$UserController";
  String Authenticate = "$route/authenticate";
}

class _PartnerController{
  static String route = "$APIHost$APIVersion$PartnerController";
  String AvailablePartners = "$route/get-available-partners";
}

class _FieldController{
  static String route = "$APIHost$APIVersion$FieldController";
  String AvailableFields = "$route/get-available-fieldsCoords-byUser";
  // static String FieldData = "$route/"
}

class _InventoryController{
  static String route = "$APIHost$APIVersion$InventoryController";
  String AllCultures = "$route/get-all-cultures";
  String SavePhotos = "$route/save-photos";
  String AddInventory = "$route/add-inventory";
}