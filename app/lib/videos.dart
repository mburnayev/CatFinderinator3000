// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';
import 'dart:ui';

// --- Miscellaneous Libraries
import 'package:firebase_storage/firebase_storage.dart';

// --- Local Package Files ---
import 'package:cat_finderinator_threethousand/video_player.dart';

class Videos extends StatefulWidget {
  const Videos({super.key});

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  List<String> videoNamesList = [];

  // Retrieves video names from Firebase Cloud Storage bucket
  Future<void> getResults() {
    return storageRef.listAll().then((listResult) {
      for (var item in listResult.items) {
        videoNamesList.insert(0, item.name);
      }
    });
  }

  Future<void> refreshHelper() async {
    setState(() {
      videoNamesList = [];
    });
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        title: Center(
            child: const Text("Cat Videos!",
                style: TextStyle(fontSize: 24, color: Colors.white))));
  }

  // Scaffold that is used when no videos are present in videos list
  Widget get noVideosScaffold {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad
          },
        ),
        child: RefreshIndicator(
            onRefresh: refreshHelper,
            child: Scaffold(
                appBar: topBar,
                body: ListView(children: [
                  Center(
                      heightFactor: 15,
                      child: Text(
                        "No recent cat detections — stay tuned!",
                        style: TextStyle(color: Colors.blue, fontSize: 30),
                        textAlign: TextAlign.center,
                      ))
                ]))));
  }

  // Scaffold for 1+ videos in videos list, redirects user to video on press
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
                              Video(name: videoNamesList[index]))));
            }));
  }

  // Buffers then retrieves correct Scaffold depending on number of videos
  Widget get homeApp {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad
          },
        ),
        child: RefreshIndicator(
            onRefresh: refreshHelper,
            child: FutureBuilder<void>(
              future: getResults(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  Widget finalScaffold = const Scaffold();
                  finalScaffold = (videoNamesList.isEmpty)
                      ? noVideosScaffold
                      : videoListScaffold;
                  return finalScaffold;
                }
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: homeApp);
  }
}
