import 'package:shared_preferences/shared_preferences.dart';

Future<String> getCurrUid() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.get("uid") == null ? "" : prefs.get("uid").toString();
}

Future<bool> setCurrId(String uid) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString("uid", uid);

  return true;
}
