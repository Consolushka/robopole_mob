String APIHost = "http://devapi.robopole.ru";
// String APIHost = "http://192.168.1.10:7196";

String APIVersion = "/v2";
String CulturesController = "/cultures";
String UserController = "/user";
String PartnerController = "/partners";
String FieldController = "/fields";
String InventoryController ="/inventories";
String FieldInspectionController = "/fieldinspections";
String FieldMeasurementController = "/fieldmeasurement";

class APIUri{
  static _UserController User= _UserController();
  static _PartnerController Partner = _PartnerController();
  static _FieldController Field = _FieldController();
  static _CulturesController Cultures = _CulturesController();
  static _InventoryController Inventory = _InventoryController();
  static _FieldInspectionController Inspection = _FieldInspectionController();
  static _ContentController Content = _ContentController();
  static _FieldMeasurement Measurement = _FieldMeasurement();
}

class _UserController{
  static String route = "$APIHost$APIVersion$UserController";
  String Authenticate = "$route/authenticate";
}

class _PartnerController{
  static String route = "$APIHost$APIVersion$PartnerController";
  String AvailablePartners = "$route";
}

class _FieldController{
  static String route = "$APIHost$APIVersion$FieldController";
  String AvailableFields = "$route";
  String UpdateFields = "$route";
  static String FieldData(int id, int year){
    return "$route/$id?year=$year";
  }
}

class _CulturesController{
  static String route = "$APIHost$APIVersion$CulturesController";
  String AllCultures = "$route";
}

class _InventoryController{
  static String route = "$APIHost$APIVersion$InventoryController";
  String AddInventory = "$route";
}

class _FieldInspectionController{
  static String route = "$APIHost$APIVersion$FieldInspectionController";
  String AddInspection = "$route";
}

class _FieldMeasurement{
  static String route="$APIHost$APIVersion$FieldMeasurementController";
  String AddMeasurement = "$route";
}

class _ContentController{
  static String route = "$APIHost$APIVersion";
  String SavePhotos = "$route/photo";
  String SaveAudio = "$route/audio";
  String SaveVideos = "$route/video";
}