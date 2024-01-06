import "package:flutter/material.dart";
import "connection.dart";

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
        theme: ThemeData(
            useMaterial3: true,

            // Define the default brightness and colors.
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              background: Colors.white10,
              brightness: Brightness.dark,
            ),
            drawerTheme: const DrawerThemeData(backgroundColor: Colors.white10),
            navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Colors.white10,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorColor: Colors.blueAccent,
            ),
            textTheme: const TextTheme(
              displaySmall: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              displayMedium: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
              displayLarge: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            )),
        home: const Scaffold(
          body: Connections(),
        ));
  }
}