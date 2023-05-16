import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cat_finderinator_threethousand/videoPlayer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  List<String> list = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: homeApp);
  }

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

  Widget get videoListScaffold {
    return Scaffold(
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Text(index.toString()),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Video())),
            );
          }
      )
    );
  }

}