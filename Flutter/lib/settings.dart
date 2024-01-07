import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  late final int port;

   loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey("port")) {
      prefs.setInt("port", 8000);
    }

    port = prefs.getInt("port")!;

    return this;
  }
}