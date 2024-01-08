import 'dart:async';
import 'dart:io';
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
      default:
        return _buildStandard();
    }
  }

  Widget _buildStandard() {
    return const Text("Standard");
  }

  Widget _buildPowerPointTab() {
    return const Text("PowerPoint");
  }

  _checkConnection() async {
    final response = await makeReq(widget.ip, "/checkConnection");
    if(response.statusCode == 200) {
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

  makeReq(String ip, String route) async {
    try {
        final Settings settings = await Settings().loadData();
        var response = await http.get(
            Uri.parse("http://$ip:${settings.port}route"),
            headers: {
              HttpHeaders.authorizationHeader: widget.pin
            }
        );

        return response;
    } catch (e) {
      return http.Response("error: $e", 500);
    }
  }

}
