// --- Dart/Flutter libraries ---
import 'package:flutter/material.dart';

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

  PreferredSizeWidget get topBar {
    return AppBar(backgroundColor: Colors.deepPurple,
      elevation: 4,
      title: Center(
          child: const Text("Videos!!",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white
              )))
    );
  }

  // Buffers then retrieves correct Scaffold depending on number of videos
  Widget get homeApp {
    return FutureBuilder<void>(
      future: getResults(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while waiting for results
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any errors that occur during the asynchronous operation
          return Text('Error: ${snapshot.error}');
        } else {
          Widget finalScaffold = const Scaffold();
          finalScaffold =
              (videoNamesList.isEmpty) ? noVideosScaffold : videoListScaffold;
          // Retrieve the appropriate scaffold widget once the results are available
          return finalScaffold;
        }
      },
    );
  }

  // Retrieves video names from Firebase Cloud Storage bucket
  Future<void> getResults() {
    return storageRef.listAll().then((listResult) {
      for (var item in listResult.items) {
        videoNamesList.add(item.name);
      }
    });
  }

  Widget get noVideosScaffold {
    return Scaffold(
        appBar: topBar,
        body: Center(
            child: Text(
          "No recent cat recordings — stay tuned!",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 30
          ),
          textAlign: TextAlign.center,
        )));
  }

  // Redirects user to corresponding video when video name tapped/pressed
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: homeApp);
  }
}
