import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance.ref();
final videosRef = storage.child("videos");
int numResults = 0;

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
    getResults;
    return (numResults == 0) ? noVideosScaffold : videoListScaffold;
  }

  Future<void> getResults() async {
    var listResult = await videosRef.listAll();
    for(var item in listResult.items){
      numResults++;
    }
  }

  Widget get noVideosScaffold {
    return const Scaffold(
        body: Center(
            child: Text("No recent cat detection recordings — stay tuned!",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            )
        )
    );
  }

  Widget get videoListScaffold {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FloatingActionButton(onPressed: printDialogue)]
          )
        )
      )
    );
  }

}

class VideoItem {
  String title;
  VideoItem(this.title);
}