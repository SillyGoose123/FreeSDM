import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:freesdm/commandPage.dart";
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

  var _prefs;

  _loadData() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs.getStringList("connections")?.forEach((element) {
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
          const Text("Pin:",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent)),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Form(
                  key: _formKeyPin,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    focusNode: _focusNode,
                    obscureText: _pinSeen,
                    controller: _pinController,
                    decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        hintText: "Target ip address",
                        suffixIcon: IconButton(
                            onPressed: () => _pinController.clear(),
                            icon: const Icon(Icons.clear))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      if (!RegExp(r"^[0-9]*$").hasMatch(value!)) {
                        return "Not valid pin";
                      }

                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ))),
          const Center(
            child: Text("Connection addreses:",
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
                          return ListTile(
                              title: Text(_connections[i ~/ 2]),
                              trailing: IconButton(
                                  onPressed: () => setState(() {
                                        _connections
                                            .remove(_connections[i ~/ 2]);
                                        _prefs.setStringList(
                                            "connections", _connections);
                                      }),
                                  icon: const Icon(Icons.delete)),
                              onTap: () {
                                if (!_formKeyPin.currentState!.validate() ||
                                    _pinController.text.isEmpty) {

                                    final PersistentBottomSheetController controller = showBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 100,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Center(
                                                  child: Padding(
                                                      padding: EdgeInsets.only(left: 16),
                                                      child: Text(
                                                        'Please enter a valid pin.',
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.redAccent
                                                        )
                                                    )
                                                  )
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: IconButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  icon: const Icon(Icons.close),
                                                )
                                                ),
                                              ],
                                            )
                                        );
                                      });

                                  Timer(const Duration(seconds: 2), () {
                                    controller.close();
                                  });
                                  return;
                                }

                                Navigator.pop(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommandPage(
                                            ip: _connections[i ~/ 2],
                                            pin: _pinController.text)));
                              });
                        }

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
                                      _textController.clear();
                                      _prefs.setStringList(
                                          "connections", _connections);
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }

                                    if (!RegExp(
                                            r"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$")
                                        .hasMatch(value!)) {
                                      return "Not valid ip address";
                                    }

                                    if (_connections.contains(value)) {
                                      return "Already added";
                                    }

                                    return null;
                                  },
                                  maxLength: 15,
                                  keyboardType: TextInputType.number,
                                )));
                      })))
        ]));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_prefs', _prefs));
  }
}
