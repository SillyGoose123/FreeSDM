import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'command_page.dart';
import 'main.dart';

class MouseController extends StatefulWidget {
  final String ip;
  final String pin;
  const MouseController({super.key, required this.ip, required this.pin});


  @override
  State<StatefulWidget> createState() => _MouseControllerState();
}

class _MouseControllerState extends State<MouseController> {
  var _x = 0.0;
  var _y = 0.0;
  var step = 10;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Joystick(listener: (details) {
        print(details.x);
      })
    ],);
  }

  sendMouseCommand(String command) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var mouseSpeed = prefs.getInt("mouseSpeed") ?? 10;
      postRequest(widget.ip, widget.pin, "/mouse", "$command : $mouseSpeed");
    } catch (e) {
      showErrorDialog(context, "Failed to mouse command ${command}");
    }
  }

  sendScroll(int value) {

  }


}

class MouseCommand {
  static String up = "up";
  static String down = "down";

}