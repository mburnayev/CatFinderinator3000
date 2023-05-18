import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Video entrypoint
class Video extends StatelessWidget {
  final String name;
  const Video({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: VideoPlayerScreen(name: name));
  }
}

class VideoPlayerScreen extends StatefulWidget {
  // video name
  final String name;
  const VideoPlayerScreen({super.key, required this.name});

  @override
  State<VideoPlayerScreen> createState() => _VideoState();
}

class _VideoState extends State<VideoPlayerScreen> {
  final storageRef = FirebaseStorage.instance.ref().child("videos");
  String videoURLName = "";
  late VideoPlayerController _controller;
  late Future<void> _initVPFuture;

  // initialize video controllers while asynchronously fetching video
  @override
  void initState() {
    super.initState();
    getVideo();
    _controller = VideoPlayerController.network(videoURLName);
    _initVPFuture = _controller.initialize();
  }

  // retrieve video and have controllers update to display video
  Future<void> getVideo() async {
    final videoURL = await storageRef.child(widget.name).getDownloadURL();
    videoURLName = videoURL;
    _controller = VideoPlayerController.network(videoURLName);
    _initVPFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return singleVideo;
  }

  // adds watchable video, play and pause options, buttons to go back to Home
  Widget get singleVideo {
    return Scaffold(
      // the AppBar widget apparently comes with a back button?
      appBar: AppBar(title: Text(widget.name)),
      body: FutureBuilder(
        future: _initVPFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller)
            );
          } else {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
        }
      ),
      floatingActionButton: playPauseButton,
    );
  }

  Widget get playPauseButton {
    return FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow
        )
    );
  }

}
