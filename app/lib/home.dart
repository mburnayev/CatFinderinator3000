import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const App());
// }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
