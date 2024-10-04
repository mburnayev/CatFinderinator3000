// --- Dart/Flutter libraries ---
import 'dart:async';
import 'package:flutter/material.dart';

// --- Miscellaneous Libraries
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  String videoURLName = "";
  late VideoPlayerController _controller;
  late Future<void> _initVPFuture;

  // Initialize video controllers while asynchronously fetching video
  @override
  void initState() {
    super.initState();
    getVideo();
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoURLName));
    _initVPFuture = _controller.initialize();
  }

  // Retrieve video and have controllers update to display video
  Future<void> getVideo() async {
    final videoURL = await storageRef.child(widget.videoName).getDownloadURL();
    videoURLName = videoURL;
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoURLName));
    _initVPFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Customized AppBar
  PreferredSizeWidget get topBar {
    return AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        title: Center(
            child: Text(widget.videoName,
                style: TextStyle(fontSize: 24, color: Colors.white))));
  }

  // Adds watchable video, play and pause options, buttons to go back to Home
  Widget get singleVideo {
    return Scaffold(
      // The AppBar widget apparently comes with a back button?
      appBar: topBar,
      body: FutureBuilder(
          future: _initVPFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: playPauseButton,
    );
  }

  Widget get playPauseButton {
    return FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow));
  }

  @override
  Widget build(BuildContext context) {
    return singleVideo;
  }
}
