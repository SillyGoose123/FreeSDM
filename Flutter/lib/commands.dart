import 'package:shared_preferences/shared_preferences.dart';

class Commands {

}

class PowerPoint {
  static Command nextSlide = Command(name: "nextSlide");
  static Command previousSlide = Command(name: "previousSlide");
  static Command startPresentation = Command(name: "startPresentation");
}

class Command {
  final String name;
  late String? hotkey;

  Command({required this.name});

  loadKey() async {
    var prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey(name)) {
      hotkey = _StandardCommand(name: name).get();

      if(hotkey == null) {
        throw "Key with name $name does not exists.";
      }

      return;
    }

    hotkey = prefs.getString(name);
  }

  setKey() async {
    if(hotkey != _StandardCommand(name: name).get()) {
      var prefs = await SharedPreferences.getInstance();
      prefs.setString(name, hotkey!);
    }
  }

  @override
  String toString() {
    return "Name: $name Hotkey: $hotkey";
  }
}

class _StandardCommand {
  final Map<String, String> standards = {
    "nextSlide": "arrow_right",
    "previousSlide": "arrow_left",
    "startPresentation": "F5"
  };
  final String name;

  _StandardCommand({required this.name});

  String? get() {
    return standards[name];
  }
}
