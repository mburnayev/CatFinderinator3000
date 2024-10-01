import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cat_finderinator_threethousand/video_player.dart';

class Videos extends StatefulWidget {
  const Videos({super.key});

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  // reference to Firebase Cloud Storage bucket using earlier credentials
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  // video names list
  List<String> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: homeApp);
  }

  // buffers then retrieves correct Scaffold depending on number of videos
  Widget get homeApp { // thank you chat ChatGPT
    return FutureBuilder<void>(
      future: getResults(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Display a loading indicator while waiting for results
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle any errors that occur during the asynchronous operation
        } else {
          Widget finalScaffold = const Scaffold();
          finalScaffold = (list.isEmpty) ? noVideosScaffold : videoListScaffold;
          return finalScaffold; // Generate the scaffold widget once the results are available
        }
      },
    );
  }

  // retrieves video names from Firebase Cloud Storage bucket
  Future<void> getResults() {
    return storageRef.listAll().then((listResult) {
      for (var item in listResult.items) {
        list.add(item.name);
      }
    });
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

  // redirects user to corresponding video when video name tapped/pressed
  Widget get videoListScaffold {
    return Scaffold(
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
                child: Text(list[index].toString()),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Video(name: list[index]))));
          }
      )
    );
  }

}