// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';

// --- Local Package Files ---
import 'package:cat_finderinator_threethousand/demo_player.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<String> videoNamesList = ["demo_video_1.mp4", "demo_video_2.mp4", "demo_video_3.mp4"];

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        title: Center(
            child: const Text("CatFinderinator3000 demo: example recordings",
                style: TextStyle(fontSize: 24, color: Colors.white))));
  }

  // Scaffold for demo videos included as app assets, redirects user to video on press
  Widget get videoListScaffold {
    return Scaffold(
        appBar: topBar,
        body: ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: videoNamesList.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                  child: Text(videoNamesList[index].toString()),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DemoVideo(name: videoNamesList[index]))));
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: videoListScaffold);
  }
}
