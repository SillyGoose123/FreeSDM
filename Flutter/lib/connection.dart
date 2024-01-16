import "dart:io";
import "package:flutter/rendering.dart";
import "package:freesdm/command_page.dart";
import "package:freesdm/main.dart";
import "package:freesdm/settings.dart";
import "package:freesdm/settings_page.dart";
import "package:http/http.dart" as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import "dart:async";
import "package:flutter/material.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";

class Connections extends StatefulWidget {
  const Connections({super.key});

  @override
  State<StatefulWidget> createState() => _ConnectionsState();
}

class _ConnectionsState extends State<Connections> {
  final _connections = <String>[];
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  final _formKeyPin = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  var _pinSeen = false;
  final _focusNode = FocusNode();

  SharedPreferences? _prefs;

  _loadData() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs?.getStringList("connections")?.forEach((element) {
        _connections.add(element);
      });
    });
  }

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _pinSeen = !_focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _loadData();
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Expanded(
                  child: Text("Pin:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ))),
              IconButton(
                onPressed: () => _showPage(const SettingsPage(name: "Standard", commandPage: false)),
                icon: const Icon(Icons.settings),
                alignment: Alignment.centerRight,
              )
            ],
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Form(
                  key: _formKeyPin,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    focusNode: _focusNode,
                    obscureText: _pinSeen,
                    controller: _pinController,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        hintText: "Pin",
                        suffixIcon: IconButton(
                            onPressed: () => _pinController.clear(),
                            icon: const Icon(Icons.clear))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
                        return "Invalid pin.";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ))),
          const Center(
            child: Text("Connection addresses:",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      itemCount: _connections.length * 2 + 1,
                      itemBuilder: (context, i) {
                        if (i.isOdd) {
                          return const Divider();
                        }

                        if (i ~/ 2 < _connections.length) {
                          return _createNormalListTile(i ~/ 2);
                        }

                        return _createAddConnection();
                      })))
        ]));
  }

  Widget _createNormalListTile(i) {
    return ListTile(
        title: Text(_connections[i]),
        trailing: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showPage(SettingsPage(
                name: _connections[i]
            ))
          ),

        onTap: () {
          if (!_formKeyPin.currentState!.validate() ||
              _pinController.text.isEmpty) {
            showErrorDialog(context, "Invalid pin.");
            return;
          }


          _establishConnection(
              _connections[i], _pinController.text);
        });
  }

  Widget _createAddConnection() {
    return ListTile(
        title: Form(
            key: _formKey,
            autovalidateMode:
            AutovalidateMode.onUserInteraction,
            child: TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                  icon: const Icon(Icons.add),
                  hintText: "Target ip address",
                  suffixIcon: IconButton(
                      onPressed: () =>
                          _textController.clear(),
                      icon: const Icon(Icons.clear))),
              onFieldSubmitted: (value) {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                setState(() {
                  _connections.add(_textController.text);
                  Settings(name: _textController.text)
                      .createByStandard();
                  _textController.clear();
                  _prefs?.setStringList(
                      "connections", _connections);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }

                if (!RegExp(
                    r"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$")
                    .hasMatch(value)) {
                  return "Invalid ip address.";
                }

                if (_connections.contains(value)) {
                  return "Already added.";
                }

                return null;
              },
              maxLength: 15,
              keyboardType: TextInputType.number,
      )));
  }


  _establishConnection(String connection, String pin) async {
    print(connection);
    BuildContext? dialogContext;

    dismissDialog() {
      Navigator.pop(dialogContext!);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return SizedBox(
              height: MediaQuery.of(context).size.height - 50,
              child: Container(
                  color: Colors.black.withOpacity(0.65),
                  child: Column(children: [
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.only(left: 16, top: 16),
                            child: Text("Establishing connection:",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)))),
                    LoadingAnimationWidget.prograssiveDots(
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width / 2),
                    Center(
                        child: IconButton(
                      style: ButtonStyle(
                        iconSize: MaterialStateProperty.all<double>(50),
                      ),
                      onPressed: () {
                        dismissDialog();
                      },
                      icon: const Icon(Icons.close),
                    )),
                  ])));
        });

    try {
      //wait so cancel button can be pressed
      await Future.delayed(const Duration(milliseconds: 100));

      final Settings settings = await Settings(name: connection).loadData();

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      var versionReq = await http.get(
          Uri.parse("http://$connection:${settings.port}/version"),
          headers: {HttpHeaders.authorizationHeader: pin});

      if (versionReq.statusCode != 200 ||
          versionReq.body.trim() != packageInfo.version.trim()) {
        dismissDialog();
        _showErrorDialog("Connection failed.");
        return;
      }

      var req = await http.get(
          Uri.parse("http://$connection:${settings.port}/connect"),
          headers: {HttpHeaders.authorizationHeader: pin});

      if(req.body.contains("true")) {
        dismissDialog();
        _showPage(CommandPage(
            ip: connection,
            pin: pin
        ));
        return;
      } else {
        dismissDialog();
        _showErrorDialog("Connection failed.");
        return;
      }

    } catch (e) {
      dismissDialog();
      _showErrorDialog("Connection failed.");
    }
  }

  void _showErrorDialog(String message) {
    showErrorDialog(context, message);
  }

  void _showPage(Widget page) {
    showPage(page, context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_prefs', _prefs));
  }

}
