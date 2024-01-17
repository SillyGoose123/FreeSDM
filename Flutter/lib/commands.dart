import 'package:shared_preferences/shared_preferences.dart';

class Commands {

}

class PowerPoint {
  static Command nextSlide = Command(name: "nextSlide");
  static Command previousSlide = Command(name: "previousSlide");
  static Command startPresentation = Command(name: "startPresentation");
}

class Youtube {
  static Command skip = Command(name: "skip");
  static Command skipBack = Command(name: "skipBack");
  static Command fullscreen = Command(name: "fullscreen");
  static Command playPause = Command(name: "playPause");
  static Command mute = Command(name: "mute");

}

class Mouse {
  static Command leftClick = Command(name: "leftClick");
  static Command rightClick = Command(name: "rightClick");
  static Command middleClick = Command(name: "middleClick");
  static Command up = Command(name: "up");
  static Command down = Command(name: "down");
  static Command left = Command(name: "left");
  static Command right = Command(name: "right");
}

class Command {
  final String name;
  String? hotkey = null;

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
    var string = "";

    string += "name: $name Hotkey: ";

    if(hotkey != null) {
      string += hotkey!;
    } else {
      string += "null";
    }

    return string;
  }
}

class _StandardCommand {
  final Map<String, String> standards = {
    "nextSlide": "right",
    "previousSlide": "left",
    "startPresentation": "F5",
    "skip": "right",
    "skipBack": "left",
    "fullscreen": "f",
    "playPause": "k",
    "mute" : "m"
  };
  final String name;

  _StandardCommand({required this.name});

  String? get() {
    return standards[name];
  }
}
