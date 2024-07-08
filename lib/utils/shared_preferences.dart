import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;
  SharedPreferences get sharedPrefs => _sharedPrefs;

  init() async {

    _sharedPrefs = await SharedPreferences.getInstance();
  }

  //String get device_token => _sharedPrefs.getString("device_token") ?? "";

  void removeWalletAddress() {
    _sharedPrefs.remove("walletAddress");
  }

  void setStringSp(String title, String value) {
    _sharedPrefs.setString(title, value);
  }

  String getStringSp(String title) {
    return _sharedPrefs.getString(title) ?? "";
  }

  void setIntSp(String title, int value) {
    _sharedPrefs.setInt(title, value);
  }

  int getIntSp(String title) {
    return _sharedPrefs.getInt(title) ?? 0;
  }

  void setDoubleSp(String title, double value) {
    _sharedPrefs.setDouble(title, value);
  }

  double getDoubleSp(String title) {
    return _sharedPrefs.getDouble(title) ?? 0.0;
  }

  void setBoolSp(String title, bool value) {
    _sharedPrefs.setBool(title, value);
  }

  bool getBoolSp(String title) {
    return _sharedPrefs.getBool(title) ?? true;
  }

  bool getBoolDefaultFalseSp(String title) {
    return _sharedPrefs.getBool(title) ?? false;
  }

  void setStringListSp(String title, List<String> value) {
    _sharedPrefs.setStringList(title, value);
  }

  List<String> getStringListSp(String title) {
    return _sharedPrefs.getStringList(title) ?? [];
  }
}

final sp = SharedPrefs();
