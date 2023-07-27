import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService{
  static late SharedPreferences _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get sharedPreferences => _sharedPreferences;

  static Future<void> setAuthKey(String key) async {
    await _sharedPreferences.setString('auth-token', key);
  }
  static Future<void> deleteAuthKey() async {
    await _sharedPreferences.remove('auth-token');
  }
}