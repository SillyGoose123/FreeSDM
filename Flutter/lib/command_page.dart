import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freesdm/freesdm_icons.dart';
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
  get _context => context;

  @override
  Widget build(BuildContext context) {
    _checkConnection();
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
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

      default:
        return _buildStandard();
    }
  }

  Widget _buildStandard() {
    return const Text("Standard");
  }

  Widget _buildPowerPointTab() {
    return Padding(padding: EdgeInsets.only(top: 5), child: Row(

      children: [
        IconButton(onPressed: () {
        sendCommand("back");
      }, icon: const Icon(Icons.arrow_back_ios),
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.only(top: 50, bottom: 50, left: 50, right: 50)),
          iconSize: MaterialStateProperty.all<double>(50),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
        ),),
        const Spacer(),
        IconButton(onPressed: () {
          sendCommand("next");
        },
            icon: const Icon(Icons.arrow_forward_ios),
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.only(top: 50, bottom: 50, left: 50, right: 50)),
            iconSize: MaterialStateProperty.all<double>(50),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
          ),
    ),

      ],
    ));
  }

  Widget _buildNetflix() {
    return const Text("Netflix");
  }

  Widget _buildYouTube() {
    return const Text("YouTube");
  }

  _checkConnection() async {
    print("checkConnection");
    final response = await makeReq(widget.ip, "/connected");
    print(response.body);
    if(response.statusCode == 200 && response.body == "true" && context.mounted) {
      Timer(const Duration(seconds: 1), () {
        _checkConnection();
      });
      return;
    }

    Navigator.pop(_context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_context', _context));
    properties.add(DiagnosticsProperty('_context', _context));
  }

  sendCommand(String command) async {
    try {
      final Settings settings = await Settings().loadData();

      var response = await http.post(
          Uri.parse("http://${widget.ip}:${settings.port}/command"),
          headers: {
            HttpHeaders.authorizationHeader: widget.pin
          },
          body: command
      ).timeout(const Duration(seconds: 5));

      return response;
    } catch (e) {
      print(e);
      return http.Response("error: $e", 500);
    }
  }


  makeReq(String ip, String route) async {
    try {
        final Settings settings = await Settings().loadData();
        if(!route.startsWith("/")) {
          route = "/$route";
        }
        var response = await http.get(
            Uri.parse("http://$ip:${settings.port}$route"),
            headers: {
              HttpHeaders.authorizationHeader: widget.pin
            }

        ).timeout(const Duration(seconds: 5));

        return response;
    } catch (e) {
      return http.Response("error: $e", 500);
    }
  }



}
