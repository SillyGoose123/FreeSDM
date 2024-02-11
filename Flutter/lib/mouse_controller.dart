import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

import 'package:holding_gesture/holding_gesture.dart';
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
  Widget content = const Text("Mouse Controller loading...");

  @override
  void initState() {
    super.initState();
    getContent();
  }

  @override
  Widget build(BuildContext context) {
    return content;
  }

  Future<void> getContent() async {
    var prefs = await SharedPreferences.getInstance();
    var joystick = prefs.getBool("joystick") ?? true;

    setState(() {
      if(joystick) {
        content = Column(children: [
          Joystick(listener: (details) {
            if(details.x > 0.5) {
              sendMouseCommand("right");
            } else if(details.x < -0.5) {
              sendMouseCommand("left");
            } else if (details.y > 0.5) {
              sendMouseCommand("down");
            } else if(details.y < -0.5) {
              sendMouseCommand("up");
            }
          }),
         Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.up_arrow),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          top: 25, bottom: 25, left: 25, right: 25)),
                  iconSize: MaterialStateProperty.all<double>(50),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blueAccent),
                ), onPressed: () => sendScroll(Direction.up),
              ),
              Padding(padding: const EdgeInsets.all(15), child:
              IconButton(
                icon: const Icon(CupertinoIcons.cursor_rays),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          top: 25, bottom: 25, left: 25, right: 25)),
                  iconSize: MaterialStateProperty.all<double>(50),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blueAccent),
                ), onPressed: () {
                try {
                  postRequest(widget.ip, widget.pin, "/click", "left");
                } catch (e) {
                  showErrorDialog(context, "Failed to click.");
                }
              },
              ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.down_arrow),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          top: 25, bottom: 25, left: 25, right: 25)),
                  iconSize: MaterialStateProperty.all<double>(50),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blueAccent),
                ), onPressed: () => sendScroll(Direction.down),
              ),
            ],
          )
        ]);
      } else {
        content = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child:  Column(children: [
                  Row(
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.up_arrow),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.only(
                                top: 25, bottom: 25, left: 25, right: 25)),
                        iconSize: MaterialStateProperty.all<double>(50),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                      ), onPressed: () => sendScroll(Direction.up),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 15, right: 15), child: HoldDetector(
                        onHold: () => sendMouseCommand("up"),
                        holdTimeout: const Duration(milliseconds: 50),
                        enableHapticFeedback: true,
                        child:  IconButton(
                          icon: const Icon(CupertinoIcons.up_arrow),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.only(
                                    top: 25, bottom: 25, left: 25, right: 25)),
                            iconSize: MaterialStateProperty.all<double>(50),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
                          ), onPressed: () => sendMouseCommand("up"),
                        )
                    )),
                    IconButton(
                      icon: const Icon(CupertinoIcons.down_arrow),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.only(
                                top: 25, bottom: 25, left: 25, right: 25)),
                        iconSize: MaterialStateProperty.all<double>(50),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                      ), onPressed: () => sendScroll(Direction.down),
                    )
                  ]),
                  Row(
                    children: [
                    HoldDetector(
                        onHold: () => sendMouseCommand("left"),
                        holdTimeout: const Duration(milliseconds: 50),
                        enableHapticFeedback: true,
                        child:  IconButton(
                          icon: const Icon(CupertinoIcons.arrow_left),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.only(
                                    top: 25, bottom: 25, left: 25, right: 25)),
                            iconSize: MaterialStateProperty.all<double>(50),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
                          ), onPressed: () => sendMouseCommand("left"),
                        )
                    ),
                    Padding(padding: const EdgeInsets.all(15), child: IconButton(
                      icon: const Icon(Icons.ads_click),
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.only(
                                top: 25, bottom: 25, left: 25, right: 25)),
                        iconSize: MaterialStateProperty.all<double>(50),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                      ), onPressed: () {
                      try {
                        postRequest(widget.ip, widget.pin, "/click", "left");
                      } catch (e) {
                        showErrorDialog(context, "Failed to click.");
                      }
                    },
                    )),
                    HoldDetector(
                        onHold: () => sendMouseCommand("right"),
                        holdTimeout: const Duration(milliseconds: 50),
                        enableHapticFeedback: true,
                        child:  IconButton(
                          icon: const Icon(CupertinoIcons.arrow_right),
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.only(
                                    top: 25, bottom: 25, left: 25, right: 25)),
                            iconSize: MaterialStateProperty.all<double>(50),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
                          ), onPressed: () => sendMouseCommand("right"),
                        )
                    ),
                  ],),
                  HoldDetector(
                      onHold: () => sendMouseCommand("down"),
                      holdTimeout: const Duration(milliseconds: 50),
                      enableHapticFeedback: true,
                      child:  IconButton(
                        icon: const Icon(CupertinoIcons.down_arrow),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.only(
                                  top: 25, bottom: 25, left: 25, right: 25)),
                          iconSize: MaterialStateProperty.all<double>(50),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blueAccent),
                        ), onPressed: () => sendMouseCommand("down"),
                      )
                  ),
                ]
                ),
              ),
            ]
        );
      }
    });
  }


  sendMouseCommand(String command) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      postRequest(widget.ip, widget.pin, "/mouse",
          "$command : ${prefs.getInt("mouseSpeed") ?? 20}");
    } catch (e) {
      showErrorDialog(context, "Failed to mouse command ${command}");
    }
  }

  sendScroll(Direction direction) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var mouseSpeed = prefs.getInt("scrollSpeed") ?? 5;

      if (direction == Direction.up) {
        mouseSpeed = -mouseSpeed;
      }

      postRequest(widget.ip, widget.pin, "/scroll", "$mouseSpeed");
    } catch (e) {
      showErrorDialog(context, "Failed to scroll.");
    }
  }
}

enum Direction {
  up,
  down,
}
