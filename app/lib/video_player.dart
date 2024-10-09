// --- Dart/Flutter libraries ---
import 'dart:async';
import 'package:flutter/material.dart';

// --- Miscellaneous Libraries
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class Video extends StatelessWidget {
  final String name;

  const Video({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: VideoPlayerScreen(videoName: name));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoName;

  const VideoPlayerScreen({super.key, required this.videoName});

  @override
  State<VideoPlayerScreen> createState() => _VideoState();
}

class _VideoState extends State<VideoPlayerScreen> {
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late Chewie playerWidget;

  // Initialize video controllers while asynchronously fetching video
  Future<void> init() async {
    final storageRef = FirebaseStorage.instance.ref().child("videos");
    final videoURL = await storageRef.child(widget.videoName).getDownloadURL();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoURL));
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false);
    playerWidget = Chewie(controller: chewieController);
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        title: Center(
            child:
                Text(widget.videoName, style: TextStyle(color: Colors.white))));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topBar,
        body: FutureBuilder(
            future: init(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return playerWidget;
              }
            }));
  }
}
