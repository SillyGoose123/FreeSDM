import 'dart:async';

import 'package:flutter/cupertino.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key, required String ip, required String pin});

  @override
  _CommandPageState createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  @override
  Widget build(BuildContext context) {
    return const Text("Command Page");
  }
  
}