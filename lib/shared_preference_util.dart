import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  /// сохранить данные
  static saveData<T>(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  /// Чтение данных
  static Future<String> getData<T>(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String res = '';
    switch (T) {
      case String:
        res = prefs.getString(key).toString();
        break;
      case int:
        res = prefs.getInt(key).toString();
        break;
      case bool:
        res = prefs.getBool(key).toString();
        break;
      case double:
        res = prefs.getDouble(key).toString();
        break;
    }
    return res;
  }
}