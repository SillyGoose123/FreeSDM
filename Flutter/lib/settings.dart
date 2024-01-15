import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection.dart';
import 'main.dart';

class Settings {
  late final String name;
  var port;

  Settings({required this.name});

  Future<Settings> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(name)) {
      Settings(name: name).createByStandard();
    }

    var data = prefs.getStringList(name)!;
    port = int.parse(data[0]);

    return this;
  }

  void createByStandard() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("Standard")) {
      createStandard();
    }

    prefs.setStringList(name, prefs.getStringList("Standard")!);
  }

  void createStandard() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("Standard", ["8000"]);
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(name, [port.toString()]);
  }
}

class SettingsPage extends StatefulWidget {
  final String name;

  const SettingsPage({super.key, required this.name});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  Widget content = const Text("Loading...");

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 65, left: 16, right: 16),
      child: content,
    ));
  }

  Future<void> fetchSettings() async {
    final Settings settings = await Settings(name: widget.name).loadData();
    var portController = TextEditingController(text: settings.port.toString());
    var formKey = GlobalKey<FormState>();

    setState(() {
      content = Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text("${widget.name} Settings:",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ))),
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a port";
                    }
                    if (!RegExp(r"^[0-9]*$").hasMatch(value)) {
                      return "Not valid port";
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Port",
                      suffixIcon: IconButton(
                          onPressed: () =>
                              portController.text = settings.port.toString(),
                          icon: const Icon(CupertinoIcons.arrow_2_circlepath))),
                  onChanged: (value) {},
                  maxLength: 4,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  controller: portController,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            portController.text = settings.port.toString();
                          },
                          icon: const Icon(CupertinoIcons.arrow_2_circlepath),
                          label: const Text("Reset")),
                      ElevatedButton.icon(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              showErrorDialog(context,
                                  "Please make sure that all fields are valid.");
                              return;
                            }

                            settings.port = int.parse(portController.text);
                            settings.saveData();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Save")),
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text("Cancel")),
                    ]),
              ],
            ),
          ),
        ],
      );
    });
  }
}
