import "package:flutter/cupertino.dart";
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
        ),
        home: const Scaffold(
          body: Connections(),
        ));
  }
}

void showErrorDialog(BuildContext context, String message) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text(
          "Error",
          style: TextStyle(fontSize: 20),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.redAccent, fontSize: 18),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Ok"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    },
  );
}

showPage(Widget page, BuildContext context) {
  Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: Container(color: Colors.black, child: child),
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) => page));
}
