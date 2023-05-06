import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: homeApp);
  }

  void printDialogue() => print("button clicked");

    Widget get homeApp {
      return Scaffold(
          body: Center(
            child: Column(
                children: [const Text("Nothing here yet, but here's a button :)",
                    style: TextStyle(color: Colors.lightBlue, fontSize: 30),
                    textAlign: TextAlign.center),
                  FloatingActionButton(onPressed: printDialogue)])
          )
      );
    }

}
