import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: homeApp);
  }

  void printDialogue() => print("button clicked");

  Widget get homeApp {
    return scrollableList;
  }

  Widget get scrollableList {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FloatingActionButton(onPressed: printDialogue),
              FloatingActionButton(onPressed: printDialogue),
              FloatingActionButton(onPressed: printDialogue)]
          )
        )
      )
    );
  }
}