import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freesdm/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  final String name;
  final bool commandPage;
  final BuildContext? completeContext;

  const SettingsPage({
    super.key,
    required this.name,
    this.commandPage = false,
    this.completeContext,
  });

  const SettingsPage.commandPage({
    super.key,
    required this.name,
    required this.commandPage,
    required this.completeContext,
  });

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
        backgroundColor: const Color.fromRGBO(24, 24, 24, 1.0),
        body: Padding(
          padding: EdgeInsets.only(
              top: widget.commandPage ? 0 : 65, left: 16, right: 16),
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
                  maxLength: 4,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  controller: portController,
                ),

                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text(
                                      "Delete?",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    content: Text(
                                      "Are you sure you want to reset ${widget.name} to standard?",
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 18),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text("Yes"),
                                        onPressed: () {
                                          if (widget.name == "Standard") {
                                            settings.delete();
                                            settings.createStandard();
                                            fetchSettings();
                                            return;
                                          }

                                          settings.loadStandard();
                                          settings.saveData();
                                          fetchSettings();
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text("No"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  );
                                });
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
                            if (!widget.commandPage) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Save")),
                      if (widget.name != "Standard")
                        ElevatedButton.icon(
                          onPressed: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text(
                                      "Delete?",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete ${widget.name}?",
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 18),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text("Yes"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          SharedPreferences
                                              .getInstance().then((prefs) {
                                              var connections = prefs.getStringList("connections")!;
                                              connections.remove(widget.name);
                                              prefs.setStringList("connections", connections);
                                              settings.delete();

                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  PageRouteBuilder(
                                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                      const begin = Offset(0.0, -1.0);
                                                      const end = Offset.zero;
                                                      const curve = Curves.ease;

                                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                                      return SlideTransition(
                                                        position: animation.drive(tween),
                                                        child: Container(color: Colors.black, child: child),
                                                      );
                                                    },
                                                    pageBuilder: (context, animation, secondaryAnimation) => const MyApp(),),
                                                    (route) => false);
                                          });




                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text("No"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                        )
                      else
                        const Text(""),
                    ]),
                Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: widget.commandPage
                        ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(widget.completeContext!);
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text("Exit"))
                        : ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancel"),
                    )),
              ],
            ),
          ),
        ],
      );
    });
  }
}
