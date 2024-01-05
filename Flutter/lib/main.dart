import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "FreeSDM",
        home: Scaffold(
            backgroundColor: const Color.fromRGBO(32, 32, 32, 100),
            body: Column(
              children: [
                
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(89, 149, 192, 100)),
                  ),
                  onPressed: () { },
                  child: const Text('Connect'),
                )
              ],
            )));
  }
}
