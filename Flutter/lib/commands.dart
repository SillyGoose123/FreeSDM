class PowerPoint {
  Command nextSlide = Command("Next Slide");
  Command previousSlide = Command("Previous Slide");
  Command startPresentation = Command("Start Presentation");


}

class Command {
  final String name;
  Hotkey hotkey;

  Command( this.name, this.hotkey);

  loadKey() async {

  }

}

class Hotkey {
  List<String> key;
  List<String> modifier;

  Hotkey(this.key, this.modifier);

  @override
  String toString() {
    String result = "";
    for (var i = 0; i < modifier.length; i++) {
      result += modifier[i];
      if (i != modifier.length - 1) {
        result += " + ";
      }
    }

    for (var i = 0; i < key.length; i++) {
      result += key[i];
      if (i != key.length - 1) {
        result += " + ";
      }
    }

    return result;
  }

  Future<Hotkey> loadKey(String key) async {

  }
}

