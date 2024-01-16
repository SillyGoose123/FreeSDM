import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freesdm/commands.dart';
import 'package:freesdm/freesdm_icons.dart';
import 'package:freesdm/settings_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:freesdm/settings.dart';

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
              onPressed: () {},
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
                onPressed: () {},
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
          onPressed: () {},
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
    return const Text("YouTube");
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_context', context));
    properties.add(DiagnosticsProperty('_context', context));
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

  void excetuteHotkey(Command command) async {
    print("hotkey: ${command.toString()}");
  }
}
