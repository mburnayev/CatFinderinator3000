import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  List<VideoItem> list = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: homeApp);
  }

  Widget get homeApp {
    getResults();
    print("list length is ${list.length}");
    return videoListScaffold;
  }

  Future<void> getResults() async {
    var listResult = await storageRef.listAll();
    for (var item in listResult.items) {
      print(item.name);
      list.add(VideoItem(item.name));
    }
    print("res");
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
        child: ListView.builder(
          itemBuilder: (context, index) => VideoList(item: list[index]),
          itemCount: list.length,
        ),
      )
    );
  }

}

class VideoItem {
  String title;
  VideoItem(this.title);
}

class VideoList extends StatefulWidget {
  final VideoItem? item;
  // final Function(VideoItem videoItem)? onPressed;
  // const VideoList({super.key, this.item, this.onPressed});
  const VideoList({super.key, this.item});


  @override
  State<StatefulWidget> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  VideoItem? item;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(item!.title));
  }
}