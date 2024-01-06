import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key, required String ip, required String pin});

  @override
  _CommandPageState createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          child: Column(children: [
            const Text("Pin:",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            ]
          ),
    );
  }
  
}