import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:freesdm/commands.dart';
import 'package:freesdm/freesdm_icons.dart';
import 'package:freesdm/main.dart';
import 'package:freesdm/settings_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:freesdm/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mouse_controller.dart';

class CommandPage extends StatefulWidget {
  final String ip;
  final String pin;

  const CommandPage({super.key, required this.ip, required this.pin});

  @override
  CommandPageState createState() => CommandPageState();
}

class CommandPageState extends State<CommandPage> {
  @override
  initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      _checkConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: Colors.white10,
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white10,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: "Standard",
          ),
          BottomNavigationBarItem(
              label: "PowerPoint",
              icon: FreeSDMIcon.powerpoint,
              activeIcon: FreeSDMIcon.powerpointActive),
          BottomNavigationBarItem(
              label: "Netflix",
              icon: FreeSDMIcon.netflix,
              activeIcon: FreeSDMIcon.netflixActive),
          BottomNavigationBarItem(
              label: "YouTube",
              icon: FreeSDMIcon.youtube,
              activeIcon: FreeSDMIcon.youtubeActive),
          const BottomNavigationBarItem(
            label: "Settings",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return _buildTab(index);
      },
    );
  }

  CupertinoTabView _buildTab(int index) {
    return CupertinoTabView(
      builder: (BuildContext context) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: _buildAllTabs(index));
      },
    );
  }

  Widget _buildAllTabs(int index) {
    switch (index) {
      case 1:
        return _buildPowerPointTab();

      case 2:
        return _buildNetflix();

      case 3:
        return _buildYouTube();

      case 4:
        return SettingsPage(
            name: widget.ip, commandPage: true, completeContext: context);

      default:
        return _buildStandard();
    }
  }

  Widget _buildStandard() {
    return const Text("Standard");
  }

  Widget _buildPowerPointTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
      Row(
          children: [
            IconButton(
              onPressed: () => executeHotkey(PowerPoint.previousSlide),
              icon: const Icon(Icons.arrow_back_ios),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.only(
                        top: 50, bottom: 50, left: 50, right: 50)),
                iconSize: MaterialStateProperty.all<double>(50),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueAccent),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () => executeHotkey(PowerPoint.nextSlide),
                icon: const Icon(Icons.arrow_forward_ios),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          top: 50, bottom: 50, left: 50, right: 50)),
                  iconSize: MaterialStateProperty.all<double>(50),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                )),
          ],
        ),
        Padding(padding: const EdgeInsets.only(top: 65), child: IconButton(
          onPressed: () => executeHotkey(PowerPoint.startPresentation),
          icon: const Icon(Icons.start_rounded),
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.only(
                    top: 50, bottom: 50, left: 50, right: 50)),
            iconSize: MaterialStateProperty.all<double>(50),
            backgroundColor:
            MaterialStateProperty.all<Color>(Colors.blueAccent),
          ),
        ))
      ],
    );
  }

  Widget _buildNetflix() {
    return const Text("Netflix");
  }

  Widget _buildYouTube() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        MouseController(ip: widget.ip, pin: widget.pin),
        Row(
          children: [
            IconButton(
              onPressed: () => executeHotkey(Youtube.skipBack),
              icon: const Icon(Icons.arrow_back_ios),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.only(
                        top: 25, bottom: 25, left: 25, right: 25)),
                iconSize: MaterialStateProperty.all<double>(50),
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.blueAccent),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => executeHotkey(Youtube.playPause),
              icon: const Icon(CupertinoIcons.playpause),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.only(
                        top: 25, bottom: 25, left: 25, right: 25)),
                iconSize: MaterialStateProperty.all<double>(50),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () => executeHotkey(Youtube.skip),
                icon: const Icon(Icons.arrow_forward_ios),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.only(
                          top: 25, bottom: 25, left: 25, right: 25)),
                  iconSize: MaterialStateProperty.all<double>(50),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blueAccent),
                )),
          ],
        ),
        Padding(padding: const EdgeInsets.all(25), child: IconButton(
          onPressed: () => executeHotkey(Youtube.fullscreen),
          icon: const Icon(Icons.fullscreen),
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.only(
                    top: 25, bottom: 25, left: 25, right: 25)
            ),
            iconSize: MaterialStateProperty.all<double>(50),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
          ),
        )),
      ],
    );
  }

  _checkConnection() async {
    final response = await makeReq(widget.ip, "/connected");
    if (response.statusCode == 200 && response.body == "true" && mounted) {
      Timer(const Duration(seconds: 1), () {
        _checkConnection();
      });
      return;
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  makeReq(String ip, String route) async {
    try {
      final Settings settings = await Settings(name: ip).loadData();
      if (!route.startsWith("/")) {
        route = "/$route";
      }
      var response = await http
          .get(Uri.parse("http://$ip:${settings.port}$route"), headers: {
        HttpHeaders.authorizationHeader: widget.pin
      }).timeout(const Duration(seconds: 5));

      return response;
    } catch (e) {
      return http.Response("error: $e", 500);
    }
  }


  void executeHotkey(Command command) async {
    command.loadKey();

    try {
      postRequest(widget.ip, widget.pin, "/hotkey", command.hotkey.toString());
    } catch (e) {
      showErrorDialog(context, "Failed to send hotkey ${command.name}");
    }
  }

}


void postRequest(String ip, String pin, String route, String body) async {
  final Settings settings = await Settings(name: ip).loadData();
  final response = await http.post(Uri.parse("http://${ip}:${settings.port}$route"), headers: {
    HttpHeaders.authorizationHeader: pin
  }, body: body
  ).timeout(const Duration(seconds: 5));

  if (response.statusCode != 200 || !response.body.contains("true")) {
    throw "Failed to send hotkey $body";
  }
}